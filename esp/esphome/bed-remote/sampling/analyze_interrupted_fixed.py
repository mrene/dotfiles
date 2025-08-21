#!/usr/bin/env python3
"""Analyze interrupted movements with proper event states"""

from bed_frame_analysis import load_sensor_data
from ha_client import HAClient
from movement_detection import calculate_velocity
import pandas as pd
import numpy as np

# Load sensor data
print("Loading partial movements data...")
df = load_sensor_data('partial-movements.csv')

print(f"Loaded {len(df)} sensor readings")
print(f"Time range: {df['sensor_timestamp'].min()} to {df['sensor_timestamp'].max()}")
print(f"Pitch range: {df['pitch'].min():.3f} to {df['pitch'].max():.3f} radians\n")

# Load HA events with ALL states (including open/closed for stop commands)
print("Fetching Home Assistant events...")

with open('/run/secrets/home-assistant/token', 'r') as f:
    token = f.read().strip()

client = HAClient('http://tvpi:8123', token)
sensor_start = df['sensor_timestamp'].min()
sensor_end = df['sensor_timestamp'].max()

# Fetch logbook entries
logbook_data = client.fetch_logbook_entries('cover.bed_remote_head_position', sensor_start)

# Parse ALL events - no filtering
ha_events = []
for entry in logbook_data:
    if 'state' in entry:
        timestamp = pd.to_datetime(entry['when'])
        if timestamp.tz is None:
            timestamp = timestamp.tz_localize('UTC')
        else:
            timestamp = timestamp.tz_convert('UTC')
        timestamp = timestamp.tz_localize(None)
        
        ha_events.append({
            'timestamp': timestamp,
            'state': entry['state'],
            'entity_id': entry.get('entity_id'),
            'name': entry.get('name')
        })

# Filter to sensor timeframe
ha_events = client.filter_events_by_timerange(ha_events, sensor_start, sensor_end)

print(f"Found {len(ha_events)} events in sensor timeframe:")
for event in ha_events:
    print(f"  {event['timestamp'].strftime('%H:%M:%S.%f')[:-3]}: {event['state']}")

# Analyze interrupted sequences
print("\n" + "="*60)
print("INTERRUPTED MOVEMENT ANALYSIS")
print("="*60)

for i in range(len(ha_events) - 1):
    curr_event = ha_events[i]
    next_event = ha_events[i + 1]
    
    # Check for interruption patterns
    is_interrupted = False
    if curr_event['state'] == 'opening' and next_event['state'] == 'open':
        is_interrupted = True
        movement_type = "OPENING"
    elif curr_event['state'] == 'closing' and next_event['state'] == 'closed':
        is_interrupted = True
        movement_type = "CLOSING"
    
    if is_interrupted:
        print(f"\n{movement_type} INTERRUPTED:")
        print(f"  Movement command: {curr_event['timestamp'].strftime('%H:%M:%S.%f')[:-3]}")
        print(f"  Stop command:     {next_event['timestamp'].strftime('%H:%M:%S.%f')[:-3]}")
        
        command_duration = (next_event['timestamp'] - curr_event['timestamp']).total_seconds()
        print(f"  Command duration: {command_duration:.3f} seconds")
        
        # Analyze pitch change during movement
        idx_start = df['sensor_timestamp'].sub(curr_event['timestamp']).abs().idxmin()
        idx_stop_cmd = df['sensor_timestamp'].sub(next_event['timestamp']).abs().idxmin()
        
        pitch_at_start = df.loc[idx_start, 'pitch']
        pitch_at_stop_cmd = df.loc[idx_stop_cmd, 'pitch']
        
        print(f"  Pitch at movement start: {pitch_at_start:.3f} rad")
        print(f"  Pitch at stop command:   {pitch_at_stop_cmd:.3f} rad")
        print(f"  Pitch change:            {pitch_at_stop_cmd - pitch_at_start:.3f} rad")
        
        # Now find when movement actually stopped after the stop command
        stop_command_time = next_event['timestamp']
        window_end = stop_command_time + pd.Timedelta(seconds=5)
        
        window_data = df[
            (df['sensor_timestamp'] >= stop_command_time) &
            (df['sensor_timestamp'] <= window_end)
        ].copy()
        
        if len(window_data) > 10:
            # Calculate velocities
            window_data = calculate_velocity(window_data)
            
            # Find when movement stops
            MOVEMENT_THRESHOLD = 0.005  # rad/s
            STABILITY_TIME = 0.3  # seconds
            STABILITY_SAMPLES = int(STABILITY_TIME * 20)
            
            for j in range(5, len(window_data) - STABILITY_SAMPLES):
                future_window = window_data.iloc[j:j + STABILITY_SAMPLES]
                
                if len(future_window) > 0:
                    smooth_velocities = future_window['pitch_velocity_smooth'].dropna()
                    if len(smooth_velocities) > 0 and all(smooth_velocities < MOVEMENT_THRESHOLD):
                        # Movement stopped
                        actual_stop_time = window_data.iloc[j]['sensor_timestamp']
                        stop_delay_ms = (actual_stop_time - stop_command_time).total_seconds() * 1000
                        
                        final_pitch = window_data.iloc[j]['pitch']
                        
                        print(f"  Movement stopped:        {actual_stop_time.strftime('%H:%M:%S.%f')[:-3]}")
                        print(f"  >>> STOP DELAY:          {stop_delay_ms:.0f} ms <<<")
                        print(f"  Final pitch:             {final_pitch:.3f} rad")
                        print(f"  Overrun after stop cmd:  {final_pitch - pitch_at_stop_cmd:.3f} rad")
                        break
            else:
                print(f"  Could not detect movement stop within 5s window")