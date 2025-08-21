"""Movement detection algorithms for analyzing sensor data."""

from dataclasses import dataclass
from typing import Optional, Tuple
import pandas as pd
import numpy as np


@dataclass
class MovementConfig:
    """Configuration parameters for movement detection."""
    window_seconds: float = 20.0  # Time window to analyze after event
    movement_threshold: float = 0.005  # rad/s to consider as stopped
    stability_time: float = 0.5  # Seconds of stability to confirm stop
    start_movement_threshold: float = 0.01  # Minimum change to detect start
    velocity_smoothing_window: int = 5  # Window size for velocity smoothing
    

def calculate_velocity(window_data: pd.DataFrame) -> pd.DataFrame:
    """
    Calculate pitch velocity and smoothed velocity from sensor data.
    
    Args:
        window_data: DataFrame with 'pitch' and 'sensor_timestamp' columns
        
    Returns:
        DataFrame with additional velocity columns
    """
    df = window_data.copy()
    df = df.reset_index(drop=True)
    
    # Calculate differences
    df['pitch_diff'] = df['pitch'].diff()
    df['time_diff'] = df['sensor_timestamp'].diff().dt.total_seconds()
    
    # Calculate velocity
    df['pitch_velocity'] = df['pitch_diff'] / df['time_diff']
    df['pitch_velocity_abs'] = df['pitch_velocity'].abs()
    
    # Smooth the velocity to reduce noise
    df['pitch_velocity_smooth'] = df['pitch_velocity_abs'].rolling(
        window=5, center=True
    ).mean()
    
    return df


def detect_movement_start(
    window_data: pd.DataFrame, 
    initial_pitch: float,
    threshold: float = 0.01
) -> Optional[Tuple[int, pd.Timestamp]]:
    """
    Detect when movement starts after a command.
    
    Args:
        window_data: DataFrame with sensor data
        initial_pitch: Initial pitch value at command time
        threshold: Minimum pitch change to detect movement
        
    Returns:
        Tuple of (index, timestamp) when movement started, or None
    """
    for i in range(1, len(window_data)):
        pitch_change = abs(window_data.iloc[i]['pitch'] - initial_pitch)
        if pitch_change > threshold:
            return i, window_data.iloc[i]['sensor_timestamp']
    
    return None


def detect_movement_stop(
    window_data: pd.DataFrame,
    start_idx: int,
    movement_threshold: float = 0.005,
    stability_time: float = 0.5,
    sampling_rate: float = 20.0
) -> Optional[Tuple[int, pd.Timestamp, float]]:
    """
    Detect when movement stops after it has started.
    
    Args:
        window_data: DataFrame with sensor data and velocity columns
        start_idx: Index where movement started
        movement_threshold: Velocity threshold for "stopped" (rad/s)
        stability_time: Required time of stability (seconds)
        sampling_rate: Assumed sampling rate (Hz)
        
    Returns:
        Tuple of (index, timestamp, pitch_value) when stopped, or None
    """
    stability_samples = int(stability_time * sampling_rate)
    
    # Start looking after movement began, with some buffer
    for i in range(start_idx + 5, len(window_data) - stability_samples):
        # Check if velocity stays below threshold for stability period
        future_window = window_data.iloc[i:i + stability_samples]
        
        if len(future_window) > 0:
            smooth_velocities = future_window['pitch_velocity_smooth'].dropna()
            if len(smooth_velocities) > 0 and all(smooth_velocities < movement_threshold):
                # Movement has stopped
                return (
                    i,
                    window_data.iloc[i]['sensor_timestamp'],
                    window_data.iloc[i]['pitch']
                )
    
    return None


def analyze_movement(
    event_timestamp: pd.Timestamp,
    sensor_df: pd.DataFrame,
    config: MovementConfig
) -> Optional[dict]:
    """
    Analyze movement for a single event.
    
    Args:
        event_timestamp: Timestamp of the HA event
        sensor_df: Full sensor DataFrame
        config: Movement detection configuration
        
    Returns:
        Dictionary with analysis results or None if insufficient data
    """
    # Define analysis window
    window_start = event_timestamp
    window_end = window_start + pd.Timedelta(seconds=config.window_seconds)
    
    # Get data within window
    window_data = sensor_df[
        (sensor_df['sensor_timestamp'] >= window_start) &
        (sensor_df['sensor_timestamp'] <= window_end)
    ].copy()
    
    if len(window_data) < 10:  # Need enough data points
        return None
    
    # Calculate velocities
    window_data = calculate_velocity(window_data)
    
    initial_pitch = window_data.iloc[0]['pitch']
    
    # Detect movement start
    start_result = detect_movement_start(
        window_data, initial_pitch, config.start_movement_threshold
    )
    
    if not start_result:
        return None
    
    start_idx, start_time = start_result
    
    # Detect movement stop
    stop_result = detect_movement_stop(
        window_data, start_idx, 
        config.movement_threshold, 
        config.stability_time
    )
    
    if not stop_result:
        return None
    
    stop_idx, stop_time, stop_pitch = stop_result
    
    # Calculate delays and changes
    start_delay_ms = (start_time - event_timestamp).total_seconds() * 1000
    stop_delay_ms = (stop_time - event_timestamp).total_seconds() * 1000
    pitch_change = stop_pitch - initial_pitch
    
    return {
        'start_time': start_time,
        'start_delay_ms': start_delay_ms,
        'stop_time': stop_time,
        'stop_delay_ms': stop_delay_ms,
        'initial_pitch': initial_pitch,
        'stop_pitch': stop_pitch,
        'pitch_change': pitch_change,
        'direction': 'up' if pitch_change > 0 else 'down'
    }