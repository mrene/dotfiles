#!/usr/bin/env python3
"""Test imports from movement_detection module."""

try:
    from movement_detection import MovementConfig
    print("✓ MovementConfig imported successfully")
except ImportError as e:
    print(f"✗ Failed to import MovementConfig: {e}")

try:
    from movement_detection import InterruptedMovementResult
    print("✓ InterruptedMovementResult imported successfully")
except ImportError as e:
    print(f"✗ Failed to import InterruptedMovementResult: {e}")

try:
    from movement_detection import analyze_movement
    print("✓ analyze_movement imported successfully")
except ImportError as e:
    print(f"✗ Failed to import analyze_movement: {e}")

try:
    from movement_detection import analyze_interrupted_movement
    print("✓ analyze_interrupted_movement imported successfully")
except ImportError as e:
    print(f"✗ Failed to import analyze_interrupted_movement: {e}")

print("\nAll imports tested!")