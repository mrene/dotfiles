"""Main analysis module for bed frame sensor data."""

from typing import List, Dict, Optional
import pandas as pd
import numpy as np
from movement_detection import (
    MovementConfig, 
    analyze_movement,
    analyze_interrupted_movement,
    InterruptedMovementResult
)
from ha_client import load_ha_events


def load_sensor_data(csv_path: str) -> pd.DataFrame:
    """
    Load and preprocess CSV sensor data.
    
    Args:
        csv_path: Path to CSV file with sensor data
        
    Returns:
        DataFrame with processed sensor data including sensor_timestamp column
    """
    # Load CSV
    df = pd.read_csv(csv_path)
    
    # Convert sensor_time from nanoseconds to datetime (UTC)
    df['sensor_timestamp'] = pd.to_datetime(df['sensor_time'], unit='ns')
    
    # Sort by sensor timestamp
    df = df.sort_values('sensor_timestamp')
    
    return df


def analyze_event(
    event: Dict,
    sensor_df: pd.DataFrame,
    config: Optional[MovementConfig] = None
) -> Optional[Dict]:
    """
    Analyze a single Home Assistant event for movement delays.
    
    Args:
        event: HA event dictionary with 'timestamp' and 'state' keys
        sensor_df: DataFrame with sensor data
        config: Movement detection configuration (uses defaults if None)
        
    Returns:
        Analysis results dictionary or None if analysis failed
    """
    if config is None:
        config = MovementConfig()
    
    # Analyze movement for this event
    result = analyze_movement(event['timestamp'], sensor_df, config)
    
    if result:
        # Add event information to result
        result['event_timestamp'] = event['timestamp']
        result['event_state'] = event['state']
        result['entity_id'] = event.get('entity_id')
    
    return result


def analyze_all_events(
    events: List[Dict],
    sensor_df: pd.DataFrame,
    config: Optional[MovementConfig] = None
) -> Dict:
    """
    Batch analyze all events and return statistics.
    
    Args:
        events: List of HA events to analyze
        sensor_df: DataFrame with sensor data
        config: Movement detection configuration
        
    Returns:
        Dictionary with analysis results and statistics
    """
    if config is None:
        config = MovementConfig()
    
    results = []
    opening_delays = {'start': [], 'stop': []}
    closing_delays = {'start': [], 'stop': []}
    
    for event in events:
        result = analyze_event(event, sensor_df, config)
        
        if result:
            results.append(result)
            
            # Collect delays by event type
            if event['state'] == 'opening':
                opening_delays['start'].append(result['start_delay_ms'])
                opening_delays['stop'].append(result['stop_delay_ms'])
            elif event['state'] == 'closing':
                closing_delays['start'].append(result['start_delay_ms'])
                closing_delays['stop'].append(result['stop_delay_ms'])
    
    # Calculate statistics
    statistics = {}
    
    if opening_delays['stop']:
        statistics['opening'] = {
            'count': len(opening_delays['stop']),
            'avg_start_delay_ms': np.mean(opening_delays['start']),
            'avg_stop_delay_ms': np.mean(opening_delays['stop']),
            'min_stop_delay_ms': np.min(opening_delays['stop']),
            'max_stop_delay_ms': np.max(opening_delays['stop'])
        }
    
    if closing_delays['stop']:
        statistics['closing'] = {
            'count': len(closing_delays['stop']),
            'avg_start_delay_ms': np.mean(closing_delays['start']),
            'avg_stop_delay_ms': np.mean(closing_delays['stop']),
            'min_stop_delay_ms': np.min(closing_delays['stop']),
            'max_stop_delay_ms': np.max(closing_delays['stop'])
        }
    
    return {
        'results': results,
        'statistics': statistics,
        'config': config
    }


def print_analysis_summary(analysis: Dict) -> None:
    """
    Print a summary of analysis results.
    
    Args:
        analysis: Dictionary from analyze_all_events
    """
    print("Movement Stop Analysis")
    print("=" * 50)
    
    # Print individual results
    for result in analysis['results']:
        state = result['event_state'].capitalize()
        timestamp = result['event_timestamp'].strftime('%H:%M:%S.%f')[:-3]
        
        print(f"\n{state} at {timestamp}")
        print(f"  Movement started after {result['start_delay_ms']:.0f} ms")
        print(f"  Stopped at: {result['stop_pitch']:.3f} rad "
              f"({result['direction']}, Δ={result['pitch_change']:.3f}) "
              f"at {result['stop_time'].strftime('%H:%M:%S.%f')[:-3]}")
        print(f"  Total time to stop: {result['stop_delay_ms']:.0f} ms")
    
    # Print statistics
    print("\n" + "=" * 50)
    print("Summary Statistics")
    print("-" * 50)
    
    stats = analysis['statistics']
    
    if 'opening' in stats:
        opening = stats['opening']
        print(f"Opening commands: {opening['count']}")
        print(f"  Average start delay: {opening['avg_start_delay_ms']:.0f} ms")
        print(f"  Average time to stop: {opening['avg_stop_delay_ms']:.0f} ms")
        print(f"  Min time to stop: {opening['min_stop_delay_ms']:.0f} ms")
        print(f"  Max time to stop: {opening['max_stop_delay_ms']:.0f} ms")
    
    if 'closing' in stats:
        closing = stats['closing']
        print(f"\nClosing commands: {closing['count']}")
        print(f"  Average start delay: {closing['avg_start_delay_ms']:.0f} ms")
        print(f"  Average time to stop: {closing['avg_stop_delay_ms']:.0f} ms")
        print(f"  Min time to stop: {closing['min_stop_delay_ms']:.0f} ms")
        print(f"  Max time to stop: {closing['max_stop_delay_ms']:.0f} ms")


def analyze_interrupted_events(
    events: List[Dict],
    sensor_df: pd.DataFrame,
    config: Optional[MovementConfig] = None
) -> Dict:
    """
    Analyze movement stop delays after stop commands.
    
    This analyzes ALL movements followed by state changes (open/closed),
    measuring the time from the state change to actual movement stop.
    
    Args:
        events: List of ALL HA events (including open/closed states)
        sensor_df: DataFrame with sensor data
        config: Movement detection configuration
        
    Returns:
        Dictionary with movement stop delay results and statistics
    """
    if config is None:
        config = MovementConfig()
    
    results = []
    opening_stop_delays = []
    closing_stop_delays = []
    opening_overruns = []
    closing_overruns = []
    
    # Look for interrupted movement patterns
    for i in range(len(events) - 1):
        curr_event = events[i]
        next_event = events[i + 1]
        
        # Check for movement followed by state change (ALL movements end with a state change)
        # We want to measure stop delay for ALL of these transitions
        if curr_event['state'] in ['opening', 'closing'] and next_event['state'] in ['open', 'closed']:
            # Get the next movement event if it exists
            next_movement_event = None
            if i + 2 < len(events) and events[i + 2]['state'] in ['opening', 'closing']:
                next_movement_event = events[i + 2]
            
            # Analyze this interrupted sequence
            result = analyze_interrupted_movement(
                curr_event, next_event, sensor_df, config, next_movement_event
            )
            
            if result:
                results.append(result)
                
                # Collect statistics
                if result.movement_type == 'opening':
                    opening_stop_delays.append(result.stop_delay_ms)
                    opening_overruns.append(result.overrun_after_stop)
                elif result.movement_type == 'closing':
                    closing_stop_delays.append(result.stop_delay_ms)
                    closing_overruns.append(result.overrun_after_stop)
    
    # Calculate statistics
    statistics = {}
    
    if opening_stop_delays:
        statistics['opening_interrupted'] = {
            'count': len(opening_stop_delays),
            'avg_stop_delay_ms': np.mean(opening_stop_delays),
            'min_stop_delay_ms': np.min(opening_stop_delays),
            'max_stop_delay_ms': np.max(opening_stop_delays),
            'avg_overrun_rad': np.mean(opening_overruns),
            'max_overrun_rad': np.max(np.abs(opening_overruns))
        }
    
    if closing_stop_delays:
        statistics['closing_interrupted'] = {
            'count': len(closing_stop_delays),
            'avg_stop_delay_ms': np.mean(closing_stop_delays),
            'min_stop_delay_ms': np.min(closing_stop_delays),
            'max_stop_delay_ms': np.max(closing_stop_delays),
            'avg_overrun_rad': np.mean(closing_overruns),
            'max_overrun_rad': np.max(np.abs(closing_overruns))
        }
    
    return {
        'results': results,
        'statistics': statistics,
        'config': config
    }


def print_interrupted_analysis_summary(analysis: Dict) -> None:
    """
    Print a summary of interrupted movement analysis.
    
    Args:
        analysis: Dictionary from analyze_interrupted_events
    """
    print("Interrupted Movement Analysis")
    print("=" * 50)
    
    # Print individual results
    for result in analysis['results']:
        movement = result.movement_type.capitalize()
        
        print(f"\n{movement} INTERRUPTED:")
        print(f"  Movement command: {result.movement_command_time.strftime('%H:%M:%S.%f')[:-3]}")
        print(f"  Stop command:     {result.stop_command_time.strftime('%H:%M:%S.%f')[:-3]}")
        print(f"  Command duration: {result.command_duration_s:.3f} seconds")
        print(f"  >>> STOP DELAY:   {result.stop_delay_ms:.0f} ms <<<")
        print(f"  Pitch change:     {result.pitch_change_during_movement:.3f} rad")
        print(f"  Overrun:          {result.overrun_after_stop:.3f} rad")
        
        if result.velocity_at_stop_command:
            print(f"  Velocity at stop: {result.velocity_at_stop_command:.3f} rad/s")
    
    # Print statistics
    print("\n" + "=" * 50)
    print("Summary Statistics")
    print("-" * 50)
    
    stats = analysis['statistics']
    
    if 'opening_interrupted' in stats:
        opening = stats['opening_interrupted']
        print(f"Opening interruptions: {opening['count']}")
        print(f"  Average stop delay:  {opening['avg_stop_delay_ms']:.0f} ms")
        print(f"  Min stop delay:      {opening['min_stop_delay_ms']:.0f} ms")
        print(f"  Max stop delay:      {opening['max_stop_delay_ms']:.0f} ms")
        print(f"  Average overrun:     {opening['avg_overrun_rad']:.3f} rad")
        print(f"  Max overrun:         {opening['max_overrun_rad']:.3f} rad")
    
    if 'closing_interrupted' in stats:
        closing = stats['closing_interrupted']
        print(f"\nClosing interruptions: {closing['count']}")
        print(f"  Average stop delay:  {closing['avg_stop_delay_ms']:.0f} ms")
        print(f"  Min stop delay:      {closing['min_stop_delay_ms']:.0f} ms")
        print(f"  Max stop delay:      {closing['max_stop_delay_ms']:.0f} ms")
        print(f"  Average overrun:     {closing['avg_overrun_rad']:.3f} rad")
        print(f"  Max overrun:         {closing['max_overrun_rad']:.3f} rad")