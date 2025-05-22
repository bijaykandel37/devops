import requests
import subprocess
import sys
import datetime
import time
import os
now = datetime.datetime.now()
file_now = time.time()

##THING TO CHANGE####
server_name="someServer"
folder_path = "/cron/logs"
days_to_keep = 30
url = "https://chat.googleapis.com/v1/spaces/someCode/messages?key=someKey"
headers = {'Content-Type': 'application/json; charset=UTF-8'}
#####################

if not os.path.exists(folder_path):
    os.makedirs(folder_path)
    print(f"Folder created at {folder_path}")
else:
    print(f"Folder already exists at {folder_path}")

if sys.version_info < (3, 0):
    print("Python 2.x is not supported. Please upgrade to Python 3.x.")
else:
    if len(sys.argv) < 2:
        print("Usage: python run_script.py <script_file>")
        sys.exit(1)
    script_file = sys.argv[1]
    log_file = os.path.join("logs", f"{script_file}_{now.strftime('%Y-%m-%d_%H-%M-%S')}.log")
    try:
        subprocess.run(["bash", script_file], check=True, stderr=subprocess.PIPE)
        bot_success_data = {
          "text": "*"+server_name+"* ✅ Success running `"+script_file+"` Cheers 🍻"
          }
        response = requests.post(url, json=bot_success_data, headers=headers)
        # if response.status_code == 200:
        #     print("Request successful!")
        # else:
        #     print(f"Request failed with status code {response.status_code}")
        print(f"{script_file} completed successfully!")
    except subprocess.CalledProcessError as e:
        bot_error_data = {
          "text": "*"+server_name+"* ❌ Error occured while running "+script_file+" Plesae Check log. PATH=/cron/`"+log_file+"` ❌"
          }
        response = requests.post(url, json=bot_error_data, headers=headers)
        # if response.status_code == 200:
        #     print("Request successful!")
        # else:
        #     print(f"Request failed with status code {response.status_code}")
        print(f"Error running {script_file}: {e}")
        with open(log_file, "w") as f:
            f.write(e.stderr.decode())
        print(f"Error output saved to {log_file}")
    # Delete old files
    for file_name in os.listdir(folder_path):
        file_path = os.path.join(folder_path, file_name)
        # Check if file is older than 15 days
        if os.path.isfile(file_path) and (file_now - os.path.getmtime(file_path)) // (24 * 3600) > days_to_keep:
            # Delete file
            os.remove(file_path)
            print(f"Deleted file {file_name}")

