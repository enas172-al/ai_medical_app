import json

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    "example_name": {"ar": "أحمد محمد علي", "en": "Ahmed Mohamed Ali"},
    "example_dob": {"ar": "15 يناير 1990", "en": "January 15, 1990"},
    "example_family_member_1": {"ar": "سارة أحمد", "en": "Sarah Ahmed"},
    "example_family_member_2": {"ar": "محمد أحمد", "en": "Mohamed Ahmed"},
    "years_old": {"ar": "{} سنة", "en": "{} years old"},
}

for key, val in new_translations.items():
    if key not in ar_data:
        ar_data[key] = val["ar"]
    if key not in en_data:
        en_data[key] = val["en"]

with open(ar_path, 'w', encoding='utf-8') as f:
    json.dump(ar_data, f, ensure_ascii=False, indent=2)

with open(en_path, 'w', encoding='utf-8') as f:
    json.dump(en_data, f, ensure_ascii=False, indent=2)

print("Example data translations added!")
