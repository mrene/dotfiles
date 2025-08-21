#!/usr/bin/env python3
"""Simple test of interrupted movement analysis."""

from bed_frame_analysis import load_sensor_data, analyze_interrupted_events, print_interrupted_analysis_summary
from ha_client import load_ha_events
from movement_detection import MovementConfig

# Load data
print("Loading partial-movements.csv...")
df = load_sensor_data('partial-movements.csv')

# Load ALL events (including stop commands)
print("Loading HA events...")
events = load_ha_events(df, 'cover.bed_remote_head_position', event_types=None)

print(f"\nFound {len(events)} events:")
for event in events[:5]:  # Show first 5
    print(f"  {event['timestamp'].strftime('%H:%M:%S.%f')[:-3]}: {event['state']}")
print("  ...")

# Analyze interrupted movements
print("\nAnalyzing interrupted movements...")
config = MovementConfig()
analysis = analyze_interrupted_events(events, df, config)

# Print results
print()
print_interrupted_analysis_summary(analysis)

print(f"\nSuccessfully analyzed {len(analysis['results'])} interrupted movements!")