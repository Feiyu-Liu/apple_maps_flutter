# Changelog

## 1.6.0

* **NEW: Camera Constraints and Advanced Control (iOS 13+)**
  * Added `CameraBoundary` class to limit map panning area
  * Added `CameraZoomRange` class to restrict zoom levels
  * Added `CameraRegion` class for coordinate region representation
  * Added `AppleMapController.setCameraBoundary()` method
  * Added `AppleMapController.setCameraZoomRange()` method
  * Supports both LatLngBounds and CoordinateRegion boundary creation
* **NEW: User Location Tracking (Complete Implementation)**
  * Added `LocationData` model with comprehensive location information (coordinates, accuracy, altitude, speed, heading, timestamp)
  * Added `LocationError` class and `LocationErrorCode` enum for error handling
  * Added `onLocationChanged` callback to receive real-time location updates
  * Added `onLocationError` callback for location failure handling
  * Added `onUserTrackingModeChanged` callback for tracking mode changes
  * Implemented CLLocationManagerDelegate on native iOS side
* Added camera and location tracking example demonstrating all new features
* Maintains backward compatibility (camera constraints ignored on iOS < 13, location tracking works on all iOS versions)

## 1.5.0

* **NEW: POI (Point of Interest) and Map Features Support (iOS 16+)**
  * Added `MapConfigurationOptions` to use iOS 16+ MKMapConfiguration API
  * Added `MapFeatureOptions` for controlling selectable map features
  * Added `POIData` model with comprehensive POI information
  * Added `POICategory` enum with 90+ POI types
  * Added `onPOISelected` callback to handle POI selection events
  * Added `AppleMapController.updateMapConfiguration()` method
  * Added `AppleMapController.updateSelectableFeatures()` method
  * Replaced deprecated `mapType` with new iOS 16+ configuration system
  * Maintains backward compatibility with iOS 14-15 (falls back to deprecated `mapType`)
* Added POI example demonstrating all new features

## 1.4.0

* Flutter 3.27.1 compatibility, replace `ui.hash*` with `Object.hash*

## 1.3.0

* Animate marker position changes instead of removing and re-adding
* Fix Fatal error: Attempted to read an unowned reference but the object was already deallocated
* Fixed an issue where onCameraMove was not invoked by double-tapping
* Added insetsLayoutMarginsFromSafeArea

## 1.2.0

* Added a `markerAnnotationWithHue()` and `pinAnnotationWithHue()` method to allow custom marker/pin colors

## 1.1.0

* Added Annotation zIndex
* Added posibility to take snapshots of the map

## 1.0.3

* Fixes an issue where mapController.moveCamera would animate the camera transition
* To animate a camera movement, mapController.animateCamera should be used instead

## 1.0.2

* Removed Android folder to fix build failures

## 1.0.1

* Fixes memory leak
* Adds ability to take snapshots of the map
## 1.0.0

Thanks to @jonbhanson
* Adds null safety.
* Refreshes the example app.
* Updates .gitignore and removes files that should not be tracked.

## 0.1.4

* Animate to bounds was added. (Thanks to @nghiashiyi)
* Fixed an issue where the user location was only displayed in `authorizationInUse` status. (Thanks to @zgosalvez)

* minor fixes

## 0.1.3

* Thanks to @maxiundtesa the getter for the current zoomLevel was added
* iOS build failure for Flutter modules was fixed

## 0.1.2+5

* Fixed build failure
* Added anchor param to Annotation
* Added missing comparison of Overlay coordinates, which caused
  Circles, Annotations, Polylines and Ploygons to not update correctly
  on coordinate changes.

## 0.1.2+4

* Added configurable Anchor for infoWindows

## 0.1.2+3

* Fixed the offset of custom markers

## 0.1.2+2

* Fixed the onTap event for Annotation Callouts

## 0.1.2+1

* Added custom annotation icons from byte data
* Fixed scaling of icons from assets => see: https://flutter.dev/docs/development/ui/assets-and-images#declaring-resolution-aware-image-assets

## 0.1.2

* Annotation rework:
   * onTap for InfoWindow added
   * Multiline InfoWindow subtitle support
   * Overall Annotation handling refactored
   * Correct UserTracking Button added

## 0.1.1+2

* Fixed map freezing when setState is being called

## 0.1.1+1

* Fixed Polygon and Circle Tap events.

## 0.1.1

* Added markerAnnotation as selectable annotation type.

## 0.1.0

* Added ability to place circles on the map.

## 0.0.7

* Added ability to place polygons on the map.

## 0.0.6+4

* Fixed build issues

## 0.0.6+3

* Fixes issue #6, location permission is only requested if it's actually used.

## 0.0.6+2

* Converted iOS code to swift 5.

## 0.0.6+1

* Changed annotation initialisation, fixes custom annotation icons not showing up on the map.

## 0.0.6

* Added ability to add padding to the map

## 0.0.5

* Added ability to place polylines.

## 0.0.4

* Fixed error when updating Annotations on map.

## 0.0.3

* Added getter for visible map region.

## 0.0.2

* Added zoomBy functionality.
* Added setter for min and max zoom levels.

## 0.0.1

* Initial release.
