# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter plugin that provides an **Apple Maps widget** for iOS applications only. The plugin uses Flutter's Platform View mechanism to embed native MKMapView widgets. It was based on `google_maps_flutter` to maintain API compatibility and enable cross-platform implementations.

**Key constraint:** This plugin is **iOS-only**. There is no Android implementation (the Android folder was intentionally removed). For cross-platform map support, use the companion package `platform_maps_flutter` which combines this plugin with `google_maps_flutter`.

## Essential Commands

```bash
# Development
flutter pub get              # Install dependencies
flutter analyze              # Run Dart analyzer (checks for issues)
flutter test                 # Run unit tests
flutter test --coverage      # Run tests with coverage report

# Building
flutter build ios            # Build iOS app
flutter pub publish --dry-run # Validate package before publishing

# Example app
cd example && flutter run    # Run the example application
cd example && flutter build ios --release --no-codesign
```

**CI/CD Pipeline** (GitHub Actions - `.github/workflows/dart.yml`):
- Runs on macOS (required for iOS builds)
- Flutter version: 3.27.3
- Steps: `dart analyze`, `flutter test --coverage`, codecov upload, example build, pub publish dry-run

## Code Architecture

### Part File Pattern

The main library uses Dart's `part` directive to split implementation across multiple files. All parts are declared in `lib/apple_maps_flutter.dart`:

```dart
part 'src/annotation.dart';
part 'src/camera.dart';
part 'src/controller.dart';
part 'src/circle.dart';
part 'src/polygon.dart';
part 'src/polyline.dart';
part 'src/route_result.dart';
// ... etc
```

**Implication:** When working with this codebase, all `part` files share the same library scope. You don't need to import individual part files - they're already available through the main library.

### Platform Bridge Architecture

**Dart Side** (`lib/`):
- `AppleMap` - Main StatefulWidget widget
- `AppleMapController` - API for controlling the map (camera, overlays, routes)
- Model classes: `Annotation`, `Circle`, `Polygon`, `Polyline`, `CameraPosition`, etc.
- Update classes: `AnnotationUpdates`, `CircleUpdates`, etc. (efficient diff-based updates)

**iOS Native Side** (`ios/Classes/`):
- `SwiftAppleMapsFlutterPlugin.swift` - Plugin registration and entry point
- `MapView/FlutterMapView.swift` - Native MKMapView wrapper
- `MapView/AppleMapController.swift` - Native controller implementation (large file ~22K lines)
- `Annotations/` - Marker/pin implementations
- `Overlays/` - Circle, polygon, polyline overlays
- `RouteCalculation/` - Route calculation using MKDirections API

**Communication:**
- Method channels for method calls (Dart → Swift)
- Event channels for streaming events (Swift → Dart)

### Key Implementation Patterns

**Controller Pattern:**
- `AppleMapController` provides the main API for map control
- Methods like `moveCamera()`, `animateCamera()`, `calculateRoute()` communicate with native iOS code via method channels
- Controller is obtained through `AppleMap.onMapCreated` callback

**Update Pattern:**
- Uses update classes (e.g., `AnnotationUpdates`) for efficient batch updates
- Compares existing collections with new collections to compute insert/remove/update sets
- Serialized to JSON for platform communication

**Route Calculation (New Feature - `get_route` branch):**
- Three main APIs: `calculateRoute()` (single route), `calculateAlternateRoutes()` (multiple routes), `calculateETA()` (time/distance only)
- Uses Apple's MKDirections API (network required)
- Supports: automobile, walking, cycling (iOS 17+), transit
- **Note:** Transit routing not available in mainland China; cycling availability varies by region
- See `docs/route_calculation_guide.md` for detailed usage

## iOS Configuration Requirements

When adding this plugin to an iOS app, two Info.plist entries are required:

1. **Embedded Views Preview** (required for Flutter platform views):
   - Key: `io.flutter_embedded_views_preview`
   - Value: `YES`

2. **Location Permission** (if using user location):
   - Key: `NSLocationWhenInUseUsageDescription`
   - Value: Your usage description string

## File Structure Reference

```
lib/
├── apple_maps_flutter.dart    # Main entry (part declarations)
└── src/
    ├── apple_map.dart          # Main map widget
    ├── controller.dart         # Map controller API
    ├── route_result.dart       # Route calculation models
    ├── annotation.dart         # Markers/pins
    ├── circle.dart             # Circle overlays
    ├── polygon.dart            # Polygon overlays
    ├── polyline.dart           # Polyline overlays
    └── camera.dart             # Camera positioning

ios/Classes/
├── SwiftAppleMapsFlutterPlugin.swift
├── MapView/
│   ├── FlutterMapView.swift
│   └── AppleMapController.swift  # Large native controller
├── Annotations/                  # Marker implementations
├── Overlays/                     # Shape overlays
└── RouteCalculation/             # Route calculation

example/                          # Example app demonstrating features
test/                             # Unit tests
docs/                             # Feature documentation
```

## Testing

- Tests are located in `test/` directory
- Use mock controllers from `test/fake_maps_controllers.dart` for testing
- Run `flutter test --coverage` for coverage reports
- CI uploads coverage to Codecov

## Documentation

Key documentation files:
- `README.md` - Basic usage and setup
- `docs/route_calculation_guide.md` - Comprehensive route calculation feature guide (in Chinese)
- `docs/ROUTE_FEATURE_README.md` - Route feature implementation details
- `CHANGELOG.md` - Version history

## Current Development Status

- **Version:** 1.4.0
- **Flutter:** 3.27.1 compatibility (uses `Object.hash` instead of deprecated `ui.hash*`)
- **Active branch:** `get_route` - Contains route calculation feature under active development
- **Status:** Development preview (due to Flutter's embedded views preview status)
