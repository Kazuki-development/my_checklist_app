
import urllib.request
import sys

url = "https://kazuki-development.github.io/my_checklist_app/app-ads.txt"
expected_id = "pub-9575784455721701"

try:
    with urllib.request.urlopen(url) as response:
        print(f"Status: {response.status}")
        print(f"Headers: {response.headers}")
        content = response.read().decode('utf-8')
        print(f"Content: {content}")
        
        if expected_id in content:
            print("SUCCESS: ID found in content.")
        else:
            print("FAILURE: ID NOT found in content.")
except Exception as e:
    print(f"Error: {e}")
