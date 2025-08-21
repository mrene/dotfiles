#!/usr/bin/env python3
"""
Example usage of the refactored bed frame analysis modules.

This script demonstrates how to:
1. Load sensor data from CSV
2. Fetch corresponding Home Assistant events
3. Analyze movement delays for each event
4. Generate visualizations
5. Print summary statistics
"""

import matplotlib.pyplot as plt
from movement_detection import MovementConfig
from ha_client import load_ha_events
from bed_frame_analysis import (
    load_sensor_data,
    analyze_all_events,
    print_analysis_summary
)
from visualization import plot_pitch_with_events, plot_velocity_profile


def main():
    """Run the complete analysis pipeline."""
    
    # Configuration
    CSV_FILE = 'open-close.csv'
    ENTITY_ID = 'cover.bed_remote_head_position'
    HA_URL = 'http://tvpi:8123'
    TOKEN_PATH = '/run/secrets/home-assistant/token'
    
    # Step 1: Load sensor data
    print("Loading sensor data...")
    sensor_df = load_sensor_data(CSV_FILE)
    print(f"Loaded {len(sensor_df)} sensor readings")
    print(f"Time range: {sensor_df['sensor_timestamp'].min()} to "
          f"{sensor_df['sensor_timestamp'].max()}")
    print(f"Pitch range: {sensor_df['pitch'].min():.3f} to "
          f"{sensor_df['pitch'].max():.3f} radians\n")
    
    # Step 2: Load Home Assistant events
    print("Fetching Home Assistant events...")
    ha_events = load_ha_events(
        sensor_df=sensor_df,
        entity_id=ENTITY_ID,
        ha_url=HA_URL,
        token_path=TOKEN_PATH
    )
    print(f"Found {len(ha_events)} events in sensor timeframe")
    for event in ha_events:
        print(f"  {event['timestamp']}: {event['state']}")
    print()
    
    # Step 3: Configure movement detection
    config = MovementConfig(
        window_seconds=20.0,
        movement_threshold=0.005,  # rad/s
        stability_time=0.5,  # seconds
        start_movement_threshold=0.01  # radians
    )
    
    # Step 4: Analyze all events
    print("Analyzing movement patterns...")
    analysis = analyze_all_events(ha_events, sensor_df, config)
    
    # Step 5: Print summary
    print_analysis_summary(analysis)
    
    # Step 6: Create visualizations
    print("\nGenerating visualizations...")
    
    # Main plot with all events and analysis
    fig1 = plot_pitch_with_events(sensor_df, ha_events, analysis)
    plt.savefig('bed_frame_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved main analysis plot to 'bed_frame_analysis.png'")
    
    # Velocity profiles for individual events (optional)
    for i, event in enumerate(ha_events[:2]):  # First 2 events as examples
        fig2 = plot_velocity_profile(event, sensor_df, config.window_seconds)
        filename = f"velocity_profile_{i+1}_{event['state']}.png"
        plt.savefig(filename, dpi=150, bbox_inches='tight')
        print(f"Saved velocity profile to '{filename}'")
    
    # Show plots (optional - comment out for headless operation)
    plt.show()
    
    return analysis


def example_custom_analysis():
    """Example of custom analysis with different parameters."""
    
    # Load data
    sensor_df = load_sensor_data('open-close.csv')
    ha_events = load_ha_events(
        sensor_df=sensor_df,
        entity_id='cover.bed_remote_head_position'
    )
    
    # Try different configurations
    configs = [
        MovementConfig(movement_threshold=0.003, stability_time=0.3),
        MovementConfig(movement_threshold=0.008, stability_time=0.7),
        MovementConfig(start_movement_threshold=0.005)
    ]
    
    print("Comparing different configurations:\n")
    for i, config in enumerate(configs, 1):
        print(f"Configuration {i}:")
        print(f"  Movement threshold: {config.movement_threshold:.3f} rad/s")
        print(f"  Stability time: {config.stability_time:.1f} s")
        print(f"  Start threshold: {config.start_movement_threshold:.3f} rad")
        
        analysis = analyze_all_events(ha_events, sensor_df, config)
        
        if 'opening' in analysis['statistics']:
            stats = analysis['statistics']['opening']
            print(f"  Opening - Avg stop delay: {stats['avg_stop_delay_ms']:.0f} ms")
        
        if 'closing' in analysis['statistics']:
            stats = analysis['statistics']['closing']
            print(f"  Closing - Avg stop delay: {stats['avg_stop_delay_ms']:.0f} ms")
        
        print()


if __name__ == '__main__':
    # Run main analysis
    results = main()
    
    # Optionally run custom analysis
    # print("\n" + "="*60)
    # print("CUSTOM ANALYSIS")
    # print("="*60 + "\n")
    # example_custom_analysis()