#!/usr/bin/env python3
import requests
import json

# Load the sample data
with open('sensor-log.json', 'r') as f:
    sample_data = json.load(f)

# Send POST request to the logger
url = 'http://localhost:8000/data'
response = requests.post(url, json=sample_data)

print(f"Status Code: {response.status_code}")
print(f"Response: {response.json()}")

if response.status_code == 200:
    print("\nData successfully logged to CSV!")
    print("Check sensor_data.csv for the recorded data.")