// Copyright 2024 The apple_maps_flutter authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of apple_maps_flutter;

/// 路线计算结果
class RouteResult {
  /// 路线距离（米）
  final double distance;

  /// 预计行驶时间（秒）
  final double expectedTravelTime;

  /// 路线坐标点列表
  final List<LatLng> coordinates;

  /// 导航步骤列表（可选）
  final List<RouteStep>? steps;

  /// 路线名称（可选）
  final String? name;

  /// 交通方式
  final String transportType;

  const RouteResult({
    required this.distance,
    required this.expectedTravelTime,
    required this.coordinates,
    this.steps,
    this.name,
    required this.transportType,
  });

  /// 从 Map 创建 RouteResult
  factory RouteResult.fromMap(Map<dynamic, dynamic> map) {
    return RouteResult(
      distance: (map['distance'] as num).toDouble(),
      expectedTravelTime: (map['expectedTravelTime'] as num).toDouble(),
      coordinates: (map['coordinates'] as List).map((coord) {
        final coordMap = coord as Map;
        return LatLng(
          (coordMap['latitude'] as num).toDouble(),
          (coordMap['longitude'] as num).toDouble(),
        );
      }).toList(),
      steps: map['steps'] != null
          ? (map['steps'] as List)
              .map((step) => RouteStep.fromMap(step as Map))
              .toList()
          : null,
      name: map['name'] as String?,
      transportType: map['transportType'] as String? ?? 'automobile',
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'distance': distance,
      'expectedTravelTime': expectedTravelTime,
      'coordinates': coordinates
          .map((coord) => {
                'latitude': coord.latitude,
                'longitude': coord.longitude,
              })
          .toList(),
      if (steps != null) 'steps': steps!.map((step) => step.toMap()).toList(),
      if (name != null) 'name': name,
      'transportType': transportType,
    };
  }

  /// 获取路线距离（公里）
  double get distanceKm => distance / 1000;

  /// 获取路线距离（英里）
  double get distanceMiles => distance / 1609.34;

  /// 获取预计时间（分钟）
  int get durationMinutes => (expectedTravelTime / 60).round();

  /// 获取预计时间（小时）
  double get durationHours => expectedTravelTime / 3600;

  /// 格式化距离字符串
  String formatDistance({bool useMetric = true}) {
    if (useMetric) {
      if (distance < 1000) {
        return '${distance.toStringAsFixed(0)} 米';
      } else {
        return '${distanceKm.toStringAsFixed(1)} 公里';
      }
    } else {
      if (distance < 1609.34) {
        return '${(distance * 3.28084).toStringAsFixed(0)} 英尺';
      } else {
        return '${distanceMiles.toStringAsFixed(1)} 英里';
      }
    }
  }

  /// 格式化时间字符串
  String formatDuration() {
    if (expectedTravelTime < 60) {
      return '${expectedTravelTime.toStringAsFixed(0)} 秒';
    } else if (expectedTravelTime < 3600) {
      return '${durationMinutes} 分钟';
    } else {
      final hours = (expectedTravelTime / 3600).floor();
      final minutes = ((expectedTravelTime % 3600) / 60).round();
      return '$hours 小时 $minutes 分钟';
    }
  }

  @override
  String toString() {
    return 'RouteResult(distance: ${formatDistance()}, duration: ${formatDuration()}, transportType: $transportType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteResult &&
        other.distance == distance &&
        other.expectedTravelTime == expectedTravelTime &&
        other.transportType == transportType;
  }

  @override
  int get hashCode {
    return distance.hashCode ^
        expectedTravelTime.hashCode ^
        transportType.hashCode;
  }
}

/// 路线导航步骤
class RouteStep {
  /// 导航指示文本
  final String instructions;

  /// 该步骤的距离（米）
  final double distance;

  /// 该步骤的坐标点列表（可选）
  final List<LatLng>? coordinates;

  /// 该步骤的交通方式
  final String? transportType;

  const RouteStep({
    required this.instructions,
    required this.distance,
    this.coordinates,
    this.transportType,
  });

  /// 从 Map 创建 RouteStep
  factory RouteStep.fromMap(Map<dynamic, dynamic> map) {
    return RouteStep(
      instructions: map['instructions'] as String? ?? '',
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
      coordinates: map['coordinates'] != null
          ? (map['coordinates'] as List).map((coord) {
              final coordMap = coord as Map;
              return LatLng(
                (coordMap['latitude'] as num).toDouble(),
                (coordMap['longitude'] as num).toDouble(),
              );
            }).toList()
          : null,
      transportType: map['transportType'] as String?,
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'instructions': instructions,
      'distance': distance,
      if (coordinates != null)
        'coordinates': coordinates!
            .map((coord) => {
                  'latitude': coord.latitude,
                  'longitude': coord.longitude,
                })
            .toList(),
      if (transportType != null) 'transportType': transportType,
    };
  }

  /// 获取步骤距离（公里）
  double get distanceKm => distance / 1000;

  /// 格式化距离字符串
  String formatDistance({bool useMetric = true}) {
    if (useMetric) {
      if (distance < 1000) {
        return '${distance.toStringAsFixed(0)} 米';
      } else {
        return '${distanceKm.toStringAsFixed(1)} 公里';
      }
    } else {
      final distanceMiles = distance / 1609.34;
      if (distance < 1609.34) {
        return '${(distance * 3.28084).toStringAsFixed(0)} 英尺';
      } else {
        return '${distanceMiles.toStringAsFixed(1)} 英里';
      }
    }
  }

  @override
  String toString() {
    return 'RouteStep(instructions: $instructions, distance: ${formatDistance()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteStep &&
        other.instructions == instructions &&
        other.distance == distance;
  }

  @override
  int get hashCode {
    return instructions.hashCode ^ distance.hashCode;
  }
}

/// 交通方式枚举
enum RouteTransportType {
  /// 驾车
  automobile,

  /// 步行
  walking,

  /// 骑行
  cycling,

  /// 公共交通
  transit,

  /// 任意方式
  any;

  /// 转换为字符串
  String toValue() {
    switch (this) {
      case RouteTransportType.automobile:
        return 'automobile';
      case RouteTransportType.walking:
        return 'walking';
      case RouteTransportType.cycling:
        return 'cycling';
      case RouteTransportType.transit:
        return 'transit';
      case RouteTransportType.any:
        return 'any';
    }
  }

  /// 从字符串创建
  static RouteTransportType fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'automobile':
      case 'driving':
        return RouteTransportType.automobile;
      case 'walking':
        return RouteTransportType.walking;
      case 'cycling':
      case 'bicycle':
        return RouteTransportType.cycling;
      case 'transit':
        return RouteTransportType.transit;
      case 'any':
        return RouteTransportType.any;
      default:
        return RouteTransportType.automobile;
    }
  }

  /// 获取显示名称
  String get displayName {
    switch (this) {
      case RouteTransportType.automobile:
        return '驾车';
      case RouteTransportType.walking:
        return '步行';
      case RouteTransportType.cycling:
        return '骑行';
      case RouteTransportType.transit:
        return '公交';
      case RouteTransportType.any:
        return '任意';
    }
  }
}
