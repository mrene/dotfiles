"""Visualization functions for bed frame analysis."""

from typing import List, Dict, Optional
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D


def plot_pitch_with_events(
    sensor_df: pd.DataFrame,
    ha_events: List[Dict],
    analysis_results: Optional[Dict] = None,
    figsize: tuple = (14, 8)
) -> plt.Figure:
    """
    Create main visualization with pitch data, events, and analysis results.
    
    Args:
        sensor_df: DataFrame with sensor data
        ha_events: List of HA events
        analysis_results: Optional analysis results from analyze_all_events
        figsize: Figure size tuple
        
    Returns:
        Matplotlib figure object
    """
    fig, ax = plt.subplots(figsize=figsize)
    
    # Plot pitch data
    ax.plot(sensor_df['sensor_timestamp'], sensor_df['pitch'], 
            'b-', linewidth=1.5, alpha=0.8, label='Pitch')
    
    # Add event markers
    for event in ha_events:
        add_event_markers(ax, event, sensor_df)
    
    # Add stop markers if analysis results provided
    if analysis_results and 'results' in analysis_results:
        add_stop_markers(ax, analysis_results['results'])
    
    # Labels and formatting
    ax.set_xlabel('Time (UTC)', fontsize=12)
    ax.set_ylabel('Pitch (radians)', fontsize=12)
    
    # Title with config info if available
    if analysis_results and 'config' in analysis_results:
        config = analysis_results['config']
        title = (f'Bed Frame Pitch - Movement Start and Stop Detection\n'
                f'(Movement threshold: {config.movement_threshold:.3f} rad/s, '
                f'Start threshold: {config.start_movement_threshold:.3f} rad)')
    else:
        title = 'Bed Frame Pitch with Home Assistant Events'
    
    ax.set_title(title, fontsize=14)
    ax.grid(True, alpha=0.3)
    plt.xticks(rotation=45)
    
    # Create legend
    create_legend(ax)
    
    plt.tight_layout()
    return fig


def add_event_markers(
    ax: plt.Axes,
    event: Dict,
    sensor_df: pd.DataFrame
) -> None:
    """
    Add vertical lines and labels for HA events.
    
    Args:
        ax: Matplotlib axes object
        event: HA event dictionary
        sensor_df: DataFrame with sensor data
    """
    color = 'green' if event['state'] == 'opening' else 'red'
    
    # Add vertical line
    ax.axvline(x=event['timestamp'], color=color, linestyle='--',
              linewidth=2, alpha=0.7)
    
    # Find pitch at event time
    time_diff = (sensor_df['sensor_timestamp'] - event['timestamp']).abs()
    closest_idx = time_diff.idxmin()
    pitch_at_event = sensor_df.loc[closest_idx, 'pitch']
    
    # Add text label
    ax.text(event['timestamp'], pitch_at_event + 0.05,
           event['state'].capitalize(),
           rotation=90, verticalalignment='bottom',
           color=color, fontsize=10, fontweight='bold')


def add_stop_markers(ax: plt.Axes, results: List[Dict]) -> None:
    """
    Add markers for movement stop points.
    
    Args:
        ax: Matplotlib axes object
        results: List of analysis results
    """
    for result in results:
        # Determine marker style and color
        if result['event_state'] == 'opening':
            marker = 'g^' if result['pitch_change'] > 0 else 'gv'
            edge_color = 'darkgreen'
        else:
            marker = 'rv' if result['pitch_change'] < 0 else 'r^'
            edge_color = 'darkred'
        
        # Plot stop point
        ax.plot(result['stop_time'], result['stop_pitch'], marker,
               markersize=12, markeredgecolor=edge_color, markeredgewidth=2)
        
        # Add annotation
        annotation_text = (f"Start: {result['start_delay_ms']:.0f}ms\n"
                          f"Stop: {result['stop_delay_ms']:.0f}ms\n"
                          f"Δ: {result['pitch_change']:.3f} rad")
        
        y_offset = 10 if result['pitch_change'] > 0 else -30
        
        ax.annotate(annotation_text,
                   xy=(result['stop_time'], result['stop_pitch']),
                   xytext=(10, y_offset),
                   textcoords='offset points',
                   fontsize=8, color=edge_color,
                   bbox=dict(boxstyle='round,pad=0.3', 
                            facecolor='white', alpha=0.7),
                   arrowprops=dict(arrowstyle='->', 
                                  color=edge_color, alpha=0.5))


def create_legend(ax: plt.Axes) -> None:
    """
    Create a custom legend for the plot.
    
    Args:
        ax: Matplotlib axes object
    """
    legend_elements = [
        Line2D([0], [0], color='blue', linewidth=2, label='Pitch'),
        Line2D([0], [0], color='green', linewidth=2, linestyle='--', 
               label='Opening Command'),
        Line2D([0], [0], color='red', linewidth=2, linestyle='--', 
               label='Closing Command'),
        Line2D([0], [0], marker='^', color='w', markerfacecolor='g', 
               markersize=10, markeredgecolor='darkgreen', markeredgewidth=2, 
               label='Stop Point (up)'),
        Line2D([0], [0], marker='v', color='w', markerfacecolor='r', 
               markersize=10, markeredgecolor='darkred', markeredgewidth=2, 
               label='Stop Point (down)')
    ]
    ax.legend(handles=legend_elements, loc='upper right')


def plot_velocity_profile(
    event: Dict,
    sensor_df: pd.DataFrame,
    window_seconds: float = 20.0,
    figsize: tuple = (12, 6)
) -> plt.Figure:
    """
    Plot velocity profile for a specific event.
    
    Args:
        event: HA event to analyze
        sensor_df: DataFrame with sensor data
        window_seconds: Time window after event
        figsize: Figure size
        
    Returns:
        Matplotlib figure object
    """
    from movement_detection import calculate_velocity
    
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=figsize, sharex=True)
    
    # Get window data
    window_start = event['timestamp']
    window_end = window_start + pd.Timedelta(seconds=window_seconds)
    window_data = sensor_df[
        (sensor_df['sensor_timestamp'] >= window_start) &
        (sensor_df['sensor_timestamp'] <= window_end)
    ].copy()
    
    if len(window_data) > 10:
        window_data = calculate_velocity(window_data)
        
        # Plot pitch
        ax1.plot(window_data['sensor_timestamp'], window_data['pitch'], 
                'b-', linewidth=1.5)
        ax1.set_ylabel('Pitch (radians)', fontsize=11)
        ax1.grid(True, alpha=0.3)
        ax1.axvline(x=event['timestamp'], color='red', linestyle='--', 
                   alpha=0.7, label=f"{event['state'].capitalize()} command")
        ax1.legend()
        
        # Plot velocity
        ax2.plot(window_data['sensor_timestamp'], 
                window_data['pitch_velocity_abs'], 
                'g-', alpha=0.3, label='Raw velocity')
        ax2.plot(window_data['sensor_timestamp'], 
                window_data['pitch_velocity_smooth'], 
                'r-', linewidth=1.5, label='Smoothed velocity')
        ax2.set_ylabel('Pitch Velocity (rad/s)', fontsize=11)
        ax2.set_xlabel('Time (UTC)', fontsize=11)
        ax2.grid(True, alpha=0.3)
        ax2.legend()
        
        # Title
        event_time = event['timestamp'].strftime('%H:%M:%S')
        fig.suptitle(f"Velocity Profile - {event['state'].capitalize()} at {event_time}", 
                    fontsize=13)
    
    plt.tight_layout()
    return fig