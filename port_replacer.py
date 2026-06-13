import os

directories_to_search = [
    r"f:\AUDIRA-MAIL-OS\apps\frontend-web\src",
    r"f:\AUDIRA-MAIL-OS\apps\mobile-app\lib"
]

replacements = {
    "http://localhost:4000": "http://localhost:3311",
    "http://10.0.2.2:4000": "http://10.0.2.2:3311"
}

files_changed = 0

for directory in directories_to_search:
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith((".tsx", ".ts", ".dart")):
                filepath = os.path.join(root, file)
                
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = content
                for old_str, new_str in replacements.items():
                    new_content = new_content.replace(old_str, new_str)
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    files_changed += 1
                    print(f"Updated {filepath}")

print(f"Total files updated: {files_changed}")
