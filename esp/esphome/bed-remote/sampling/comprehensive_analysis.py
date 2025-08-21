#!/usr/bin/env python3
"""
Comprehensive analysis of both normal and interrupted bed frame movements.

This script demonstrates:
1. Normal movement analysis (full open/close cycles)
2. Interrupted movement analysis (stop commands during movement)
3. Comparison of stop behaviors between the two scenarios
"""

import pandas as pd
import numpy as np
from movement_detection import MovementConfig
from ha_client import load_ha_events
from bed_frame_analysis import (
    load_sensor_data,
    analyze_all_events,
    analyze_interrupted_events,
    print_analysis_summary,
    print_interrupted_analysis_summary
)


def main():
    """Run comprehensive analysis on both datasets."""
    
    print("=" * 70)
    print("COMPREHENSIVE BED FRAME MOVEMENT ANALYSIS")
    print("=" * 70)
    
    # Configuration
    config = MovementConfig(
        window_seconds=20.0,
        movement_threshold=0.005,
        stability_time=0.5,
        start_movement_threshold=0.01
    )
    
    # =========================================================================
    # PART 1: NORMAL MOVEMENTS (Complete open/close cycles)
    # =========================================================================
    print("\n" + "=" * 70)
    print("PART 1: NORMAL MOVEMENTS (open-close.csv)")
    print("=" * 70)
    
    # Load normal movement data
    normal_df = load_sensor_data('open-close.csv')
    print(f"\nLoaded {len(normal_df)} sensor readings")
    print(f"Time range: {normal_df['sensor_timestamp'].min()} to {normal_df['sensor_timestamp'].max()}")
    print(f"Pitch range: {normal_df['pitch'].min():.3f} to {normal_df['pitch'].max():.3f} radians")
    
    # Load HA events (only opening/closing for normal movements)
    normal_events = load_ha_events(
        sensor_df=normal_df,
        entity_id='cover.bed_remote_head_position',
        event_types=['opening', 'closing']  # Filter for movement commands only
    )
    
    print(f"\nFound {len(normal_events)} movement commands")
    
    # Analyze normal movements
    normal_analysis = analyze_all_events(normal_events, normal_df, config)
    print_analysis_summary(normal_analysis)
    
    # =========================================================================
    # PART 2: INTERRUPTED MOVEMENTS (Stop commands during movement)
    # =========================================================================
    print("\n" + "=" * 70)
    print("PART 2: INTERRUPTED MOVEMENTS (partial-movements.csv)")
    print("=" * 70)
    
    # Load interrupted movement data
    interrupted_df = load_sensor_data('partial-movements.csv')
    print(f"\nLoaded {len(interrupted_df)} sensor readings")
    print(f"Time range: {interrupted_df['sensor_timestamp'].min()} to {interrupted_df['sensor_timestamp'].max()}")
    print(f"Pitch range: {interrupted_df['pitch'].min():.3f} to {interrupted_df['pitch'].max():.3f} radians")
    
    # Load ALL HA events (including open/closed stop commands)
    interrupted_events = load_ha_events(
        sensor_df=interrupted_df,
        entity_id='cover.bed_remote_head_position',
        event_types=None  # Get ALL events including stop commands
    )
    
    print(f"\nFound {len(interrupted_events)} total events")
    event_types = {}
    for event in interrupted_events:
        state = event['state']
        event_types[state] = event_types.get(state, 0) + 1
    
    print("Event breakdown:")
    for state, count in sorted(event_types.items()):
        print(f"  {state}: {count}")
    
    # Analyze interrupted movements
    interrupted_analysis = analyze_interrupted_events(interrupted_events, interrupted_df, config)
    print()
    print_interrupted_analysis_summary(interrupted_analysis)
    
    # =========================================================================
    # PART 3: COMPARISON AND INSIGHTS
    # =========================================================================
    print("\n" + "=" * 70)
    print("PART 3: COMPARISON AND INSIGHTS")
    print("=" * 70)
    
    print("\n### Stop Behavior Comparison ###\n")
    
    # Normal movements stop time (voluntary stop at end of movement)
    if 'opening' in normal_analysis['statistics']:
        normal_opening_stop = normal_analysis['statistics']['opening']['avg_stop_delay_ms']
        print(f"Normal OPENING movements:")
        print(f"  Avg time to voluntary stop: {normal_opening_stop:.0f} ms")
    
    if 'closing' in normal_analysis['statistics']:
        normal_closing_stop = normal_analysis['statistics']['closing']['avg_stop_delay_ms']
        print(f"\nNormal CLOSING movements:")
        print(f"  Avg time to voluntary stop: {normal_closing_stop:.0f} ms")
    
    # Interrupted movements stop time (forced stop during movement)
    if 'opening_interrupted' in interrupted_analysis['statistics']:
        interrupted_opening = interrupted_analysis['statistics']['opening_interrupted']
        print(f"\nInterrupted OPENING movements:")
        print(f"  Avg time to forced stop: {interrupted_opening['avg_stop_delay_ms']:.0f} ms")
        print(f"  Avg overrun after stop:  {interrupted_opening['avg_overrun_rad']:.3f} rad")
        print(f"  Max overrun after stop:  {interrupted_opening['max_overrun_rad']:.3f} rad")
    
    if 'closing_interrupted' in interrupted_analysis['statistics']:
        interrupted_closing = interrupted_analysis['statistics']['closing_interrupted']
        print(f"\nInterrupted CLOSING movements:")
        print(f"  Avg time to forced stop: {interrupted_closing['avg_stop_delay_ms']:.0f} ms")
        print(f"  Avg overrun after stop:  {interrupted_closing['avg_overrun_rad']:.3f} rad")
        print(f"  Max overrun after stop:  {interrupted_closing['max_overrun_rad']:.3f} rad")
    
    print("\n### Key Observations ###\n")
    
    # Calculate differences if both datasets have data
    observations = []
    
    if 'opening_interrupted' in interrupted_analysis['statistics']:
        opening_stop_delay = interrupted_opening['avg_stop_delay_ms']
        observations.append(f"• Opening stop delay when interrupted: {opening_stop_delay:.0f} ms")
        observations.append(f"• Opening typically overruns by {interrupted_opening['avg_overrun_rad']:.3f} rad after stop command")
    
    if 'closing_interrupted' in interrupted_analysis['statistics']:
        closing_stop_delay = interrupted_closing['avg_stop_delay_ms']
        observations.append(f"• Closing stop delay when interrupted: {closing_stop_delay:.0f} ms")
        
        if 'opening_interrupted' in interrupted_analysis['statistics']:
            diff = opening_stop_delay - closing_stop_delay
            if diff > 0:
                observations.append(f"• Closing stops {diff:.0f} ms faster than opening when interrupted")
            else:
                observations.append(f"• Opening stops {-diff:.0f} ms faster than closing when interrupted")
    
    for obs in observations:
        print(obs)
    
    print("\n" + "=" * 70)
    print("ANALYSIS COMPLETE")
    print("=" * 70)


if __name__ == '__main__':
    main()