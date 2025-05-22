import requests
import subprocess

update_script_url = "https://raw.githubusercontent.com/devmesis/scriptgrab/main/scripts/Application/update.py"

def run_update_script():
    try:
        response = requests.get(update_script_url)
        response.raise_for_status()
        script_code = response.text
        with open("temp_update_script.py", "w", encoding="utf-8") as f:
            f.write(script_code)
        result = subprocess.run(["python3", "temp_update_script.py"], capture_output=True, text=True)
        return result.stdout, result.stderr
    except Exception as e:
        return None, str(e)

# Replace this with your actual user prompt logic
auto_update_accepted = True

if auto_update_accepted:
    stdout, stderr = run_update_script()
    print(stdout)
    if stderr:
        print(stderr)
else:
    print("Auto-update not accepted.")
