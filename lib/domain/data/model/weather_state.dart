enum WeatherState {
  clear,
  cloudy,
  windy,
  stormy,
  foggy;

  String get displayName {
    switch (this) {
      case WeatherState.clear:
        return 'Clear';
      case WeatherState.cloudy:
        return 'Cloudy';
      case WeatherState.windy:
        return 'Windy';
      case WeatherState.stormy:
        return 'Stormy';
      case WeatherState.foggy:
        return 'Foggy';
    }
  }

  String get emoji {
    switch (this) {
      case WeatherState.clear:
        return '☀️';
      case WeatherState.cloudy:
        return '☁️';
      case WeatherState.windy:
        return '💨';
      case WeatherState.stormy:
        return '⛈️';
      case WeatherState.foggy:
        return '🌫️';
    }
  }
}
