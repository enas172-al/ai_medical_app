import spacy
import re
from typing import Dict, Any
from models import TestResult

# Attempt to load spaCy model (English core small). 
# Note: For production, replacing this with 'en_core_sci_sm' (scispacy) is recommended!
try:
    nlp = spacy.load("en_core_web_sm")
except OSError:
    print("Downloading spaCy model 'en_core_web_sm' (first run only)...")
    import spacy.cli
    spacy.cli.download("en_core_web_sm")
    nlp = spacy.load("en_core_web_sm")

def categorize_status(value: float, min_range: float, max_range: float) -> str:
    if min_range is not None and max_range is not None:
        if value < min_range:
            return "Low"
        elif value > max_range:
            return "High"
    return "Normal"

def parse_medical_text(text: str) -> Dict[str, Any]:
    # Log incoming text to help debug
    with open("ocr_log.txt", "a", encoding="utf-8") as f:
        f.write("\n--- NEW OCR SCAN ---\n")
        f.write(text)
        f.write("\n--------------------\n")
        
    # NLP document parsed by spaCy (Useful for advanced entity extraction)
    doc = nlp(text)
    tests = []
    
    lines = text.split('\n')
    
    # Hybrid Rule-Based Fallback logic:
    # Pattern designed to catch [Name] [Value] [Unit] [Min-Max]
    # Example OCR line: "Hemoglobin 12.5 g/dL 12.0-16.0"
    pattern = re.compile(
        r"([A-Za-z\s]+?)\s*[:=]?\s*(\d+\.?\d*)\s*([a-zA-Z/%]*)\s*(?:\[?\(?(\d+\.?\d*)\s*(?:-|–|to)\s*(\d+\.?\d*)\)?\]?)?"
    )

    tests_found = 0
    total_lines = len(lines)
    
    for line in lines:
        match = pattern.search(line)
        if match:
            raw_name = match.group(1).strip()
            
            # Ignore random noise that looks like a test but isn't
            ignore_words = ["date", "time", "patient", "name", "age", "result", "normal", "range", "reception", "sysmex", "deficiency", "id", "ref", "sex"]
            
            
            cleaned_name = raw_name.lower().strip()
            if len(cleaned_name) < 2 or any(word in cleaned_name for word in ignore_words):
                continue
                
            # Filter out punctuation and spaces for robust checking
            alphanumeric_name = re.sub(r'[^a-z0-9]', '', cleaned_name)
            
            # Must contain at least one known medical abbreviation or test word to be considered valid
            valid_keywords = [
                "glucose", "sugar", "glu", "hemoglobin", "hemo", "hgb", "cholesterol", "chol", 
                "vitamin", "vitd", "wbc", "rbc", "platelet", "plt", "creatinine", "creat", 
                "alt", "ast", "tsh", "ft4", "ft3", "iron", "ferritin", "calcium", "potassium", 
                "sodium", "urea", "uricacid", "triglyceride", "hdl", "ldl"
            ]
            
            if not any(kw in alphanumeric_name for kw in valid_keywords):
                continue
                
            try:
                value = float(match.group(2))
                unit = match.group(3).strip()
                
                min_range, max_range = None, None
                if match.group(4) and match.group(5):
                    min_range = float(match.group(4))
                    max_range = float(match.group(5))
                    
                status = categorize_status(value, min_range, max_range) if min_range and max_range else "Normal"
                
                tests.append(TestResult(
                    name=raw_name,
                    value=value,
                    unit=unit,
                    status=status,
                    min_range=min_range,
                    max_range=max_range
                ))
                tests_found += 1
            except ValueError:
                continue # Safely skip if conversion fails

    # Confidence calculation algorithm based on parse rate
    confidence = 0.5 # Base fallback confidence
    if tests_found > 0:
        confidence = min(0.98, 0.6 + (tests_found / max(total_lines, 1)))
    else:
        confidence = 0.1 # Very low confidence, should trigger Flutter regex fallback
        
    return {
        "tests": tests,
        "confidence": round(confidence, 2)
    }
