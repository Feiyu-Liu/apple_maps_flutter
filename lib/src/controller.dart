// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

/// Controller for a single AppleMap instance running on the host platform.
class AppleMapController {
  AppleMapController._(
    this.channel,
    CameraPosition initialCameraPosition,
    this._appleMapState,
  ) {
    channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<AppleMapController> init(
    int id,
    CameraPosition initialCameraPosition,
    _AppleMapState appleMapState,
  ) async {
    final MethodChannel channel =
        MethodChannel('apple_maps_plugin.luisthein.de/apple_maps_$id');
    // await channel.invokeMethod<void>('map#waitForMap');
    return AppleMapController._(
      channel,
      initialCameraPosition,
      appleMapState,
    );
  }

  @visibleForTesting
  final MethodChannel channel;

  final _AppleMapState _appleMapState;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'camera#onMoveStarted':
        _appleMapState.widget.onCameraMoveStarted?.call();
        break;
      case 'camera#onMove':
        _appleMapState.widget.onCameraMove?.call(
          CameraPosition.fromMap(call.arguments['position'])!,
        );
        break;
      case 'camera#onIdle':
        _appleMapState.widget.onCameraIdle?.call();
        break;
      case 'annotation#onTap':
        _appleMapState.onAnnotationTap(call.arguments['annotationId']);
        break;
      case 'polyline#onTap':
        _appleMapState.onPolylineTap(call.arguments['polylineId']);
        break;
      case 'polygon#onTap':
        _appleMapState.onPolygonTap(call.arguments['polygonId']);
        break;
      case 'circle#onTap':
        _appleMapState.onCircleTap(call.arguments['circleId']);
        break;
      case 'annotation#onDragEnd':
        _appleMapState.onAnnotationDragEnd(call.arguments['annotationId'],
            LatLng._fromJson(call.arguments['position'])!);
        break;
      case 'infoWindow#onTap':
        _appleMapState.onInfoWindowTap(call.arguments['annotationId']);
        break;
      case 'annotation#onZIndexChanged':
        _appleMapState.onAnnotationZIndexChanged(
            call.arguments['annotationId'], call.arguments['zIndex']);
        break;
      case 'map#onTap':
        _appleMapState.onTap(LatLng._fromJson(call.arguments['position'])!);
        break;
      case 'map#onLongPress':
        _appleMapState
            .onLongPress(LatLng._fromJson(call.arguments['position'])!);
        break;
      case 'poi#onSelected':
        _appleMapState.onPOISelected(call.arguments);
        break;
      case 'location#onChanged':
        _appleMapState.onLocationChanged(call.arguments);
        break;
      case 'location#onError':
        _appleMapState.onLocationError(call.arguments);
        break;
      case 'location#onTrackingModeChanged':
        _appleMapState.onUserTrackingModeChanged(call.arguments);
        break;
      default:
        throw MissingPluginException();
    }
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMapOptions(Map<String, dynamic> optionsUpdate) async {
    await channel.invokeMethod<void>(
      'map#update',
      <String, dynamic>{
        'options': optionsUpdate,
      },
    );
  }

  /// Updates annotation configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateAnnotations(_AnnotationUpdates annotationUpdates) async {
    await channel.invokeMethod<void>(
      'annotations#update',
      annotationUpdates._toMap(),
    );
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolylines(_PolylineUpdates polylineUpdates) async {
    await channel.invokeMethod<void>(
      'polylines#update',
      polylineUpdates._toMap(),
    );
  }

  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolygons(_PolygonUpdates polygonUpdates) async {
    await channel.invokeMethod<void>(
      'polygons#update',
      polygonUpdates._toMap(),
    );
  }

  /// Updates circle configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateCircles(_CircleUpdates circleUpdates) async {
    await channel.invokeMethod<void>(
      'circles#update',
      circleUpdates._toMap(),
    );
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    await channel.invokeMethod<void>('camera#animate', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  /// Programmatically show the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  Future<void> showMarkerInfoWindow(AnnotationId annotationId) {
    return channel.invokeMethod<void>('annotations#showInfoWindow',
        <String, String>{'annotationId': annotationId.value});
  }

  /// Programmatically hide the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  Future<void> hideMarkerInfoWindow(AnnotationId annotationId) {
    return channel.invokeMethod<void>('annotations#hideInfoWindow',
        <String, String>{'annotationId': annotationId.value});
  }

  /// Returns `true` when the [InfoWindow] is showing, `false` otherwise.
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  Future<bool?> isMarkerInfoWindowShown(AnnotationId annotationId) {
    return channel.invokeMethod<bool>('annotations#isInfoWindowShown',
        <String, String>{'annotationId': annotationId.value});
  }

  /// Changes the map camera position without animating the transition.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    await channel.invokeMethod<void>('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  /// Returns the current zoomLevel.
  Future<double?> getZoomLevel() async {
    return channel.invokeMethod<double>('camera#getZoomLevel');
  }

  /// Return [LatLngBounds] defining the region that is visible in a map.
  Future<LatLngBounds> getVisibleRegion() async {
    final Map<String, dynamic>? latLngBounds =
        await channel.invokeMapMethod<String, dynamic>('map#getVisibleRegion');
    final LatLng southwest = LatLng._fromJson(latLngBounds?['southwest'])!;
    final LatLng northeast = LatLng._fromJson(latLngBounds?['northeast'])!;

    return LatLngBounds(northeast: northeast, southwest: southwest);
  }

  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  Future<Offset?> getScreenCoordinate(LatLng latLng) async {
    final point = await channel
        .invokeMapMethod<String, dynamic>('camera#convert', <String, dynamic>{
      'annotation': [latLng.latitude, latLng.longitude]
    });
    if (point != null && !point.containsKey('point')) {
      return null;
    }
    final doubles = List<double>.from(point?['point']);
    return Offset(doubles.first, doubles.last);
  }

  /// Returns the image bytes of the map
  Future<Uint8List?> takeSnapshot(
      [SnapshotOptions snapshotOptions = const SnapshotOptions()]) {
    return channel.invokeMethod<Uint8List>(
        'map#takeSnapshot', snapshotOptions._toMap());
  }

  // MARK: - Route Calculation Methods

  /// Calculate a route between two points.
  ///
  /// Returns a [RouteResult] containing the route coordinates, distance, and expected travel time.
  ///
  /// * [origin]: The starting point of the route
  /// * [destination]: The ending point of the route
  /// * [transportType]: The type of transport (automobile, walking, transit, any)
  ///
  /// Example:
  /// ```dart
  /// final route = await controller.calculateRoute(
  ///   origin: LatLng(37.7749, -122.4194),
  ///   destination: LatLng(34.0522, -118.2437),
  ///   transportType: RouteTransportType.automobile,
  /// );
  ///
  /// print('Distance: ${route.formatDistance()}');
  /// print('Duration: ${route.formatDuration()}');
  ///
  /// // Draw the route on the map
  /// final polyline = Polyline(
  ///   polylineId: PolylineId('route'),
  ///   points: route.coordinates,
  ///   color: Colors.blue,
  ///   width: 5,
  /// );
  /// ```
  ///
  /// Throws an exception if:
  /// * The coordinates are invalid
  /// * No route can be found
  /// * Network connection fails
  /// * The service is unavailable
  Future<RouteResult> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    RouteTransportType transportType = RouteTransportType.automobile,
  }) async {
    final dynamic result = await channel.invokeMethod(
      'route#calculate',
      <String, dynamic>{
        'originLat': origin.latitude,
        'originLng': origin.longitude,
        'destLat': destination.latitude,
        'destLng': destination.longitude,
        'transportType': transportType.toValue(),
      },
    );

    if (result == null) {
      throw Exception('Failed to calculate route');
    }

    return RouteResult.fromMap(result as Map);
  }

  /// Calculate multiple alternate routes between two points.
  ///
  /// Returns a list of [RouteResult] objects representing different route options.
  ///
  /// * [origin]: The starting point of the route
  /// * [destination]: The ending point of the route
  /// * [transportType]: The type of transport (automobile, walking, transit, any)
  ///
  /// Example:
  /// ```dart
  /// final routes = await controller.calculateAlternateRoutes(
  ///   origin: LatLng(37.7749, -122.4194),
  ///   destination: LatLng(34.0522, -118.2437),
  /// );
  ///
  /// for (var i = 0; i < routes.length; i++) {
  ///   print('Route ${i + 1}: ${routes[i].formatDistance()}, ${routes[i].formatDuration()}');
  /// }
  /// ```
  Future<List<RouteResult>> calculateAlternateRoutes({
    required LatLng origin,
    required LatLng destination,
    RouteTransportType transportType = RouteTransportType.automobile,
  }) async {
    final dynamic results = await channel.invokeMethod(
      'route#calculateAlternate',
      <String, dynamic>{
        'originLat': origin.latitude,
        'originLng': origin.longitude,
        'destLat': destination.latitude,
        'destLng': destination.longitude,
        'transportType': transportType.toValue(),
      },
    );

    if (results == null) {
      throw Exception('Failed to calculate alternate routes');
    }

    return (results as List)
        .map((result) => RouteResult.fromMap(result as Map))
        .toList();
  }

  /// Calculate the estimated time of arrival (ETA) between two points.
  ///
  /// Returns a map containing:
  /// * `distance`: Distance in meters
  /// * `expectedTravelTime`: Time in seconds
  /// * `transportType`: Transport type used
  ///
  /// This is faster than [calculateRoute] as it doesn't include the full route coordinates.
  ///
  /// * [origin]: The starting point
  /// * [destination]: The ending point
  /// * [transportType]: The type of transport
  ///
  /// Example:
  /// ```dart
  /// final eta = await controller.calculateETA(
  ///   origin: LatLng(37.7749, -122.4194),
  ///   destination: LatLng(34.0522, -118.2437),
  /// );
  ///
  /// print('Distance: ${eta['distance'] / 1000} km');
  /// print('Time: ${eta['expectedTravelTime'] / 60} minutes');
  /// ```
  Future<Map<String, dynamic>> calculateETA({
    required LatLng origin,
    required LatLng destination,
    RouteTransportType transportType = RouteTransportType.automobile,
  }) async {
    final dynamic result = await channel.invokeMethod(
      'route#calculateETA',
      <String, dynamic>{
        'originLat': origin.latitude,
        'originLng': origin.longitude,
        'destLat': destination.latitude,
        'destLng': destination.longitude,
        'transportType': transportType.toValue(),
      },
    );

    if (result == null) {
      throw Exception('Failed to calculate ETA');
    }

    return Map<String, dynamic>.from(result as Map);
  }

  // MARK: - POI and Map Configuration Methods (iOS 16+)

  /// Updates the map configuration (iOS 16+).
  ///
  /// This replaces the deprecated [mapType] property with the new
  /// [MapConfigurationOptions] system.
  ///
  /// Example:
  /// ```dart
  /// await controller.updateMapConfiguration(
  ///   MapConfigurationOptions.standard(
  ///     emphasisStyle: StandardMapEmphasisStyle.muted,
  ///   ),
  /// );
  /// ```
  Future<void> updateMapConfiguration(
    MapConfigurationOptions configuration,
  ) async {
    await channel.invokeMethod<void>(
      'map#updateConfiguration',
      configuration.toMap(),
    );
  }

  /// Updates the selectable map features (iOS 16+).
  ///
  /// Controls which types of map features (POIs, boundaries, physical features)
  /// can be selected by the user.
  ///
  /// Example:
  /// ```dart
  /// await controller.updateSelectableFeatures(
  ///   MapFeatureOptions(
  ///     pointsOfInterest: true,
  ///     territorialBoundaries: false,
  ///     physicalFeatures: false,
  ///   ),
  /// );
  /// ```
  Future<void> updateSelectableFeatures(
    MapFeatureOptions features,
  ) async {
    await channel.invokeMethod<void>(
      'map#updateSelectableFeatures',
      <String, dynamic>{
        'features': features.toMap(),
      },
    );
  }

  // MARK: - Camera Constraints Methods (iOS 13+)

  /// Sets the camera boundary that limits panning (iOS 13+).
  ///
  /// [boundary] The boundary to apply, or [CameraBoundary.unbounded] to remove.
  /// [animated] Whether to animate the transition to the boundary.
  ///
  /// This method has no effect on iOS versions prior to 13.0.
  ///
  /// Example:
  /// ```dart
  /// // Restrict to San Francisco Bay Area
  /// await controller.setCameraBoundary(
  ///   CameraBoundary.fromBounds(
  ///     LatLngBounds(
  ///       southwest: LatLng(37.4, -122.5),
  ///       northeast: LatLng(37.8, -122.0),
  ///     ),
  ///   ),
  /// );
  ///
  /// // Remove restriction
  /// await controller.setCameraBoundary(CameraBoundary.unbounded);
  /// ```
  Future<void> setCameraBoundary(
    CameraBoundary boundary, {
    bool animated = true,
  }) async {
    await channel.invokeMethod<void>('camera#setBoundary', <String, dynamic>{
      'boundary': boundary._toJson(),
      'animated': animated,
    });
  }

  /// Sets the camera zoom range that limits zooming (iOS 13+).
  ///
  /// [zoomRange] The zoom range to apply, or [CameraZoomRange.unbounded] to remove.
  /// [animated] Whether to animate the transition to the range.
  ///
  /// This method has no effect on iOS versions prior to 13.0.
  ///
  /// Example:
  /// ```dart
  /// // Limit zoom from city level (1km) to region level (50km)
  /// await controller.setCameraZoomRange(
  ///   CameraZoomRange(
  ///     minCenterCoordinateDistance: 1000,
  ///     maxCenterCoordinateDistance: 50000,
  ///   ),
  /// );
  ///
  /// // Remove restriction
  /// await controller.setCameraZoomRange(CameraZoomRange.unbounded);
  /// ```
  Future<void> setCameraZoomRange(
    CameraZoomRange zoomRange, {
    bool animated = true,
  }) async {
    await channel.invokeMethod<void>('camera#setZoomRange', <String, dynamic>{
      'zoomRange': zoomRange._toJson(),
      'animated': animated,
    });
  }
}
