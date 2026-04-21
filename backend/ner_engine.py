"""
Hybrid lab-line parser: regex (Latin + Arabic) + light spaCy on unmatched lines.
Outputs tests compatible with FastAPI ParseResponse / Flutter AIParseService.
"""
import re
import spacy
from typing import Any, Dict, List, Optional, Set, Tuple

from models import TestResult

# English model: token + like_num for value detection on hard lines.
try:
    nlp = spacy.load("en_core_web_sm", disable=["lemmatizer"])
except OSError:
    print("Downloading spaCy model 'en_core_web_sm' (first run only)...")
    import spacy.cli

    spacy.cli.download("en_core_web_sm")
    nlp = spacy.load("en_core_web_sm", disable=["lemmatizer"])


# --- Keywords (Latin slug + raw Arabic fragments in reports) ---
_VALID_KEYWORDS_EN = frozenset(
    [
        "glucose",
        "sugar",
        "glu",
        "hemoglobin",
        "hemo",
        "hgb",
        "cholesterol",
        "chol",
        "vitamin",
        "vitd",
        "wbc",
        "rbc",
        "platelet",
        "plt",
        "creatinine",
        "creat",
        "alt",
        "ast",
        "tsh",
        "ft4",
        "ft3",
        "iron",
        "ferritin",
        "calcium",
        "potassium",
        "sodium",
        "urea",
        "uricacid",
        "triglyceride",
        "hdl",
        "ldl",
        "albumin",
        "bilirubin",
        "inr",
        "pt",
        "aptt",
        "esr",
        "crp",
        "hba1c",
        "a1c",
        "mch",
        "mcv",
        "mchc",
        "mpv",
        "rdw",
        "neutrophil",
        "lymphocyte",
        "monocyte",
        "eosinophil",
        "basophil",
        "urea",
        "bun",
    ]
)

_VALID_KEYWORDS_AR = (
    "هيمو",
    "هيموجلوبين",
    "غليكوز",
    "جلوكوز",
    "سكر",
    "كوليسترول",
    "الكوليسترول",
    "فيتامين",
    "د ",
    "صفائح",
    "صفحات",
    "كريات",
    "بيض",
    "حمر",
    "كرياتينين",
    "الكرياتينين",
    "يوريا",
    "حمض",
    "uric",
    "الحديد",
    "ferritin",
    "تيروكسين",
    "tsh",
    "wbc",
    "rbc",
)

_IGNORE_LATIN = frozenset(
    [
        "date",
        "time",
        "patient",
        "name",
        "age",
        "result",
        "normal",
        "range",
        "reception",
        "sysmex",
        "deficiency",
        "id",
        "ref",
        "sex",
        "sample",
        "specimen",
        "report",
        "page",
        "laboratory",
    ]
)

_IGNORE_ARABIC_SUBSTR = ("تاريخ", "اسم", "مريض", "عمر", "الجنس", "رقم")


def categorize_status(value: float, min_range: float, max_range: float) -> str:
    if min_range is not None and max_range is not None:
        if value < min_range:
            return "Low"
        if value > max_range:
            return "High"
    return "Normal"


def _slug_latin(s: str) -> str:
    return re.sub(r"[^a-z0-9]", "", s.lower())


def _is_noise_name_latin(name: str) -> bool:
    n = name.lower().strip()
    if len(n) < 2:
        return True
    cleaned = _slug_latin(n)
    if any(w in cleaned for w in _IGNORE_LATIN):
        return True
    return not any(kw in cleaned for kw in _VALID_KEYWORDS_EN)


def _is_noise_name_arabic(name: str) -> bool:
    t = name.strip()
    if len(t) < 2:
        return True
    if any(x in t for x in _IGNORE_ARABIC_SUBSTR):
        return True
    if any(k in t for k in _VALID_KEYWORDS_AR):
        return False
    # Arabic line but no known token: allow if looks like a word + value (len)
    if re.search(r"[\u0600-\u06FF]", t) and len(t) >= 3:
        return False
    return True


def _has_medical_keyword(name: str) -> bool:
    if not _is_noise_name_arabic(name):
        return True
    return not _is_noise_name_latin(name)


# Latin / mixed lab lines: Hemoglobin 12.5 g/dL 12.0-16.0  |  HGB: 13.1
_PAT_LATIN = re.compile(
    r"([A-Za-z][A-Za-z0-9\s\-\.]{1,55}?)\s*[:=]?\s*(\d+[.,]?\d*)\s*([a-zA-Z/%./μµ\-]{0,28})\s*(?:\[?\(?(\d+[.,]?\d*)\s*(?:-|–|to)\s*(\d+[.,]?\d*)\)?\]?)?"
)

# Arabic-first names (RTL reports): هيموجلوبين 13.2 g/dL ...
_PAT_ARABIC = re.compile(
    r"([\u0600-\u06FF][\u0600-\u06FF0-9\s\u0660-\u0669\u06F0-\u06F9]{1,55}?)\s*[:：\u061b]?\s*(\d+[.,]?\d*)\s*([a-zA-Z/%./μµ\-]{0,28})\s*(?:\[?\(?(\d+[.,]?\d*)\s*[-–]\s*(\d+[.,]?\d*)\)?\]?)?",
    re.UNICODE,
)


def _float_token(s: Optional[str]) -> Optional[float]:
    if not s:
        return None
    try:
        return float(s.replace(",", ".").replace("٫", "."))
    except ValueError:
        return None


def _try_match_to_result(m: re.Match) -> Optional[TestResult]:
    raw_name = m.group(1).strip()
    if not raw_name or not _has_medical_keyword(raw_name):
        return None
    value = _float_token(m.group(2))
    if value is None:
        return None
    unit = (m.group(3) or "").strip()
    min_r = _float_token(m.group(4)) if m.lastindex >= 4 else None
    max_r = _float_token(m.group(5)) if m.lastindex >= 5 else None
    status = (
        categorize_status(value, min_r, max_r)
        if min_r is not None and max_r is not None
        else "Normal"
    )
    return TestResult(
        name=raw_name,
        value=value,
        unit=unit,
        status=status,
        min_range=min_r,
        max_range=max_r,
    )


def _regex_candidates(line: str) -> List[TestResult]:
    out: List[TestResult] = []
    for pat in (_PAT_LATIN, _PAT_ARABIC):
        for m in pat.finditer(line):
            tr = _try_match_to_result(m)
            if tr:
                out.append(tr)
    return out


def _spacy_fallback_line(line: str) -> Optional[TestResult]:
    """If a line has a number but regex missed, use tokenization + like_num."""
    tl = line.strip()
    if len(tl) < 4 or len(tl) > 400:
        return None
    doc = nlp(tl)
    for i, tok in enumerate(doc):
        if not tok.like_num:
            continue
        val = _float_token(tok.text)
        if val is None or not (0.001 <= abs(val) <= 1e7):
            continue
        parts: List[str] = []
        for j in range(i - 1, -1, -1):
            t = doc[j]
            if t.is_space:
                continue
            if t.is_punct and parts:
                break
            if t.like_num:
                break
            parts.insert(0, t.text)
            if len(parts) >= 12:
                break
        name = re.sub(r"\s+", " ", "".join(parts)).strip(" :-،\u060c")
        if len(name) < 2 or not _has_medical_keyword(name):
            continue
        return TestResult(
            name=name,
            value=val,
            unit="",
            status="Normal",
            min_range=None,
            max_range=None,
        )
    return None


def _dedupe(tests: List[TestResult]) -> List[TestResult]:
    seen: Set[Tuple[str, float]] = set()
    out: List[TestResult] = []
    for t in tests:
        key = (re.sub(r"\s+", " ", t.name.strip().lower()), round(float(t.value), 4))
        if key in seen:
            continue
        seen.add(key)
        out.append(t)
    return out


def parse_medical_text(text: str) -> Dict[str, Any]:
    try:
        with open("ocr_log.txt", "a", encoding="utf-8") as f:
            f.write("\n--- NEW OCR SCAN ---\n")
            f.write(text)
            f.write("\n--------------------\n")
    except OSError:
        pass

    lines = text.splitlines()
    tests: List[TestResult] = []
    matched_line_indices: Set[int] = set()

    for i, line in enumerate(lines):
        if not line.strip():
            continue
        found = _regex_candidates(line)
        if found:
            matched_line_indices.add(i)
            tests.extend(found)

    # spaCy fallback on lines with digits but no regex hit (bounded for latency)
    max_spacy = 48
    spacy_used = 0
    for i, line in enumerate(lines):
        if i in matched_line_indices or spacy_used >= max_spacy:
            continue
        if not re.search(r"\d", line):
            continue
        tr = _spacy_fallback_line(line)
        if tr:
            tests.append(tr)
            spacy_used += 1

    tests = _dedupe(tests)
    tests_found = len(tests)
    total_lines = max(len(lines), 1)

    if tests_found > 0:
        confidence = min(0.98, 0.55 + 0.12 * tests_found + 0.25 * (tests_found / total_lines))
    else:
        confidence = 0.1

    return {
        "tests": tests,
        "confidence": round(float(confidence), 2),
    }
