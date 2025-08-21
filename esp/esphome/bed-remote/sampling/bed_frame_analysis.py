"""Main analysis module for bed frame sensor data."""

from typing import List, Dict, Optional
import pandas as pd
import numpy as np
from movement_detection import MovementConfig, analyze_movement
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