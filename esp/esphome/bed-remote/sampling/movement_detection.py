"""Movement detection algorithms for analyzing sensor data."""

from dataclasses import dataclass
from typing import Optional, Tuple, Dict
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


@dataclass 
class InterruptedMovementResult:
    """Results from analyzing an interrupted movement."""
    movement_command_time: pd.Timestamp
    stop_command_time: pd.Timestamp
    movement_type: str  # 'opening' or 'closing'
    
    # Timing measurements
    command_duration_s: float  # Time between movement and stop commands
    start_delay_ms: float  # Time from command to actual movement start
    stop_delay_ms: float  # Time from stop command to actual stop
    actual_start_time: pd.Timestamp
    actual_stop_time: pd.Timestamp
    
    # Position measurements  
    pitch_at_start: float
    pitch_at_stop_command: float
    pitch_at_actual_stop: float
    pitch_change_during_movement: float
    overrun_after_stop: float  # Additional movement after stop command
    
    # Optional velocity at stop command
    velocity_at_stop_command: Optional[float] = None
    

def calculate_velocity(window_data: pd.DataFrame) -> pd.DataFrame:
    """
    Calculate pitch velocity, acceleration, and smoothed values from sensor data.
    
    Velocity is signed: positive for opening (pitch increasing), 
    negative for closing (pitch decreasing).
    Acceleration is the derivative of velocity.
    
    Args:
        window_data: DataFrame with 'pitch' and 'sensor_timestamp' columns
        
    Returns:
        DataFrame with additional velocity and acceleration columns
    """
    df = window_data.copy()
    df = df.reset_index(drop=True)
    
    # Calculate differences
    df['pitch_diff'] = df['pitch'].diff()
    df['time_diff'] = df['sensor_timestamp'].diff().dt.total_seconds()
    
    # Calculate velocity (signed: positive=opening, negative=closing)
    df['pitch_velocity'] = df['pitch_diff'] / df['time_diff']
    df['pitch_velocity_abs'] = df['pitch_velocity'].abs()
    
    # Smooth the absolute velocity to reduce noise (for stop detection)
    # Use backward-looking window to avoid time offset
    df['pitch_velocity_smooth'] = df['pitch_velocity_abs'].rolling(
        window=5, center=False, min_periods=1
    ).mean()
    
    # No smoothing on signed velocity - use raw values
    df['pitch_velocity_signed_smooth'] = df['pitch_velocity']  # Keep the name for compatibility
    
    # Calculate acceleration (derivative of velocity)
    df['velocity_diff'] = df['pitch_velocity'].diff()
    df['pitch_acceleration'] = df['velocity_diff'] / df['time_diff']
    
    # No smoothing on acceleration - use raw derivative
    df['pitch_acceleration_smooth'] = df['pitch_acceleration']  # Keep the name for compatibility
    
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


def detect_stop_after_command(
    stop_command_time: pd.Timestamp,
    sensor_df: pd.DataFrame,
    config: MovementConfig,
    next_movement_time: Optional[pd.Timestamp] = None
) -> Optional[Tuple[pd.Timestamp, float, float]]:
    """
    Detect when movement stops after a stop command.
    
    This handles both actual stops (velocity goes to zero) and direction
    reversals (movement continues in opposite direction).
    
    Args:
        stop_command_time: Time when stop command was issued
        sensor_df: Full sensor DataFrame 
        config: Movement detection configuration
        next_movement_time: Time of next movement command (if any) to detect reversals
        
    Returns:
        Tuple of (stop_time, stop_pitch, overrun) or None
    """
    # Get window after stop command
    window_start = stop_command_time
    # If there's a next movement, limit window to that time
    if next_movement_time:
        window_end = min(
            window_start + pd.Timedelta(seconds=5),
            next_movement_time + pd.Timedelta(seconds=0.5)
        )
    else:
        window_end = window_start + pd.Timedelta(seconds=5)  # 5 second window
    
    window_data = sensor_df[
        (sensor_df['sensor_timestamp'] >= window_start) &
        (sensor_df['sensor_timestamp'] <= window_end)
    ].copy()
    
    if len(window_data) < 10:
        return None
    
    # Calculate velocities including signed velocity for direction detection
    window_data = calculate_velocity(window_data)
    
    pitch_at_stop_command = window_data.iloc[0]['pitch']
    initial_velocity_sign = None
    
    # Determine initial movement direction from first few samples
    for i in range(2, min(10, len(window_data))):
        if not pd.isna(window_data.iloc[i]['pitch_velocity']):
            vel = window_data.iloc[i]['pitch_velocity']
            if abs(vel) > 0.002:  # Significant velocity
                initial_velocity_sign = 1 if vel > 0 else -1
                break
    
    # Find when movement stops or reverses
    stability_samples = int(config.stability_time * 20)  # Assuming ~20Hz
    
    for i in range(5, len(window_data) - 2):  # -2 to allow checking next sample
        current_vel = window_data.iloc[i]['pitch_velocity']
        
        # Check for direction reversal
        if initial_velocity_sign and not pd.isna(current_vel):
            if abs(current_vel) > 0.002:  # Significant velocity
                current_sign = 1 if current_vel > 0 else -1
                if current_sign != initial_velocity_sign:
                    # Direction reversed - movement effectively stopped here
                    stop_time = window_data.iloc[i]['sensor_timestamp']
                    stop_pitch = window_data.iloc[i]['pitch']
                    overrun = stop_pitch - pitch_at_stop_command
                    return stop_time, stop_pitch, overrun
        
        # Check for actual stop (velocity near zero)
        if i <= len(window_data) - stability_samples:
            future_window = window_data.iloc[i:i + stability_samples]
            
            if len(future_window) > 0:
                smooth_velocities = future_window['pitch_velocity_smooth'].dropna()
                if len(smooth_velocities) > 0 and all(smooth_velocities < config.movement_threshold):
                    # Movement stopped
                    stop_time = window_data.iloc[i]['sensor_timestamp']
                    stop_pitch = window_data.iloc[i]['pitch']
                    overrun = stop_pitch - pitch_at_stop_command
                    
                    return stop_time, stop_pitch, overrun
    
    return None


def analyze_interrupted_movement(
    movement_event: Dict,
    stop_event: Dict,
    sensor_df: pd.DataFrame,
    config: Optional[MovementConfig] = None,
    next_movement_event: Optional[Dict] = None
) -> Optional[InterruptedMovementResult]:
    """
    Analyze an interrupted movement sequence.
    
    Args:
        movement_event: HA event for movement command (opening/closing)
        stop_event: HA event for stop command (open/closed)
        sensor_df: Full sensor DataFrame
        config: Movement detection configuration
        next_movement_event: Optional next movement event to detect reversals
        
    Returns:
        InterruptedMovementResult or None if analysis failed
    """
    if config is None:
        config = MovementConfig()
    
    movement_time = movement_event['timestamp']
    stop_command_time = stop_event['timestamp']
    movement_type = movement_event['state']
    
    # Get pitch at movement command
    idx_start = sensor_df['sensor_timestamp'].sub(movement_time).abs().idxmin()
    pitch_at_start = sensor_df.loc[idx_start, 'pitch']
    
    # Detect when movement becomes visible in sensor data
    window_for_start = sensor_df[
        (sensor_df['sensor_timestamp'] >= movement_time) &
        (sensor_df['sensor_timestamp'] <= movement_time + pd.Timedelta(seconds=2))
    ].copy()
    
    # Movement command time IS the start time
    actual_start_time = movement_time
    movement_detected_time = movement_time  # Default if no movement detected
    start_delay_ms = 0.0
    
    if len(window_for_start) > 5:
        # Calculate velocity to detect when movement actually starts
        window_for_start = calculate_velocity(window_for_start)
        
        # Find when velocity becomes non-zero (movement actually starts)
        velocity_threshold = 0.002  # rad/s - very small threshold to catch start
        
        for i in range(1, len(window_for_start)):
            # Check velocity magnitude
            vel = abs(window_for_start.iloc[i].get('pitch_velocity', 0))
            if vel > velocity_threshold:
                movement_detected_time = window_for_start.iloc[i]['sensor_timestamp']
                start_delay_ms = (movement_detected_time - movement_time).total_seconds() * 1000
                break
    
    # Get pitch at stop command
    idx_stop_cmd = sensor_df['sensor_timestamp'].sub(stop_command_time).abs().idxmin()
    pitch_at_stop_command = sensor_df.loc[idx_stop_cmd, 'pitch']
    
    # Detect actual stop, passing next movement time if available
    next_movement_time = next_movement_event['timestamp'] if next_movement_event else None
    stop_result = detect_stop_after_command(stop_command_time, sensor_df, config, next_movement_time)
    
    if not stop_result:
        return None
    
    actual_stop_time, pitch_at_actual_stop, overrun = stop_result
    
    # Calculate velocity at stop command (optional)
    window_around_stop = sensor_df[
        (sensor_df['sensor_timestamp'] >= stop_command_time - pd.Timedelta(seconds=0.5)) &
        (sensor_df['sensor_timestamp'] <= stop_command_time + pd.Timedelta(seconds=0.5))
    ].copy()
    
    velocity_at_stop = None
    if len(window_around_stop) > 5:
        window_around_stop = calculate_velocity(window_around_stop)
        idx_closest = window_around_stop['sensor_timestamp'].sub(stop_command_time).abs().idxmin()
        if idx_closest in window_around_stop.index:
            velocity_at_stop = window_around_stop.loc[idx_closest, 'pitch_velocity_abs']
    
    return InterruptedMovementResult(
        movement_command_time=movement_time,
        stop_command_time=stop_command_time,
        movement_type=movement_type,
        command_duration_s=(stop_command_time - movement_time).total_seconds(),
        start_delay_ms=start_delay_ms,
        stop_delay_ms=(actual_stop_time - stop_command_time).total_seconds() * 1000,
        actual_start_time=actual_start_time,
        actual_stop_time=actual_stop_time,
        pitch_at_start=pitch_at_start,
        pitch_at_stop_command=pitch_at_stop_command,
        pitch_at_actual_stop=pitch_at_actual_stop,
        pitch_change_during_movement=pitch_at_stop_command - pitch_at_start,
        overrun_after_stop=overrun,
        velocity_at_stop_command=velocity_at_stop
    )