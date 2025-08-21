#!/usr/bin/env python3
"""Quick analysis of partial-movements.csv to understand the data."""

import pandas as pd
import numpy as np

# Load the data
df = pd.read_csv('partial-movements.csv')
df['sensor_timestamp'] = pd.to_datetime(df['sensor_time'], unit='ns')

print(f"Loaded {len(df)} sensor readings")
print(f"Time range: {df['sensor_timestamp'].min()} to {df['sensor_timestamp'].max()}")
print(f"Duration: {df['sensor_timestamp'].max() - df['sensor_timestamp'].min()}")
print(f"Pitch range: {df['pitch'].min():.3f} to {df['pitch'].max():.3f} radians")

# Show pitch statistics
print(f"\nPitch statistics:")
print(f"  Mean: {df['pitch'].mean():.3f}")
print(f"  Std: {df['pitch'].std():.3f}")
print(f"  Min: {df['pitch'].min():.3f}")
print(f"  Max: {df['pitch'].max():.3f}")