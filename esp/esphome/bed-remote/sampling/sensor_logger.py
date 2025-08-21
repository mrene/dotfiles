#!/usr/bin/env python3
import json
import csv
import os
from datetime import datetime
from flask import Flask, request, jsonify
from pathlib import Path

app = Flask(__name__)

CSV_FILE = "sensor_data.csv"
CSV_HEADERS = [
    "timestamp", "message_id", "session_id", "device_id", "sensor_name",
    "sensor_time", "yaw", "pitch", "roll", "qx", "qy", "qz", "qw"
]

def ensure_csv_exists():
    if not os.path.exists(CSV_FILE):
        with open(CSV_FILE, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=CSV_HEADERS)
            writer.writeheader()

def write_sensor_data(data):
    ensure_csv_exists()
    
    with open(CSV_FILE, 'a', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=CSV_HEADERS)
        
        for sensor_reading in data['payload']:
            row = {
                'timestamp': datetime.now().isoformat(),
                'message_id': data['messageId'],
                'session_id': data['sessionId'],
                'device_id': data['deviceId'],
                'sensor_name': sensor_reading['name'],
                'sensor_time': sensor_reading['time'],
                'yaw': sensor_reading['values'].get('yaw', ''),
                'pitch': sensor_reading['values'].get('pitch', ''),
                'roll': sensor_reading['values'].get('roll', ''),
                'qx': sensor_reading['values'].get('qx', ''),
                'qy': sensor_reading['values'].get('qy', ''),
                'qz': sensor_reading['values'].get('qz', ''),
                'qw': sensor_reading['values'].get('qw', '')
            }
            writer.writerow(row)

@app.route('/data', methods=['POST'])
def receive_data():
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No JSON data provided'}), 400
        
        write_sensor_data(data)
        
        # Log orientation values to console for correlation analysis
        for sensor_reading in data['payload']:
            if sensor_reading['name'] == 'orientation':
                values = sensor_reading['values']
                timestamp = datetime.now().strftime('%H:%M:%S.%f')[:-3]
                print(f"[{timestamp}] Yaw: {values['yaw']:.6f} | Pitch: {values['pitch']:.6f} | Roll: {values['roll']:.6f}")
        
        return jsonify({'status': 'success', 'readings_recorded': len(data['payload'])}), 200
    
    except Exception as e:
        print(f"Error processing data: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    ensure_csv_exists()
    print(f"Starting sensor logger server...")
    print(f"CSV file: {os.path.abspath(CSV_FILE)}")
    print(f"Listening on http://0.0.0.0:8000")
    app.run(host='0.0.0.0', port=8000, debug=True)