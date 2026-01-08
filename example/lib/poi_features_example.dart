// Copyright 2024 The apple_maps_flutter authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:apple_maps_flutter_example/page.dart';
import 'package:flutter/material.dart';

/// POI和地图特性示例页面（用于主页面列表）
class POIFeaturesPage extends ExamplePage {
  const POIFeaturesPage()
      : super(const Icon(Icons.place), 'POI功能 POI Features (iOS 16+)');

  @override
  Widget build(BuildContext context) {
    return const POIFeaturesExample();
  }
}

/// POI和地图特性示例页面
///
/// 此示例展示iOS 16+的新功能：
/// - 新的地图配置系统（MKMapConfiguration）
/// - 可选择的地图特性（POI、边界、自然特征）
/// - POI选择回调
class POIFeaturesExample extends StatefulWidget {
  const POIFeaturesExample({Key? key}) : super(key: key);

  @override
  State<POIFeaturesExample> createState() => _POIFeaturesExampleState();
}

class _POIFeaturesExampleState extends State<POIFeaturesExample> {
  AppleMapController? _mapController;

  // 当前选择的地图配置
  MapConfigurationType _selectedConfigType = MapConfigurationType.standard;
  StandardMapEmphasisStyle _selectedEmphasisStyle = StandardMapEmphasisStyle.defaultValue;

  // 地图特性选项
  bool _pointsOfInterestEnabled = true;
  bool _territorialBoundariesEnabled = false;
  bool _physicalFeaturesEnabled = false;

  // 最后选中的POI信息
  POIData? _lastSelectedPOI;

  // 示例位置 - 旧金山金门大桥周边（有丰富的POI）
  static const LatLng _initialPosition = LatLng(37.8199, -122.4783);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POI功能示例 (iOS 16+)'),
        actions: [
          // 信息按钮
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: '功能说明',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 地图
          AppleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 14,
            ),
            // iOS 16+ 新配置系统
            mapConfigurationOptions: _buildMapConfiguration(),
            // 可选择的地图特性
            selectableMapFeatures: MapFeatureOptions(
              pointsOfInterest: _pointsOfInterestEnabled,
              territorialBoundaries: _territorialBoundariesEnabled,
              physicalFeatures: _physicalFeaturesEnabled,
            ),
            // POI选择回调
            onPOISelected: _onPOISelected,
            onMapCreated: _onMapCreated,
          ),

          // 配置面板
          _buildConfigPanel(),

          // POI信息卡片（当选中POI时显示）
          if (_lastSelectedPOI != null) _buildPOICard(),
        ],
      ),
    );
  }

  /// 构建地图配置
  MapConfigurationOptions? _buildMapConfiguration() {
    switch (_selectedConfigType) {
      case MapConfigurationType.standard:
        return MapConfigurationOptions.standard(
          emphasisStyle: _selectedEmphasisStyle,
        );
      case MapConfigurationType.hybrid:
        return const MapConfigurationOptions.hybrid();
      case MapConfigurationType.imagery:
        return const MapConfigurationOptions.imagery(
          showsBuildings: true,
        );
    }
  }

  /// 构建配置面板
  Widget _buildConfigPanel() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 180),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 地图配置类型选择
                Row(
                  children: [
                    const Icon(Icons.map, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text(
                      '地图类型',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: MapConfigurationType.values.map((type) {
                      final isSelected = _selectedConfigType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedConfigType = type;
                              _updateMapConfiguration();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getConfigTypeName(type),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // 强调样式选择（仅标准地图可用）
                if (_selectedConfigType == MapConfigurationType.standard) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '强调样式',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: StandardMapEmphasisStyle.values.map((style) {
                      final isSelected = _selectedEmphasisStyle == style;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedEmphasisStyle = style;
                            _updateMapConfiguration();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getEmphasisStyleName(style),
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // 地图特性开关 - 紧凑版本
                const Text(
                  '可选择特性',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                _buildCompactSwitch('POI', _pointsOfInterestEnabled, (value) {
                  setState(() {
                    _pointsOfInterestEnabled = value;
                    _updateSelectableFeatures();
                  });
                }),
                _buildCompactSwitch('边界', _territorialBoundariesEnabled, (value) {
                  setState(() {
                    _territorialBoundariesEnabled = value;
                    _updateSelectableFeatures();
                  });
                }),
                _buildCompactSwitch('自然特征', _physicalFeaturesEnabled, (value) {
                  setState(() {
                    _physicalFeaturesEnabled = value;
                    _updateSelectableFeatures();
                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建紧凑的开关组件
  Widget _buildCompactSwitch(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建POI信息卡片
  Widget _buildPOICard() {
    final poi = _lastSelectedPOI!;
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // POI名称
              Row(
                children: [
                  const Icon(Icons.place, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      poi.name ?? '未知地点',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _lastSelectedPOI = null;
                      });
                    },
                  ),
                ],
              ),
              const Divider(height: 16),

              // POI类别
              if (poi.category != null)
                _buildInfoRow(
                  Icons.category,
                  '类别',
                  _getCategoryName(poi.category!),
                ),

              // 地址
              if (poi.address != null && poi.address!.isNotEmpty)
                _buildInfoRow(Icons.location_on, '地址', poi.address!),

              // 详细地址信息
              if (poi.locality != null ||
                  poi.administrativeArea != null ||
                  poi.country != null)
                Padding(
                  padding: const EdgeInsets.only(left: 32, bottom: 8),
                  child: Text(
                    _formatFullAddress(poi),
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),

              // 坐标
              _buildInfoRow(
                Icons.my_location,
                '坐标',
                '${poi.coordinate.latitude.toStringAsFixed(6)}, '
                '${poi.coordinate.longitude.toStringAsFixed(6)}',
              ),

              // 特性类型
              if (poi.featureKind != null)
                _buildInfoRow(
                  Icons.map,
                  '特性',
                  poi.featureKind!,
                ),

              const SizedBox(height: 8),

              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.center_focus_strong),
                      label: const Text('居中显示'),
                      onPressed: () => _centerOnPOI(poi),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('关闭'),
                      onPressed: () {
                        setState(() {
                          _lastSelectedPOI = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// 地图创建回调
  void _onMapCreated(AppleMapController controller) {
    _mapController = controller;
  }

  /// POI选择回调
  void _onPOISelected(POIData poi) {
    setState(() {
      _lastSelectedPOI = poi;
    });

    // 显示SnackBar通知
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已选择: ${poi.name ?? "未知地点"}'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: '查看',
          onPressed: () => _centerOnPOI(poi),
        ),
      ),
    );
  }

  /// 更新地图配置
  void _updateMapConfiguration() {
    _mapController?.updateMapConfiguration(_buildMapConfiguration()!);
  }

  /// 更新可选择的地图特性
  void _updateSelectableFeatures() {
    _mapController?.updateSelectableFeatures(
      MapFeatureOptions(
        pointsOfInterest: _pointsOfInterestEnabled,
        territorialBoundaries: _territorialBoundariesEnabled,
        physicalFeatures: _physicalFeaturesEnabled,
      ),
    );
  }

  /// 居中显示POI
  void _centerOnPOI(POIData poi) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(poi.coordinate),
    );
  }

  /// 格式化完整地址
  String _formatFullAddress(POIData poi) {
    final parts = <String>[];
    if (poi.locality != null) parts.add(poi.locality!);
    if (poi.administrativeArea != null) parts.add(poi.administrativeArea!);
    if (poi.country != null) parts.add(poi.country!);
    return parts.isNotEmpty ? parts.join(', ') : '';
  }

  /// 获取配置类型名称
  String _getConfigTypeName(MapConfigurationType type) {
    switch (type) {
      case MapConfigurationType.standard:
        return '标准';
      case MapConfigurationType.hybrid:
        return '混合';
      case MapConfigurationType.imagery:
        return '卫星';
    }
  }

  /// 获取强调样式名称
  String _getEmphasisStyleName(StandardMapEmphasisStyle style) {
    switch (style) {
      case StandardMapEmphasisStyle.defaultValue:
        return '默认';
      case StandardMapEmphasisStyle.muted:
        return '静音';
      case StandardMapEmphasisStyle.highContrast:
        return '高对比度';
    }
  }

  /// 获取类别名称
  String _getCategoryName(POICategory category) {
    // 常见类别的中文名称映射
    const commonCategories = {
      POICategory.restaurant: '餐厅',
      POICategory.cafe: '咖啡厅',
      POICategory.bank: '银行',
      POICategory.atm: 'ATM',
      POICategory.hotel: '酒店',
      POICategory.hospital: '医院',
      POICategory.pharmacy: '药房',
      POICategory.park: '公园',
      POICategory.school: '学校',
      POICategory.store: '商店',
      POICategory.gasStation: '加油站',
      POICategory.parking: '停车场',
      POICategory.airport: '机场',
      POICategory.police: '警察局',
      POICategory.postOffice: '邮局',
      POICategory.library: '图书馆',
      POICategory.museum: '博物馆',
      POICategory.theater: '剧院',
    };

    return commonCategories[category] ?? category.name;
  }

  /// 显示功能说明对话框
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('功能说明'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: [
              Text(
                '此示例展示了iOS 16+的MapKit新功能：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('1. 新的地图配置系统'),
              Text(
                '   使用MKMapConfiguration替代已废弃的mapType',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text('2. 可选择的地图特性'),
              Text(
                '   控制地图上哪些元素可以与用户交互',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text('3. POI选择回调'),
              Text(
                '   当用户点击兴趣点时触发回调',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 12),
              Text(
                '注意：这些功能需要iOS 16或更高版本',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
