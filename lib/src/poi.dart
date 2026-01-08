// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

/// POI类别枚举，对应MapKit的MKPointOfInterestCategory
///
/// iOS 16+可用
enum POICategory {
  // 主要类别
  airport,
  atm,
  bank,
  beach,
  campground,
  evCharger,
  foodMarket,
  gasStation,
  hospital,
  hotel,
  laundry,
  nightlife,
  park,
  parking,
  pharmacy,
  police,
  postOffice,
  publicTransport,
  restaurant,
  restrooms,
  school,
  stadium,
  store,
  theater,

  // 其他类别
  amusementPark,
  aquarium,
  artGallery,
  bakery,
  bar,
  beautySalon,
  bookStore,
  bowlingAlley,
  busStation,
  cafe,
  carRental,
  casino,
  cemetery,
  cityHall,
  clothingStore,
  conventionCenter,
  courthouse,
  dentist,
  departmentStore,
  electronicsStore,
  fireStation,
  fitnessCenter,
  florist,
  furnitureStore,
  garden,
  gym,
  hardwareStore,
  hinduTemple,
  jewelryStore,
  library,
  lightRailStation,
  mosque,
  movieRental,
  movieTheater,
  museum,
  musicVenue,
  nationalPark,
  nightMarket,
  parkAndRide,
  pawnShop,
  performingArtsTheater,
  petStore,
  physiotherapist,
  placeOfWorship,
  playground,
  religiousSite,
  rvPark,
  shoeStore,
  spa,
  sportingGoodsStore,
  subwayStation,
  supermarket,
  synagogue,
  taxiStand,
  touristAttraction,
  trainStation,
  transitStation,
  travelAgency,
  university,
  weddingVenue,
  winery,
  zoo,
  unknown;

  /// 将枚举转换为MapKit识别的字符串值
  String toValue() {
    switch (this) {
      case POICategory.airport:
        return 'MKPOICategoryAirport';
      case POICategory.atm:
        return 'MKPOICategoryATM';
      case POICategory.bank:
        return 'MKPOICategoryBank';
      case POICategory.beach:
        return 'MKPOICategoryBeach';
      case POICategory.campground:
        return 'MKPOICategoryCampground';
      case POICategory.evCharger:
        return 'MKPOICategoryEVCharger';
      case POICategory.foodMarket:
        return 'MKPOICategoryFoodMarket';
      case POICategory.gasStation:
        return 'MKPOICategoryGasStation';
      case POICategory.hospital:
        return 'MKPOICategoryHospital';
      case POICategory.hotel:
        return 'MKPOICategoryHotel';
      case POICategory.laundry:
        return 'MKPOICategoryLaundry';
      case POICategory.nightlife:
        return 'MKPOICategoryNightlife';
      case POICategory.park:
        return 'MKPOICategoryPark';
      case POICategory.parking:
        return 'MKPOICategoryParking';
      case POICategory.pharmacy:
        return 'MKPOICategoryPharmacy';
      case POICategory.police:
        return 'MKPOICategoryPolice';
      case POICategory.postOffice:
        return 'MKPOICategoryPostOffice';
      case POICategory.publicTransport:
        return 'MKPOICategoryPublicTransport';
      case POICategory.restaurant:
        return 'MKPOICategoryRestaurant';
      case POICategory.restrooms:
        return 'MKPOICategoryRestroom';
      case POICategory.school:
        return 'MKPOICategorySchool';
      case POICategory.stadium:
        return 'MKPOICategoryStadium';
      case POICategory.store:
        return 'MKPOICategoryStore';
      case POICategory.theater:
        return 'MKPOICategoryTheater';
      default:
        return 'MKPOICategoryUnknown';
    }
  }

  /// 从MapKit字符串值创建枚举
  static POICategory fromValue(String value) {
    switch (value) {
      case 'MKPOICategoryAirport':
        return POICategory.airport;
      case 'MKPOICategoryATM':
        return POICategory.atm;
      case 'MKPOICategoryBank':
        return POICategory.bank;
      case 'MKPOICategoryBeach':
        return POICategory.beach;
      case 'MKPOICategoryCampground':
        return POICategory.campground;
      case 'MKPOICategoryEVCharger':
        return POICategory.evCharger;
      case 'MKPOICategoryFoodMarket':
        return POICategory.foodMarket;
      case 'MKPOICategoryGasStation':
        return POICategory.gasStation;
      case 'MKPOICategoryHospital':
        return POICategory.hospital;
      case 'MKPOICategoryHotel':
        return POICategory.hotel;
      case 'MKPOICategoryLaundry':
        return POICategory.laundry;
      case 'MKPOICategoryNightlife':
        return POICategory.nightlife;
      case 'MKPOICategoryPark':
        return POICategory.park;
      case 'MKPOICategoryParking':
        return POICategory.parking;
      case 'MKPOICategoryPharmacy':
        return POICategory.pharmacy;
      case 'MKPOICategoryPolice':
        return POICategory.police;
      case 'MKPOICategoryPostOffice':
        return POICategory.postOffice;
      case 'MKPOICategoryPublicTransport':
        return POICategory.publicTransport;
      case 'MKPOICategoryRestaurant':
        return POICategory.restaurant;
      case 'MKPOICategoryRestroom':
        return POICategory.restrooms;
      case 'MKPOICategorySchool':
        return POICategory.school;
      case 'MKPOICategoryStadium':
        return POICategory.stadium;
      case 'MKPOICategoryStore':
        return POICategory.store;
      case 'MKPOICategoryTheater':
        return POICategory.theater;
      default:
        return POICategory.unknown;
    }
  }
}

/// 地图特性选项，对应MapKit的MKMapFeatureOptions
///
/// iOS 16+可用
class MapFeatureOptions {
  const MapFeatureOptions({
    this.pointsOfInterest = false,
    this.territorialBoundaries = false,
    this.physicalFeatures = false,
  });

  /// 是否可选择兴趣点（如餐厅、公园等）
  final bool pointsOfInterest;

  /// 是否可选择领土边界（如国家、州边界）
  final bool territorialBoundaries;

  /// 是否可选择自然地理特征（如山脉、河流）
  final bool physicalFeatures;

  /// 转换为Map格式
  Map<String, dynamic> toMap() {
    return {
      'pointsOfInterest': pointsOfInterest,
      'territorialBoundaries': territorialBoundaries,
      'physicalFeatures': physicalFeatures,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapFeatureOptions &&
          runtimeType == other.runtimeType &&
          pointsOfInterest == other.pointsOfInterest &&
          territorialBoundaries == other.territorialBoundaries &&
          physicalFeatures == other.physicalFeatures;

  @override
  int get hashCode =>
      Object.hash(pointsOfInterest, territorialBoundaries, physicalFeatures);

  @override
  String toString() {
    return 'MapFeatureOptions{pointsOfInterest: $pointsOfInterest, '
        'territorialBoundaries: $territorialBoundaries, '
        'physicalFeatures: $physicalFeatures}';
  }
}

/// POI数据模型，对应MapKit的MKMapFeatureAnnotation
///
/// iOS 16+可用
class POIData {
  const POIData({
    this.name,
    this.category,
    required this.coordinate,
    this.address,
    this.thoroughfare,
    this.subThoroughfare,
    this.locality,
    this.subLocality,
    this.administrativeArea,
    this.subAdministrativeArea,
    this.postalCode,
    this.country,
    this.isoCountryCode,
    this.featureKind,
  });

  /// POI名称
  final String? name;

  /// POI类别
  final POICategory? category;

  /// 坐标位置
  final LatLng coordinate;

  /// 完整地址
  final String? address;

  /// 街道地址
  final String? thoroughfare;

  /// 子地址（如门牌号）
  final String? subThoroughfare;

  /// 城市/地区
  final String? locality;

  /// 子区域
  final String? subLocality;

  /// 省/州
  final String? administrativeArea;

  /// 子行政区划
  final String? subAdministrativeArea;

  /// 邮政编码
  final String? postalCode;

  /// 国家
  final String? country;

  /// ISO国家代码
  final String? isoCountryCode;

  /// 地图特性类型
  final String? featureKind;

  /// 从Map创建POIData实例
  factory POIData.fromMap(Map<dynamic, dynamic> map) {
    String? categoryValue;
    POICategory? category;

    // 处理category字段
    if (map['category'] is String) {
      categoryValue = map['category'] as String;
      category = POICategory.fromValue(categoryValue);
    }

    // 解析coordinate
    LatLng? coord;
    if (map['coordinate'] != null) {
      if (map['coordinate'] is Map) {
        coord = LatLng._fromJson(map['coordinate'] as Map<dynamic, dynamic>);
      } else if (map['coordinate'] is List && (map['coordinate'] as List).length >= 2) {
        final coords = map['coordinate'] as List;
        coord = LatLng(coords[0] as double, coords[1] as double);
      }
    }

    // 解析地址信息（可能在嵌套的address对象中）
    final addressMap = map['address'] as Map<dynamic, dynamic>?;

    return POIData(
      name: map['name'] as String?,
      category: category,
      coordinate: coord ?? const LatLng(0, 0),
      address: map['address'] is String
          ? map['address'] as String
          : (addressMap?['name'] as String?),
      thoroughfare: addressMap?['thoroughfare'] as String?,
      subThoroughfare: addressMap?['subThoroughfare'] as String?,
      locality: addressMap?['locality'] as String?,
      subLocality: addressMap?['subLocality'] as String?,
      administrativeArea: addressMap?['administrativeArea'] as String?,
      subAdministrativeArea: addressMap?['subAdministrativeArea'] as String?,
      postalCode: addressMap?['postalCode'] as String?,
      country: addressMap?['country'] as String?,
      isoCountryCode: addressMap?['isoCountryCode'] as String?,
      featureKind: map['featureKind'] as String?,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (name != null) {
      map['name'] = name;
    }

    if (category != null) {
      map['category'] = category!.toValue();
    }

    map['coordinate'] = {
      'latitude': coordinate.latitude,
      'longitude': coordinate.longitude,
    };

    if (address != null) {
      map['address'] = address;
    }

    if (thoroughfare != null) {
      map['thoroughfare'] = thoroughfare;
    }

    if (subThoroughfare != null) {
      map['subThoroughfare'] = subThoroughfare;
    }

    if (locality != null) {
      map['locality'] = locality;
    }

    if (subLocality != null) {
      map['subLocality'] = subLocality;
    }

    if (administrativeArea != null) {
      map['administrativeArea'] = administrativeArea;
    }

    if (subAdministrativeArea != null) {
      map['subAdministrativeArea'] = subAdministrativeArea;
    }

    if (postalCode != null) {
      map['postalCode'] = postalCode;
    }

    if (country != null) {
      map['country'] = country;
    }

    if (isoCountryCode != null) {
      map['isoCountryCode'] = isoCountryCode;
    }

    if (featureKind != null) {
      map['featureKind'] = featureKind;
    }

    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is POIData &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          category == other.category &&
          coordinate == other.coordinate &&
          address == other.address;

  @override
  int get hashCode => Object.hash(name, category, coordinate, address);

  @override
  String toString() {
    return 'POIData{name: $name, category: $category, '
        'coordinate: $coordinate, address: $address}';
  }
}

/// POI过滤器类型
enum POIFilterType {
  /// 包含所有POI
  includingAll,

  /// 排除指定类别
  excluding,

  /// 只包含指定类别
  including,
}

/// POI类别过滤器
class POICategoryFilter {
  const POICategoryFilter({
    this.type = POIFilterType.includingAll,
    this.excludedCategories = const {},
    this.includedCategories = const {},
  });

  /// 过滤器类型
  final POIFilterType type;

  /// 要排除的类别（当type为excluding时使用）
  final Set<POICategory> excludedCategories;

  /// 要包含的类别（当type为including时使用）
  final Set<POICategory> includedCategories;

  /// 创建一个包含所有POI的过滤器
  const POICategoryFilter.includingAll()
      : type = POIFilterType.includingAll,
        excludedCategories = const {},
        includedCategories = const {};

  /// 创建一个排除指定类别的过滤器
  factory POICategoryFilter.excluding(Set<POICategory> categories) {
    return POICategoryFilter(
      type: POIFilterType.excluding,
      excludedCategories: categories,
    );
  }

  /// 创建一个只包含指定类别的过滤器
  factory POICategoryFilter.including(Set<POICategory> categories) {
    return POICategoryFilter(
      type: POIFilterType.including,
      includedCategories: categories,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'type': type.name,
    };

    if (excludedCategories.isNotEmpty) {
      map['excludedCategories'] =
          excludedCategories.map((c) => c.toValue()).toList();
    }

    if (includedCategories.isNotEmpty) {
      map['includedCategories'] =
          includedCategories.map((c) => c.toValue()).toList();
    }

    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is POICategoryFilter &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          excludedCategories == other.excludedCategories &&
          includedCategories == other.includedCategories;

  @override
  int get hashCode => Object.hash(type, excludedCategories, includedCategories);
}

/// 地图配置类型（iOS 16+）
enum MapConfigurationType {
  /// 标准地图
  standard,

  /// 混合地图（卫星+道路）
  hybrid,

  /// 卫星图像
  imagery,
}

/// 标准地图强调样式（iOS 16+）
enum StandardMapEmphasisStyle {
  /// 默认样式
  defaultValue,

  /// 静音样式（减少视觉强调）
  muted,

  /// 高对比度样式
  highContrast,
}

/// 地图配置选项（iOS 16+）
///
/// 使用MKMapConfiguration替代已废弃的mapType
class MapConfigurationOptions {
  const MapConfigurationOptions({
    required this.type,
    this.emphasisStyle,
    this.poiCategories,
    this.poiFilter,
    this.showsBuildings = false,
    this.showsTileLoadedCount = false,
  });

  /// 地图配置类型
  final MapConfigurationType type;

  /// 标准地图的强调样式（仅当type为standard时有效）
  final StandardMapEmphasisStyle? emphasisStyle;

  /// 要显示的POI类别（如果为null则显示所有）
  final Set<POICategory>? poiCategories;

  /// POI过滤器
  final POICategoryFilter? poiFilter;

  /// 是否显示3D建筑（仅当type为imagery时有效）
  final bool showsBuildings;

  /// 是否显示瓦片加载计数（仅当type为hybrid时有效）
  final bool showsTileLoadedCount;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'type': type.name,
    };

    if (emphasisStyle != null) {
      map['emphasisStyle'] = emphasisStyle!.name;
    }

    if (poiCategories != null && poiCategories!.isNotEmpty) {
      map['poiCategories'] = poiCategories!.map((c) => c.toValue()).toList();
    }

    if (poiFilter != null) {
      map['poiFilter'] = poiFilter!.toMap();
    }

    map['showsBuildings'] = showsBuildings;
    map['showsTileLoadedCount'] = showsTileLoadedCount;

    return map;
  }

  /// 创建标准地图配置
  const MapConfigurationOptions.standard({
    StandardMapEmphasisStyle? emphasisStyle,
    Set<POICategory>? poiCategories,
    POICategoryFilter? poiFilter,
  }) : this(
          type: MapConfigurationType.standard,
          emphasisStyle: emphasisStyle,
          poiCategories: poiCategories,
          poiFilter: poiFilter,
        );

  /// 创建混合地图配置
  const MapConfigurationOptions.hybrid({
    Set<POICategory>? poiCategories,
    POICategoryFilter? poiFilter,
    bool showsTileLoadedCount = false,
  }) : this(
          type: MapConfigurationType.hybrid,
          poiCategories: poiCategories,
          poiFilter: poiFilter,
          showsTileLoadedCount: showsTileLoadedCount,
        );

  /// 创建卫星图像配置
  const MapConfigurationOptions.imagery({
    bool showsBuildings = false,
    Set<POICategory>? poiCategories,
    POICategoryFilter? poiFilter,
  }) : this(
          type: MapConfigurationType.imagery,
          showsBuildings: showsBuildings,
          poiCategories: poiCategories,
          poiFilter: poiFilter,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapConfigurationOptions &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          emphasisStyle == other.emphasisStyle;

  @override
  int get hashCode => Object.hash(type, emphasisStyle);

  @override
  String toString() {
    return 'MapConfigurationOptions{type: $type, '
        'emphasisStyle: $emphasisStyle}';
  }
}
