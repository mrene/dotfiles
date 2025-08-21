"""Home Assistant API client for fetching logbook events."""

from typing import List, Dict, Optional
import requests
import pandas as pd
from datetime import datetime


class HAClient:
    """Client for interacting with Home Assistant API."""
    
    def __init__(self, base_url: str, token: str):
        """
        Initialize the Home Assistant client.
        
        Args:
            base_url: Base URL of Home Assistant (e.g., 'http://tvpi:8123')
            token: Bearer token for authentication
        """
        self.base_url = base_url.rstrip('/')
        self.headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
    
    def fetch_logbook_entries(
        self, 
        entity_id: str, 
        start_time: pd.Timestamp,
        hours_before: float = 1.0
    ) -> List[Dict]:
        """
        Fetch logbook entries for a specific entity.
        
        Args:
            entity_id: Entity ID to fetch events for
            start_time: Start time for fetching events
            hours_before: Hours before start_time to begin fetching
            
        Returns:
            List of logbook entries
        """
        # Calculate API start time
        api_start = start_time - pd.Timedelta(hours=hours_before)
        api_start_str = api_start.strftime('%Y-%m-%dT%H:%M:%S.000Z')
        
        # Construct URL and params
        url = f'{self.base_url}/api/logbook/{api_start_str}'
        params = {'entity': entity_id}
        
        # Make request
        response = requests.get(url, headers=self.headers, params=params)
        response.raise_for_status()
        
        return response.json()
    
    @staticmethod
    def parse_events(
        logbook_data: List[Dict], 
        event_types: Optional[List[str]] = None
    ) -> List[Dict]:
        """
        Parse specific event types from logbook data.
        
        Args:
            logbook_data: Raw logbook data from API
            event_types: List of event states to extract (if None, includes all states)
            
        Returns:
            List of parsed events with timestamps and states
        """
        events = []
        
        for entry in logbook_data:
            # Include all states if event_types is None, otherwise filter
            if 'state' in entry and (event_types is None or entry.get('state') in event_types):
                # Parse timestamp and ensure UTC
                timestamp = pd.to_datetime(entry['when'])
                
                # Handle timezone
                if timestamp.tz is None:
                    timestamp = timestamp.tz_localize('UTC')
                else:
                    timestamp = timestamp.tz_convert('UTC')
                
                # Remove timezone info for consistent comparison
                timestamp = timestamp.tz_localize(None)
                
                events.append({
                    'timestamp': timestamp,
                    'state': entry['state'],
                    'entity_id': entry.get('entity_id'),
                    'name': entry.get('name')
                })
        
        return events
    
    @staticmethod
    def filter_events_by_timerange(
        events: List[Dict],
        start_time: pd.Timestamp,
        end_time: pd.Timestamp
    ) -> List[Dict]:
        """
        Filter events to those within a specific time range.
        
        Args:
            events: List of parsed events
            start_time: Start of time range
            end_time: End of time range
            
        Returns:
            Filtered list of events
        """
        return [
            event for event in events
            if start_time <= event['timestamp'] <= end_time
        ]


def load_ha_events(
    sensor_df: pd.DataFrame,
    entity_id: str,
    ha_url: str = 'http://tvpi:8123',
    token_path: str = '/run/secrets/home-assistant/token',
    token: Optional[str] = None,
    event_types: Optional[List[str]] = None
) -> List[Dict]:
    """
    Load Home Assistant events corresponding to sensor data timeframe.
    
    Args:
        sensor_df: DataFrame with sensor data (must have 'sensor_timestamp' column)
        entity_id: Home Assistant entity ID to fetch events for
        ha_url: Home Assistant base URL
        token_path: Path to token file (used if token not provided)
        token: Bearer token (if None, will read from token_path)
        event_types: List of event states to include (if None, includes all states)
        
    Returns:
        List of HA events within sensor data timeframe
    """
    # Get token
    if token is None:
        with open(token_path, 'r') as f:
            token = f.read().strip()
    
    # Initialize client
    client = HAClient(ha_url, token)
    
    # Get sensor time range
    sensor_start = sensor_df['sensor_timestamp'].min()
    sensor_end = sensor_df['sensor_timestamp'].max()
    
    # Fetch logbook entries
    logbook_data = client.fetch_logbook_entries(entity_id, sensor_start)
    
    # Parse events (defaults to all event types if not specified)
    events = client.parse_events(logbook_data, event_types)
    
    # Filter to sensor timeframe
    events = client.filter_events_by_timerange(events, sensor_start, sensor_end)
    
    return events