import os
import re

files_to_update = [
    r'c:\src\ai_medical_app\lib\core\widgets\custom_bottom_nav_bar.dart',
    r'c:\src\ai_medical_app\lib\features\results\view\screens\result_screen.dart',
    r'c:\src\ai_medical_app\lib\features\home\screens\dashboard_screen.dart',
    r'c:\src\ai_medical_app\lib\features\profile\help_support_screen.dart'
]

for file_path in files_to_update:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Add dart:ui import if TextDirection is used
    if 'TextDirection.rtl' in content and 'import \'dart:ui\' as ui;' not in content:
        content = "import 'dart:ui' as ui;\n" + content
    
    # Fix TextDirection.rtl
    content = content.replace('TextDirection.rtl', 'ui.TextDirection.rtl')

    # Aggressive but safe const removal for widgets that contain .tr() or children that might
    content = re.sub(r'const\s+(Text\()', r'\1', content)
    content = re.sub(r'const\s+(\[)', r'\1', content)
    content = re.sub(r'const\s+(Row\()', r'\1', content)
    content = re.sub(r'const\s+(Column\()', r'\1', content)
    content = re.sub(r'const\s+(Center\()', r'\1', content)
    content = re.sub(r'const\s+(Padding\()', r'\1', content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

print('Fixed consts and TextDirection!')
