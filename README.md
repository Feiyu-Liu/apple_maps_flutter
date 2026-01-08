# apple_maps_flutter

[![codecov](https://codecov.io/gh/LuisThein/apple_maps_flutter/branch/master/graph/badge.svg)](https://codecov.io/gh/LuisThein/apple_maps_flutter)

A Flutter plugin that provides an Apple Maps widget.

The plugin relies on Flutter's mechanism for embedding Android and iOS views. As that mechanism is currently in a developers preview, this plugin should also be considered a developers preview.

This plugin was based on the `google_maps_flutter` plugin. Instead of reinventing the wheel it also uses the Flutter implementation of the `google_maps_flutter` plugin. This was also done to simplify the process of combining the `google_maps_flutter` plugin with `apple_maps_flutter` to create a cross platform implementation for Android/iOS called `flutter_platform_maps`.

# Screenshots

|                                     Example 1                                     |                                     Example 2                                     |
| :-------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------: |
| ![Example 1](https://luisthein.de/apple-maps-plugin-images/example_img01-min.png) | ![Example 2](https://luisthein.de/apple-maps-plugin-images/example_img02-min.png) |

# iOS

To use this plugin on iOS you need to opt-in for the embedded views preview by adding a boolean property to the app's Info.plist file, with the key `io.flutter.embedded_views_preview` and the value `YES`. You will also have to add the key `Privacy - Location When In Use Usage Description` with the value of your usage description.

# Android

There is no Android implementation, but there is a package combining apple_maps_flutter and the google_maps_flutter plugin to have the typical map implementations for Android/iOS called platform_maps_flutter.

## Sample Usage

```dart
class AppleMapsExample extends StatelessWidget {
  AppleMapController mapController;

  void _onMapCreated(AppleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Container(
            child: AppleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(0.0, 0.0),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    mapController.moveCamera(
                      CameraUpdate.newCameraPosition(
                        const CameraPosition(
                          heading: 270.0,
                          target: LatLng(51.5160895, -0.1294527),
                          pitch: 30.0,
                          zoom: 17,
                        ),
                      ),
                    );
                  },
                  child: const Text('newCameraPosition'),
                ),
                FlatButton(
                  onPressed: () {
                    mapController.moveCamera(
                      CameraUpdate.newLatLngZoom(
                        const LatLng(37.4231613, -122.087159),
                        11.0,
                      ),
                    );
                  },
                  child: const Text('newLatLngZoom'),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    mapController.moveCamera(
                      CameraUpdate.zoomIn(),
                    );
                  },
                  child: const Text('zoomIn'),
                ),
                FlatButton(
                  onPressed: () {
                    mapController.moveCamera(
                      CameraUpdate.zoomOut(),
                    );
                  },
                  child: const Text('zoomOut'),
                ),
                FlatButton(
                  onPressed: () {
                    mapController.moveCamera(
                      CameraUpdate.zoomTo(16.0),
                    );
                  },
                  child: const Text('zoomTo'),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
```

## POI Features (iOS 16+)

The plugin now supports Point of Interest (POI) selection and the new iOS 16+ map configuration system. This replaces the deprecated `mapType` property.

```dart
class POIExample extends StatefulWidget {
  @override
  State<POIExample> createState() => _POIExampleState();
}

class _POIExampleState extends State<POIExample> {
  AppleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return AppleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(37.7749, -122.4194), // San Francisco
        zoom: 14,
      ),

      // iOS 16+ Map Configuration
      mapConfigurationOptions: MapConfigurationOptions.standard(
        emphasisStyle: StandardMapEmphasisStyle.defaultValue,
      ),

      // Enable POI selection
      selectableMapFeatures: const MapFeatureOptions(
        pointsOfInterest: true,
        territorialBoundaries: false,
        physicalFeatures: false,
      ),

      // Handle POI selection
      onPOISelected: (POIData poi) {
        print('Selected POI: ${poi.name}');
        print('Category: ${poi.category}');
        print('Address: ${poi.address}');
        print('Coordinate: ${poi.coordinate}');
      },

      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }
}
```

### Map Configuration Options

Available map types (iOS 16+):
- `MapConfigurationType.standard` - Standard map with roads and landmarks
- `MapConfigurationType.hybrid` - Satellite imagery with road overlays
- `MapConfigurationType.imagery` - Satellite imagery only

Emphasis styles for standard maps:
- `StandardMapEmphasisStyle.defaultValue` - Default emphasis
- `StandardMapEmphasisStyle.muted` - Muted emphasis

### Dynamic Configuration Updates

You can update the map configuration dynamically using the controller:

```dart
// Change to hybrid map
_mapController?.updateMapConfiguration(
  MapConfigurationOptions.hybrid(),
);

// Update selectable features
_mapController?.updateSelectableFeatures(
  const MapFeatureOptions(
    pointsOfInterest: true,
    territorialBoundaries: true,
    physicalFeatures: false,
  ),
);
```

### POI Categories

The plugin includes 90+ POI categories such as:
- Restaurants, Cafes, Bars
- Hotels, Shopping, Banks
- Parks, Museums, Theaters
- Hospitals, Pharmacies, Police stations
- And many more...

See `POICategory` enum for the complete list.

### Backward Compatibility

For iOS 14-15, the plugin automatically falls back to the deprecated `mapType` property. The new POI features are only available on iOS 16+.

## Camera Constraints (iOS 13+)

The plugin supports camera boundaries and zoom range constraints to limit user interaction with the map.

```dart
class CameraConstraintsExample extends StatefulWidget {
  @override
  State<CameraConstraintsExample> createState() => _CameraConstraintsExampleState();
}

class _CameraConstraintsExampleState extends State<CameraConstraintsExample> {
  AppleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return AppleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(37.7749, -122.4194), // San Francisco
        zoom: 12,
      ),

      // Restrict panning to San Francisco Bay Area
      cameraBoundary: CameraBoundary.fromBounds(
        const LatLngBounds(
          southwest: LatLng(37.4, -122.5),
          northeast: LatLng(37.8, -122.0),
        ),
      ),

      // Limit zoom level
      cameraZoomRange: const CameraZoomRange(
        minCenterCoordinateDistance: 1000,  // 1km minimum (city level)
        maxCenterCoordinateDistance: 50000, // 50km maximum (region level)
      ),

      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }
}
```

### Camera Boundary Options

You can create camera boundaries in two ways:

**Using LatLngBounds** (recommended for rectangular areas):
```dart
cameraBoundary: CameraBoundary.fromBounds(
  LatLngBounds(
    southwest: LatLng(37.4, -122.5),
    northeast: LatLng(37.8, -122.0),
  ),
)
```

**Using CoordinateRegion** (center + deltas):
```dart
cameraBoundary: CameraBoundary.fromRegion(
  center: LatLng(37.7749, -122.4194),
  latitudeDelta: 0.2,
  longitudeDelta: 0.2,
)
```

**Remove boundary**:
```dart
cameraBoundary: CameraBoundary.unbounded
```

### Dynamic Constraint Updates

Update constraints dynamically using the controller:

```dart
// Set boundary with animation
await _mapController?.setCameraBoundary(
  CameraBoundary.fromBounds(
    LatLngBounds(
      southwest: LatLng(37.4, -122.5),
      northeast: LatLng(37.8, -122.0),
    ),
  ),
  animated: true,
);

// Remove boundary
await _mapController?.setCameraBoundary(CameraBoundary.unbounded);

// Set zoom range
await _mapController?.setCameraZoomRange(
  const CameraZoomRange(
    minCenterCoordinateDistance: 1000,
    maxCenterCoordinateDistance: 50000,
  ),
);

// Remove zoom range
await _mapController?.setCameraZoomRange(CameraZoomRange.unbounded);
```

## User Location Tracking

The plugin provides comprehensive user location tracking with detailed location data and error handling.

```dart
class LocationTrackingExample extends StatefulWidget {
  @override
  State<LocationTrackingExample> createState() => _LocationTrackingExampleState();
}

class _LocationTrackingExampleState extends State<LocationTrackingExample> {
  LocationData? _currentLocation;

  @override
  Widget build(BuildContext context) {
    return AppleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(37.7749, -122.4194),
        zoom: 14,
      ),

      // Enable location tracking
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      trackingMode: TrackingMode.follow,

      // Receive location updates
      onLocationChanged: (LocationData location) {
        setState(() {
          _currentLocation = location;
        });
        print('Location: ${location.latitude}, ${location.longitude}');
        print('Accuracy: ${location.accuracy}m');
        print('Altitude: ${location.altitude}m');
        print('Speed: ${location.speed}m/s');
        print('Heading: ${location.heading}°');
      },

      // Handle location errors
      onLocationError: (LocationError error) {
        print('Location error: ${error.message}');
        if (error.code == LocationErrorCode.permissionDenied) {
          // Handle permission denied
        }
      },

      // Track mode changes
      onUserTrackingModeChanged: (TrackingMode mode, bool animated) {
        print('Tracking mode changed to: $mode');
      },

      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }
}
```

### LocationData Properties

The `LocationData` class provides comprehensive location information:

- `latitude` / `longitude` - Coordinates in degrees
- `accuracy` - Horizontal accuracy in meters (null if unavailable)
- `altitude` - Altitude in meters above sea level
- `speed` - Speed in meters/second (null if stationary)
- `speedAccuracy` - Speed accuracy in meters/second (null if unavailable)
- `heading` - Heading in degrees relative to true north (0-360°, null if unavailable)
- `timestamp` - Timestamp of the location fix

### Error Handling

The `LocationError` class provides detailed error information:

```dart
onLocationError: (LocationError error) {
  switch (error.code) {
    case LocationErrorCode.permissionDenied:
      // User denied location permission
      break;
    case LocationErrorCode.serviceDisabled:
      // Location services are disabled
      break;
    case LocationErrorCode.timeout:
      // Location request timed out
      break;
    case LocationErrorCode.network:
      // Network-related error
      break;
    default:
      // Unknown error
  }
  print('Error: ${error.message}');
}
```

### Tracking Modes

Available tracking modes:

- `TrackingMode.none` - Don't follow user location
- `TrackingMode.follow` - Follow user location
- `TrackingMode.followWithHeading` - Follow user location and heading

Suggestions and PR's to make this plugin better are always welcome.
