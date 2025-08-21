#!/usr/bin/env python3
"""Analyze interrupted movements in partial-movements.csv"""

from bed_frame_analysis import load_sensor_data
from ha_client import load_ha_events
from movement_detection import MovementConfig, analyze_movement
import pandas as pd
import numpy as np

# Load sensor data
print("Loading partial movements data...")
df = load_sensor_data('partial-movements.csv')

print(f"Loaded {len(df)} sensor readings")
print(f"Time range: {df['sensor_timestamp'].min()} to {df['sensor_timestamp'].max()}")
print(f"Pitch range: {df['pitch'].min():.3f} to {df['pitch'].max():.3f} radians\n")

# Load HA events for this timeframe
print("Fetching Home Assistant events...")
ha_events = load_ha_events(
    sensor_df=df,
    entity_id='cover.bed_remote_head_position',
    ha_url='http://tvpi:8123',
    token_path='/run/secrets/home-assistant/token'
)

print(f"Found {len(ha_events)} events in sensor timeframe:")
for event in ha_events:
    print(f"  {event['timestamp'].strftime('%H:%M:%S.%f')[:-3]}: {event['state']}")

# Group consecutive events to find interrupted sequences
print("\nAnalyzing event sequences:")
if len(ha_events) >= 2:
    for i in range(len(ha_events) - 1):
        curr_event = ha_events[i]
        next_event = ha_events[i + 1]
        
        time_diff = (next_event['timestamp'] - curr_event['timestamp']).total_seconds()
        
        # Check for interruption pattern (opening -> open or closing -> closed)
        if curr_event['state'] == 'opening' and next_event['state'] == 'open':
            print(f"\nInterrupted OPENING sequence:")
            print(f"  Started opening: {curr_event['timestamp'].strftime('%H:%M:%S.%f')[:-3]}")
            print(f"  Forced to stop:  {next_event['timestamp'].strftime('%H:%M:%S.%f')[:-3]}")
            print(f"  Time between: {time_diff:.3f} seconds")
            
            # Find pitch at both events
            idx_start = df['sensor_timestamp'].sub(curr_event['timestamp']).abs().idxmin()
            idx_stop = df['sensor_timestamp'].sub(next_event['timestamp']).abs().idxmin()
            
            pitch_start = df.loc[idx_start, 'pitch']
            pitch_stop = df.loc[idx_stop, 'pitch']
            print(f"  Pitch at start: {pitch_start:.3f} rad")
            print(f"  Pitch at stop command: {pitch_stop:.3f} rad")
            print(f"  Pitch change during movement: {pitch_stop - pitch_start:.3f} rad")
            
        elif curr_event['state'] == 'closing' and next_event['state'] == 'closed':
            print(f"\nInterrupted CLOSING sequence:")
            print(f"  Started closing: {curr_event['timestamp'].strftime('%H:%M:%S.%f')[:-3]}")
            print(f"  Forced to stop:  {next_event['timestamp'].strftime('%H:%M:%S.%f')[:-3]}")
            print(f"  Time between: {time_diff:.3f} seconds")
            
            # Find pitch at both events
            idx_start = df['sensor_timestamp'].sub(curr_event['timestamp']).abs().idxmin()
            idx_stop = df['sensor_timestamp'].sub(next_event['timestamp']).abs().idxmin()
            
            pitch_start = df.loc[idx_start, 'pitch']
            pitch_stop = df.loc[idx_stop, 'pitch']
            print(f"  Pitch at start: {pitch_start:.3f} rad")
            print(f"  Pitch at stop command: {pitch_stop:.3f} rad")
            print(f"  Pitch change during movement: {pitch_stop - pitch_start:.3f} rad")

# Now let's analyze the stop delay for interrupted movements
print("\n" + "="*60)
print("STOP DELAY ANALYSIS FOR INTERRUPTED MOVEMENTS")
print("="*60)

# Look for pairs of (opening/closing -> open/closed) events
for i in range(len(ha_events) - 1):
    curr_event = ha_events[i]
    next_event = ha_events[i + 1]
    
    # Check if this is an interruption
    is_interrupted = False
    if curr_event['state'] == 'opening' and next_event['state'] == 'open':
        is_interrupted = True
        movement_type = "opening"
    elif curr_event['state'] == 'closing' and next_event['state'] == 'closed':
        is_interrupted = True
        movement_type = "closing"
    
    if is_interrupted:
        print(f"\nAnalyzing interrupted {movement_type} movement:")
        
        # Get window of data from stop command onwards
        stop_command_time = next_event['timestamp']
        window_end = stop_command_time + pd.Timedelta(seconds=5)  # 5 second window
        
        window_data = df[
            (df['sensor_timestamp'] >= stop_command_time) &
            (df['sensor_timestamp'] <= window_end)
        ].copy()
        
        if len(window_data) > 10:
            from movement_detection import calculate_velocity
            
            # Calculate velocities
            window_data = calculate_velocity(window_data)
            
            # Find when movement actually stops
            MOVEMENT_THRESHOLD = 0.005  # rad/s
            STABILITY_TIME = 0.3  # seconds
            STABILITY_SAMPLES = int(STABILITY_TIME * 20)  # ~20Hz
            
            for j in range(5, len(window_data) - STABILITY_SAMPLES):
                future_window = window_data.iloc[j:j + STABILITY_SAMPLES]
                
                if len(future_window) > 0:
                    smooth_velocities = future_window['pitch_velocity_smooth'].dropna()
                    if len(smooth_velocities) > 0 and all(smooth_velocities < MOVEMENT_THRESHOLD):
                        # Movement stopped
                        actual_stop_time = window_data.iloc[j]['sensor_timestamp']
                        stop_delay_ms = (actual_stop_time - stop_command_time).total_seconds() * 1000
                        
                        final_pitch = window_data.iloc[j]['pitch']
                        
                        print(f"  Stop command at: {stop_command_time.strftime('%H:%M:%S.%f')[:-3]}")
                        print(f"  Movement stopped at: {actual_stop_time.strftime('%H:%M:%S.%f')[:-3]}")
                        print(f"  **Stop delay: {stop_delay_ms:.0f} ms**")
                        print(f"  Final pitch: {final_pitch:.3f} rad")
                        break
            else:
                print(f"  Could not detect movement stop within window")