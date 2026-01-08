// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

/// A pair of latitude and longitude coordinates, stored as degrees.
class LatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  /// The latitude is clamped to the inclusive interval from -90.0 to +90.0.
  ///
  /// The longitude is normalized to the half-open interval from -180.0
  /// (inclusive) to +180.0 (exclusive)
  const LatLng(double latitude, double longitude)
      : latitude =
            (latitude < -90.0 ? -90.0 : (90.0 < latitude ? 90.0 : latitude)),
        longitude = (longitude + 180.0) % 360.0 - 180.0;

  /// The latitude in degrees between -90.0 and 90.0, both inclusive.
  final double latitude;

  /// The longitude in degrees between -180.0 (inclusive) and 180.0 (exclusive).
  final double longitude;

  dynamic _toJson() {
    return <double>[latitude, longitude];
  }

  static LatLng? _fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return LatLng(json[0], json[1]);
  }

  @override
  String toString() => '$runtimeType($latitude, $longitude)';

  @override
  bool operator ==(Object o) {
    return o is LatLng && o.latitude == latitude && o.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// A latitude/longitude aligned rectangle.
///
/// The rectangle conceptually includes all points (lat, lng) where
/// * lat ∈ [`southwest.latitude`, `northeast.latitude`]
/// * lng ∈ [`southwest.longitude`, `northeast.longitude`],
///   if `southwest.longitude` ≤ `northeast.longitude`,
/// * lng ∈ [-180, `northeast.longitude`] ∪ [`southwest.longitude`, 180[,
///   if `northeast.longitude` < `southwest.longitude`
class LatLngBounds {
  /// Creates geographical bounding box with the specified corners.
  ///
  /// The latitude of the southwest corner cannot be larger than the
  /// latitude of the northeast corner.
  LatLngBounds({required this.southwest, required this.northeast})
      : assert(southwest.latitude <= northeast.latitude);

  /// The southwest corner of the rectangle.
  final LatLng southwest;

  /// The northeast corner of the rectangle.
  final LatLng northeast;

  /// Returns whether this rectangle contains the given [LatLng].
  bool contains(LatLng point) {
    return _containsLatitude(point.latitude) &&
        _containsLongitude(point.longitude);
  }

  bool _containsLatitude(double lat) {
    return (southwest.latitude <= lat) && (lat <= northeast.latitude);
  }

  bool _containsLongitude(double lng) {
    if (southwest.longitude <= northeast.longitude) {
      return southwest.longitude <= lng && lng <= northeast.longitude;
    } else {
      return southwest.longitude <= lng || lng <= northeast.longitude;
    }
  }

  @visibleForTesting
  static LatLngBounds? fromList(dynamic json) {
    if (json == null) {
      return null;
    }
    return LatLngBounds(
      southwest: LatLng._fromJson(json[0])!,
      northeast: LatLng._fromJson(json[1])!,
    );
  }

  @override
  String toString() {
    return '$runtimeType($southwest, $northeast)';
  }

  @override
  bool operator ==(Object o) {
    return o is LatLngBounds &&
        o.southwest == southwest &&
        o.northeast == northeast;
  }

  /// Converts this object to something serializable in JSON.
  dynamic _toJson() {
    return <dynamic>[southwest._toJson(), northeast._toJson()];
  }

  @override
  int get hashCode => Object.hash(southwest, northeast);
}

/// Error codes for location-related failures.
enum LocationErrorCode {
  /// Permission denied by user.
  permissionDenied,

  /// Location services are disabled.
  serviceDisabled,

  /// Location request timed out.
  timeout,

  /// Network-related error.
  network,

  /// Unknown error.
  unknown,
}

/// Extension for LocationErrorCode enum.
extension LocationErrorCodeExtension on LocationErrorCode {
  /// Converts the enum to a string value.
  String toValue() => name;

  /// Creates a LocationErrorCode from a string value.
  static LocationErrorCode fromValue(String value) {
    return LocationErrorCode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LocationErrorCode.unknown,
    );
  }
}

/// Represents an error that occurred during location tracking.
class LocationError {
  const LocationError({
    required this.code,
    required this.message,
    this.details,
  });

  /// The error code.
  final LocationErrorCode code;

  /// Human-readable error message.
  final String message;

  /// Additional error details, if available.
  final dynamic details;

  static LocationError fromMap(dynamic json) {
    return LocationError(
      code: LocationErrorCodeExtension.fromValue(json['code'] as String),
      message: json['message'] as String,
      details: json['details'],
    );
  }

  @override
  String toString() => 'LocationError($code: $message)';
}

/// Represents a geographical location with metadata.
///
/// Contains coordinates, accuracy, speed, heading, and timestamp information
/// from the device's location services.
class LocationData {
  const LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.speedAccuracy,
    this.heading,
    this.timestamp,
  });

  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees.
  final double longitude;

  /// The estimated horizontal accuracy of the location, in meters.
  ///
  /// A negative value indicates no accuracy data is available.
  final double? accuracy;

  /// The altitude in meters above sea level.
  ///
  /// Null if altitude is not available.
  final double? altitude;

  /// The speed in meters/second.
  ///
  /// Null if speed is not available.
  final double? speed;

  /// The estimated speed accuracy in meters/second.
  ///
  /// Null if speed accuracy is not available.
  final double? speedAccuracy;

  /// The heading in degrees relative to true north.
  ///
  /// Values are in the range [0, 360). Null if heading is not available.
  final double? heading;

  /// The timestamp of the location fix.
  final DateTime? timestamp;

  /// Converts to LatLng for easy map positioning.
  LatLng toLatLng() => LatLng(latitude, longitude);

  dynamic _toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (accuracy != null) 'accuracy': accuracy,
        if (altitude != null) 'altitude': altitude,
        if (speed != null) 'speed': speed,
        if (speedAccuracy != null) 'speedAccuracy': speedAccuracy,
        if (heading != null) 'heading': heading,
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      };

  static LocationData fromMap(dynamic json) {
    return LocationData(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      accuracy: json['accuracy'] as double?,
      altitude: json['altitude'] as double?,
      speed: json['speed'] as double?,
      speedAccuracy: json['speedAccuracy'] as double?,
      heading: json['heading'] as double?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final LocationData typedOther = other as LocationData;
    return latitude == typedOther.latitude &&
        longitude == typedOther.longitude &&
        accuracy == typedOther.accuracy &&
        altitude == typedOther.altitude &&
        speed == typedOther.speed &&
        speedAccuracy == typedOther.speedAccuracy &&
        heading == typedOther.heading &&
        timestamp == typedOther.timestamp;
  }

  @override
  int get hashCode => Object.hash(
    latitude,
    longitude,
    accuracy,
    altitude,
    speed,
    speedAccuracy,
    heading,
    timestamp,
  );

  @override
  String toString() =>
      'LocationData(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
}
