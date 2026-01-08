// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

/// The position of the map "camera", the view point from which the world is
/// shown in the map view. Aggregates the camera's [target] geographical
/// location, its [zoom] level, [pitch] angle, and [heading].
class CameraPosition {
  const CameraPosition({
    required this.target,
    this.heading = 0.0,
    this.pitch = 0.0,
    this.zoom = 0,
  });

  /// The camera's bearing in degrees, measured clockwise from north.
  ///
  /// A bearing of 0.0, the default, means the camera points north.
  /// A bearing of 90.0 means the camera points east.
  final double heading;

  /// The geographical location that the camera is pointing at.
  final LatLng target;

  // In degrees where 0 is looking straight down. Pitch may be clamped to an appropriate value.
  final double pitch;

  /// The zoom level of the camera.
  ///
  /// A zoom of 0.0, the default, means the screen width of the world is 256.
  /// Adding 1.0 to the zoom level doubles the screen width of the map. So at
  /// zoom level 3.0, the screen width of the world is 2³x256=2048.
  ///
  /// Larger zoom levels thus means the camera is placed closer to the surface
  /// of the Earth, revealing more detail in a narrower geographical region.
  ///
  /// The supported zoom level range depends on the map data and device. Values
  /// beyond the supported range are allowed, but on applying them to a map they
  /// will be silently clamped to the supported range.
  final double zoom;

  dynamic _toMap() => <String, dynamic>{
        'target': target._toJson(),
        'heading': heading,
        'pitch': pitch,
        'zoom': zoom,
      };

  @visibleForTesting
  static CameraPosition? fromMap(dynamic json) {
    if (json == null) {
      return null;
    }
    return CameraPosition(
      heading: json['heading'],
      target: LatLng._fromJson(json['target'])!,
      pitch: json['pitch'],
      zoom: json['zoom'],
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final CameraPosition typedOther = other;
    return heading == typedOther.heading &&
        target == typedOther.target &&
        pitch == typedOther.pitch &&
        zoom == typedOther.zoom;
  }

  @override
  int get hashCode => Object.hash(heading, target, pitch, zoom);

  @override
  String toString() =>
      'CameraPosition(bearing: $heading, target: $target, tilt: $pitch, zoom: $zoom)';
}

/// Defines a camera move, supporting absolute moves as well as moves relative
/// the current position.
class CameraUpdate {
  CameraUpdate._(this._json);

  /// Returns a camera update that moves the camera to the specified position.
  static CameraUpdate newCameraPosition(CameraPosition cameraPosition) {
    return CameraUpdate._(
      <dynamic>['newCameraPosition', cameraPosition._toMap()],
    );
  }

  /// Returns a camera update that moves the camera target to the specified
  /// geographical location.
  static CameraUpdate newLatLng(LatLng latLng) {
    return CameraUpdate._(<dynamic>['newLatLng', latLng._toJson()]);
  }

  /// Returns a camera update that moves the camera target to the specified
  /// geographical location and zoom level.
  static CameraUpdate newLatLngZoom(LatLng latLng, double zoom) {
    return CameraUpdate._(
      <dynamic>['newLatLngZoom', latLng._toJson(), zoom],
    );
  }

  /// Returns a camera update that transforms the camera so that the specified
  /// geographical bounding box is centered in the map view at the greatest
  /// possible zoom level. A non-zero [padding] insets the bounding box from the
  /// map view's edges. The camera's new tilt and bearing will both be 0.0.
  static CameraUpdate newLatLngBounds(LatLngBounds bounds, double padding) {
    return CameraUpdate._(<dynamic>[
      'newLatLngBounds',
      bounds._toJson(),
      padding,
    ]);
  }

  /// Returns a camera update that modifies the camera zoom level by the
  /// specified amount. The optional [focus] is a screen point whose underlying
  /// geographical location should be invariant, if possible, by the movement.
  static CameraUpdate zoomBy(double amount, [Offset? focus]) {
    if (focus == null) {
      return CameraUpdate._(<dynamic>['zoomBy', amount]);
    } else {
      return CameraUpdate._(<dynamic>[
        'zoomBy',
        amount,
        <double>[focus.dx, focus.dy],
      ]);
    }
  }

  /// Returns a camera update that zooms the camera in, bringing the camera
  /// closer to the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(1.0)`.
  static CameraUpdate zoomIn() {
    return CameraUpdate._(<dynamic>['zoomIn']);
  }

  /// Returns a camera update that zooms the camera out, bringing the camera
  /// further away from the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(-1.0)`.
  static CameraUpdate zoomOut() {
    return CameraUpdate._(<dynamic>['zoomOut']);
  }

  /// Returns a camera update that sets the camera zoom level.
  static CameraUpdate zoomTo(double zoom) {
    return CameraUpdate._(<dynamic>['zoomTo', zoom]);
  }

  final dynamic _json;

  dynamic _toJson() => _json;
}

/// A coordinate region on the map.
///
/// Represents a rectangular area defined by a center point and spans in
/// latitude and longitude directions.
class CameraRegion {
  const CameraRegion({
    required this.center,
    required this.latitudeDelta,
    required this.longitudeDelta,
  });

  /// The center point of the region.
  final LatLng center;

  /// The latitude span (in degrees) from the center to the region's edge.
  final double latitudeDelta;

  /// The longitude span (in degrees) from the center to the region's edge.
  final double longitudeDelta;

  dynamic _toJson() => {
        'center': center._toJson(),
        'latitudeDelta': latitudeDelta,
        'longitudeDelta': longitudeDelta,
      };

  static CameraRegion fromMap(dynamic json) {
    final region = json as Map;
    return CameraRegion(
      center: LatLng._fromJson(region['center'])!,
      latitudeDelta: region['latitudeDelta'] as double,
      longitudeDelta: region['longitudeDelta'] as double,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final CameraRegion typedOther = other as CameraRegion;
    return center == typedOther.center &&
        latitudeDelta == typedOther.latitudeDelta &&
        longitudeDelta == typedOther.longitudeDelta;
  }

  @override
  int get hashCode => Object.hash(center, latitudeDelta, longitudeDelta);

  @override
  String toString() =>
      'CameraRegion(center: $center, latitudeDelta: $latitudeDelta, longitudeDelta: $longitudeDelta)';
}

/// A boundary that limits the area the user can pan to (iOS 13+).
///
/// When set, the user cannot pan the map outside the specified region.
/// This is ignored on iOS versions prior to 13.0.
class CameraBoundary {
  /// Creates a camera boundary from a geographical bounding box.
  ///
  /// The [bounds] define the southwest and northeast corners of the allowable area.
  const CameraBoundary.fromBounds(LatLngBounds bounds)
      : _type = 'bounds',
        _bounds = bounds,
        _regionCenter = null,
        _regionLatitudeDelta = null,
        _regionLongitudeDelta = null;

  /// Creates a camera boundary from a coordinate region.
  ///
  /// The [center] and deltas define the allowable area.
  const CameraBoundary.fromRegion({
    required LatLng center,
    required double latitudeDelta,
    required double longitudeDelta,
  })  : _type = 'region',
        _bounds = null,
        _regionCenter = center,
        _regionLatitudeDelta = latitudeDelta,
        _regionLongitudeDelta = longitudeDelta;

  /// An unbounded camera (no restrictions).
  static const CameraBoundary unbounded = CameraBoundary._unbounded();

  const CameraBoundary._unbounded()
      : _type = 'unbounded',
        _bounds = null,
        _regionCenter = null,
        _regionLatitudeDelta = null,
        _regionLongitudeDelta = null;

  final String _type;
  final LatLngBounds? _bounds;
  final LatLng? _regionCenter;
  final double? _regionLatitudeDelta;
  final double? _regionLongitudeDelta;

  /// Returns the CameraRegion if this boundary was created with fromRegion
  CameraRegion? get region {
    if (_type != 'region') return null;
    if (_regionCenter == null) return null;
    return CameraRegion(
      center: _regionCenter!,
      latitudeDelta: _regionLatitudeDelta!,
      longitudeDelta: _regionLongitudeDelta!,
    );
  }

  dynamic _toJson() {
    if (_type == 'unbounded') return null;
    if (_type == 'bounds') return ['bounds', _bounds!._toJson()];
    return ['region', region!._toJson()];
  }

  @visibleForTesting
  static CameraBoundary? fromMap(dynamic json) {
    if (json == null) return CameraBoundary.unbounded;
    final type = json[0] as String;
    if (type == 'bounds') {
      return CameraBoundary.fromBounds(LatLngBounds.fromList(json[1])!);
    }
    final region = json[1] as Map;
    return CameraBoundary.fromRegion(
      center: LatLng._fromJson(region['center'])!,
      latitudeDelta: region['latitudeDelta'] as double,
      longitudeDelta: region['longitudeDelta'] as double,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final CameraBoundary typedOther = other as CameraBoundary;
    return _type == typedOther._type &&
        _bounds == typedOther._bounds &&
        _regionCenter == typedOther._regionCenter &&
        _regionLatitudeDelta == typedOther._regionLatitudeDelta &&
        _regionLongitudeDelta == typedOther._regionLongitudeDelta;
  }

  @override
  int get hashCode => Object.hash(_type, _bounds, _regionCenter, _regionLatitudeDelta, _regionLongitudeDelta);

  @override
  String toString() {
    if (_type == 'unbounded') return 'CameraBoundary.unbounded';
    if (_type == 'bounds') return 'CameraBoundary.fromBounds($_bounds)';
    return 'CameraBoundary.fromRegion($region)';
  }
}

/// Defines the zoom range limits for the map camera (iOS 13+).
///
/// This restricts how close or far the user can zoom.
/// This is ignored on iOS versions prior to 13.0.
class CameraZoomRange {
  /// Creates a zoom range with both minimum and maximum zoom levels.
  ///
  /// [minCenterCoordinateDistance]: The minimum distance from the camera
  /// to the map center (in meters). Smaller values = more zoomed in.
  ///
  /// [maxCenterCoordinateDistance]: The maximum distance from the camera
  /// to the map center (in meters). Larger values = more zoomed out.
  const CameraZoomRange({
    required double minCenterCoordinateDistance,
    required double maxCenterCoordinateDistance,
  })  : assert(minCenterCoordinateDistance <= maxCenterCoordinateDistance),
        _minDistance = minCenterCoordinateDistance,
        _maxDistance = maxCenterCoordinateDistance;

  /// An unbounded zoom range (no restrictions).
  static const CameraZoomRange unbounded = CameraZoomRange._unbounded();

  const CameraZoomRange._unbounded()
      : _minDistance = null,
        _maxDistance = null;

  final double? _minDistance;
  final double? _maxDistance;

  dynamic _toJson() {
    if (_minDistance == null && _maxDistance == null) return null;
    return [_minDistance, _maxDistance];
  }

  @visibleForTesting
  static CameraZoomRange fromMap(dynamic json) {
    if (json == null) return CameraZoomRange.unbounded;
    return CameraZoomRange(
      minCenterCoordinateDistance: json[0] as double,
      maxCenterCoordinateDistance: json[1] as double,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final CameraZoomRange typedOther = other as CameraZoomRange;
    return _minDistance == typedOther._minDistance &&
        _maxDistance == typedOther._maxDistance;
  }

  @override
  int get hashCode => Object.hash(_minDistance, _maxDistance);

  @override
  String toString() =>
      'CameraZoomRange(minDistance: $_minDistance, maxDistance: $_maxDistance)';
}
