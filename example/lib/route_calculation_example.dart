// Copyright 2024 The apple_maps_flutter authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:apple_maps_flutter_example/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 路线计算示例页面（用于主页面列表）
class RouteCalculationPage extends ExamplePage {
  RouteCalculationPage()
      : super(const Icon(Icons.directions), '路线计算 Route Calculation');

  @override
  Widget build(BuildContext context) {
    return const RouteCalculationExample();
  }
}

/// 路线计算示例页面
class RouteCalculationExample extends StatefulWidget {
  const RouteCalculationExample({Key? key}) : super(key: key);

  @override
  State<RouteCalculationExample> createState() =>
      _RouteCalculationExampleState();
}

class _RouteCalculationExampleState extends State<RouteCalculationExample> {
  AppleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Annotation> _annotations = {};
  RouteResult? _currentRoute;
  List<RouteResult> _allRoutes = []; // 存储所有备选路线
  int _selectedRouteIndex = 0; // 当前选中的路线索引
  bool _isCalculating = false;
  RouteTransportType _selectedTransportType = RouteTransportType.automobile;

  // 示例位置 - 武汉地铁站（用于测试公共交通路线）
  // 武汉站（地铁4号线）
  static const LatLng _origin = LatLng(30.6069, 114.4247);
  // 武汉天河机场站（地铁2号线）
  static const LatLng _destination = LatLng(30.5224, 114.3641);

  // 备选测试坐标：
  // 江汉路站（地铁2号线）：30.5964, 114.2768
  // 光谷广场站（地铁2号线）：30.5105, 114.4171

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('路线计算示例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearRoute,
            tooltip: '清除路线',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 地图
          AppleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.6970, 114.3195), // 武汉市中心
              zoom: 11,
            ),
            polylines: _polylines,
            annotations: _annotations,
            onMapCreated: _onMapCreated,
            trafficEnabled: true,
          ),

          // 路线信息卡片
          if (_currentRoute != null) _buildRouteInfoCard(),

          // 交通方式选择器
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildTransportTypeSelector(),
          ),

          // 加载指示器
          if (_isCalculating)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'calculate',
            onPressed: _calculateRoute,
            tooltip: '计算路线',
            child: const Icon(Icons.directions),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'alternate',
            onPressed: _calculateAlternateRoutes,
            tooltip: '备选路线',
            child: const Icon(Icons.alt_route),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(AppleMapController controller) {
    _mapController = controller;
    _addMarkers();
  }

  /// 添加起点和终点标注
  void _addMarkers() {
    setState(() {
      _annotations = {
        Annotation(
          annotationId: AnnotationId('origin'),
          position: _origin,
          infoWindow: InfoWindow(
            title: '武汉站',
            snippet: '起点 (地铁4号线)',
          ),
        ),
        Annotation(
          annotationId: AnnotationId('destination'),
          position: _destination,
          infoWindow: InfoWindow(
            title: '天河机场',
            snippet: '终点 (地铁2号线)',
          ),
        ),
      };
    });
  }

  /// 计算单条路线
  Future<void> _calculateRoute() async {
    if (_mapController == null) return;

    setState(() {
      _isCalculating = true;
      _currentRoute = null;
      _allRoutes = []; // 清除备选路线
      _selectedRouteIndex = 0;
      _polylines.clear();
    });

    try {
      final route = await _mapController!.calculateRoute(
        origin: _origin,
        destination: _destination,
        transportType: _selectedTransportType,
      );

      setState(() {
        _currentRoute = route;
        _polylines = {
          Polyline(
            polylineId: PolylineId('main_route'),
            points: route.coordinates,
            color: _getColorForTransportType(_selectedTransportType),
            width: 5,
          ),
        };
      });

      // 调整视图以显示整条路线
      _fitRouteToBounds(route.coordinates);

      _showSnackBar('路线计算成功！');
    } catch (e) {
      _showDetailedError('路线计算失败', e);
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  /// 计算多条备选路线
  Future<void> _calculateAlternateRoutes() async {
    if (_mapController == null) return;

    setState(() {
      _isCalculating = true;
      _currentRoute = null;
      _allRoutes = [];
      _selectedRouteIndex = 0;
      _polylines.clear();
    });

    try {
      final routes = await _mapController!.calculateAlternateRoutes(
        origin: _origin,
        destination: _destination,
        transportType: _selectedTransportType,
      );

      if (routes.isEmpty) {
        _showSnackBar('未找到路线');
        return;
      }

      // 保存所有路线并显示第一条
      setState(() {
        _allRoutes = routes;
        _currentRoute = routes.first;
        _selectedRouteIndex = 0;

        // 绘制所有路线
        _polylines = routes.asMap().entries.map((entry) {
          final index = entry.key;
          final route = entry.value;
          final isSelected = index == _selectedRouteIndex;

          return Polyline(
            polylineId: PolylineId('route_$index'),
            points: route.coordinates,
            color: isSelected
                ? _getColorForTransportType(_selectedTransportType)
                : Colors.grey.withOpacity(0.5),
            width: isSelected ? 5 : 3,
          );
        }).toSet();
      });

      // 调整视图
      _fitRouteToBounds(routes.first.coordinates);

      _showSnackBar('找到 ${routes.length} 条路线');

      // 如果有多条路线，显示备选路线列表
      if (routes.length > 1) {
        _showAlternateRoutesSheet();
      }
    } catch (e) {
      _showDetailedError('备选路线计算失败', e);
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  /// 选择备选路线
  void _selectRoute(int index) {
    if (index < 0 || index >= _allRoutes.length) return;

    setState(() {
      _selectedRouteIndex = index;
      _currentRoute = _allRoutes[index];

      // 更新路线显示
      _polylines = _allRoutes.asMap().entries.map((entry) {
        final routeIndex = entry.key;
        final route = entry.value;
        final isSelected = routeIndex == index;

        return Polyline(
          polylineId: PolylineId('route_$routeIndex'),
          points: route.coordinates,
          color: isSelected
              ? _getColorForTransportType(_selectedTransportType)
              : Colors.grey.withOpacity(0.5),
          width: isSelected ? 5 : 3,
        );
      }).toSet();
    });

    // 调整视图以显示选中的路线
    _fitRouteToBounds(_allRoutes[index].coordinates);
  }

  /// 调整地图视图以显示整条路线
  void _fitRouteToBounds(List<LatLng> coordinates) {
    if (coordinates.isEmpty || _mapController == null) return;

    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (final coord in coordinates) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  /// 清除路线
  void _clearRoute() {
    setState(() {
      _polylines.clear();
      _currentRoute = null;
    });
  }

  /// 显示路线详细步骤
  void _showRouteDetails() {
    if (_currentRoute == null || _currentRoute!.steps == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForTransportType(_selectedTransportType),
                      color: _getColorForTransportType(_selectedTransportType),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '路线详情',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${_currentRoute!.formatDistance()} · ${_currentRoute!.formatDuration()}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // 步骤列表
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _currentRoute!.steps!.length,
                  separatorBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(left: 24),
                    child: Divider(
                      color: Colors.grey[300],
                      height: 1,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final step = _currentRoute!.steps![index];
                    return _buildStepItem(step, index);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 显示备选路线列表
  void _showAlternateRoutesSheet() {
    if (_allRoutes.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                children: [
                  // 标题栏
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.alt_route,
                          color:
                              _getColorForTransportType(_selectedTransportType),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '备选路线',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                '找到 ${_allRoutes.length} 条路线',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  // 路线列表
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _allRoutes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final route = _allRoutes[index];
                        final isSelected = index == _selectedRouteIndex;

                        return InkWell(
                          onTap: () {
                            _selectRoute(index);
                            setModalState(() {}); // 更新模态框内的状态
                            setState(() {}); // 更新主页面的状态
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _getColorForTransportType(
                                          _selectedTransportType)
                                      .withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? _getColorForTransportType(
                                        _selectedTransportType)
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 路线标题
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? _getColorForTransportType(
                                                _selectedTransportType)
                                            : Colors.grey[400],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '路线 ${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (index == 0) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '推荐',
                                          style: TextStyle(
                                            color: Colors.orange[900],
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.check_circle,
                                        color: _getColorForTransportType(
                                            _selectedTransportType),
                                        size: 20,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // 路线信息
                                Row(
                                  children: [
                                    // 距离
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.straighten,
                                            size: 18,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              route.formatDistance(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? Colors.black87
                                                    : Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // 时间
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 18,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              route.formatDuration(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? Colors.black87
                                                    : Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // 路线名称（如果有）
                                if (route.name != null &&
                                    route.name!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    route.name!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                // 对比信息（相对于推荐路线）
                                if (index > 0) ...[
                                  const SizedBox(height: 8),
                                  _buildRouteComparison(route, _allRoutes[0]),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// 构建路线对比信息
  Widget _buildRouteComparison(RouteResult route, RouteResult recommended) {
    final distanceDiff = route.distance - recommended.distance;
    final timeDiff = route.expectedTravelTime - recommended.expectedTravelTime;

    final List<String> comparisons = [];

    if (distanceDiff.abs() > 100) {
      final distanceText = distanceDiff > 0
          ? '+${(distanceDiff / 1000).toStringAsFixed(1)} km'
          : '${(distanceDiff / 1000).toStringAsFixed(1)} km';
      comparisons.add(distanceText);
    }

    if (timeDiff.abs() > 60) {
      final timeText = timeDiff > 0
          ? '+${(timeDiff / 60).round()} min'
          : '${(timeDiff / 60).round()} min';
      comparisons.add(timeText);
    }

    if (comparisons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '相比推荐路线: ${comparisons.join(', ')}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  /// 构建单个步骤项
  Widget _buildStepItem(RouteStep step, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 步骤编号
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getColorForTransportType(_selectedTransportType)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: _getColorForTransportType(_selectedTransportType),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: _getColorForTransportType(_selectedTransportType),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 步骤详情
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 指示文本
                Text(
                  step.instructions.isNotEmpty ? step.instructions : '继续前进',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                // 距离和交通方式
                Row(
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      step.formatDistance(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (step.transportType != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        _getIconForStepTransportType(step.transportType!),
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTransportTypeDisplayName(step.transportType!),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
                // 坐标点数量（如果有）
                if (step.coordinates != null && step.coordinates!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${step.coordinates!.length} 个坐标点',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 获取步骤交通方式的图标
  IconData _getIconForStepTransportType(String transportType) {
    switch (transportType.toLowerCase()) {
      case 'automobile':
        return Icons.directions_car;
      case 'walking':
        return Icons.directions_walk;
      case 'cycling':
      case 'bicycle':
        return Icons.directions_bike;
      case 'transit':
        return Icons.directions_transit;
      default:
        return Icons.navigation;
    }
  }

  /// 获取交通方式显示名称
  String _getTransportTypeDisplayName(String transportType) {
    switch (transportType.toLowerCase()) {
      case 'automobile':
        return '驾车';
      case 'walking':
        return '步行';
      case 'cycling':
      case 'bicycle':
        return '骑行';
      case 'transit':
        return '公交';
      default:
        return '导航';
    }
  }

  /// 构建路线信息卡片
  Widget _buildRouteInfoCard() {
    if (_currentRoute == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    _getIconForTransportType(_selectedTransportType),
                    color: _getColorForTransportType(_selectedTransportType),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedTransportType.displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const Divider(),
              _buildInfoRow(
                Icons.straighten,
                '距离',
                _currentRoute!.formatDistance(),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.access_time,
                '时间',
                _currentRoute!.formatDuration(),
              ),
              if (_currentRoute!.steps != null &&
                  _currentRoute!.steps!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.fork_right,
                  '步骤',
                  '${_currentRoute!.steps!.length} 步',
                ),
              ],
              // 显示备选路线数量
              if (_allRoutes.length > 1) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.alt_route,
                  '备选路线',
                  '${_allRoutes.length} 条',
                ),
              ],
              // 按钮区域
              if (_currentRoute!.steps != null &&
                      _currentRoute!.steps!.isNotEmpty ||
                  _allRoutes.length > 1) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // 查看详细步骤按钮
                    if (_currentRoute!.steps != null &&
                        _currentRoute!.steps!.isNotEmpty)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showRouteDetails,
                          icon: const Icon(Icons.list_alt, size: 18),
                          label: Text(
                            _allRoutes.length > 1 ? '详细步骤' : '查看详细步骤',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    // 备选路线按钮
                    if (_allRoutes.length > 1) ...[
                      if (_currentRoute!.steps != null &&
                          _currentRoute!.steps!.isNotEmpty)
                        const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showAlternateRoutesSheet,
                          icon: const Icon(Icons.alt_route, size: 18),
                          label: Text(
                            _currentRoute!.steps != null &&
                                    _currentRoute!.steps!.isNotEmpty
                                ? '其他路线'
                                : '查看备选路线',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 构建交通方式选择器
  Widget _buildTransportTypeSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: RouteTransportType.values
              .where((type) => type != RouteTransportType.any)
              .map((type) {
            final isSelected = type == _selectedTransportType;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Icon(
                  _getIconForTransportType(type),
                  size: 20,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedTransportType = type;
                    });
                  }
                },
                selectedColor: _getColorForTransportType(type),
                backgroundColor: Colors.grey[200],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 获取交通方式对应的图标
  IconData _getIconForTransportType(RouteTransportType type) {
    switch (type) {
      case RouteTransportType.automobile:
        return Icons.directions_car;
      case RouteTransportType.walking:
        return Icons.directions_walk;
      case RouteTransportType.cycling:
        return Icons.directions_bike;
      case RouteTransportType.transit:
        return Icons.directions_transit;
      default:
        return Icons.directions;
    }
  }

  /// 获取交通方式对应的颜色
  Color _getColorForTransportType(RouteTransportType type) {
    switch (type) {
      case RouteTransportType.automobile:
        return Colors.blue;
      case RouteTransportType.walking:
        return Colors.green;
      case RouteTransportType.cycling:
        return Colors.purple;
      case RouteTransportType.transit:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// 显示提示消息
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 显示详细的错误信息
  void _showDetailedError(String title, dynamic error) {
    // 打印到控制台以便调试
    print('$title: $error');

    // 解析错误详情
    String errorMessage = error.toString();
    Map<String, dynamic>? errorDetails;

    if (error is PlatformException) {
      errorMessage = error.message ?? '未知错误';

      // 安全地转换错误详情
      if (error.details != null) {
        try {
          if (error.details is Map) {
            errorDetails = Map<String, dynamic>.from(error.details as Map);
          }
        } catch (e) {
          print('转换错误详情失败: $e');
          errorDetails = {'raw': error.details.toString()};
        }
      }

      // 打印详细信息
      print('错误代码: ${error.code}');
      print('错误消息: ${error.message}');
      print('错误详情: ${error.details}');
      print('错误详情类型: ${error.details.runtimeType}');

      // 检查是否是公共交通路线错误
      if (_selectedTransportType == RouteTransportType.transit &&
          (error.code == 'NO_ROUTE_FOUND' ||
              error.code == 'ROUTE_ERROR' ||
              (errorDetails?['code'] == 5))) {
        errorMessage = '公共交通路线不可用';
        if (errorDetails != null) {
          errorDetails['transitNotAvailable'] = true;
          errorDetails['message'] = '公共交通路线在当前区域不可用';
        }
      }

      // 检查是否是骑行路线（提示用户地区限制）
      if (_selectedTransportType == RouteTransportType.cycling) {
        if (errorDetails != null) {
          errorDetails['cyclingNote'] = true;
          errorDetails['cyclingMessage'] = 'iOS 17+ 支持骑行路线，但数据完整性因地区而异。\n'
              'iOS 17 以下会自动降级为步行路线。';
        }
      }
    }

    // 显示错误对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (errorDetails != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  '详细信息:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...errorDetails.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
              const SizedBox(height: 16),
              const Text(
                '可能的原因：',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _buildErrorSuggestions(errorDetails),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 复制错误详情到剪贴板
              final fullError =
                  '$title\n$errorMessage\n${errorDetails?.toString() ?? ""}';
              Clipboard.setData(ClipboardData(text: fullError));
              _showSnackBar('错误详情已复制到剪贴板');
            },
            child: const Text('复制详情'),
          ),
        ],
      ),
    );
  }

  /// 根据错误类型提供建议
  Widget _buildErrorSuggestions(Map<String, dynamic>? errorDetails) {
    final errorType = errorDetails?['errorType'] as String?;
    final transitNotAvailable =
        errorDetails?['transitNotAvailable'] as bool? ?? false;

    List<String> suggestions = [];

    // 检查是否是公共交通路线不可用
    if (transitNotAvailable ||
        (_selectedTransportType == RouteTransportType.transit &&
            (errorType == 'NO_ROUTE_FOUND' ||
                errorType == 'UNKNOWN' ||
                errorDetails?['code'] == 5))) {
      suggestions = [
        '⚠️ 公共交通路线计算失败，可能的原因：',
        '',
        '1. 坐标位置问题：',
        '   • 起点或终点不在公交站点/地铁站附近',
        '   • 建议使用实际的公交站点或地铁站坐标',
        '',
        '2. 路线不可用：',
        '   • 两点之间可能没有直达的公共交通线路',
        '   • 距离可能超出公共交通服务范围',
        '',
        '3. 地区支持情况：',
        '   • Apple Maps 在中国的北京、上海等主要城市支持公共交通',
        '   • 部分中小城市的公交数据可能不完整或不可用',
        '   • 武汉等城市的支持情况需要实际测试',
        '',
        '💡 建议尝试：',
        '   • 使用实际地铁站坐标（如武汉站、光谷广场站）',
        '   • 缩短起点和终点之间的距离',
        '   • 切换到"驾车"或"步行"模式',
        '   • 使用高德地图、百度地图等本地服务（数据更完整）',
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: suggestions.map((suggestion) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              suggestion,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    suggestion.startsWith('⚠️') || suggestion.startsWith('💡')
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      );
    }

    switch (errorType) {
      case 'NO_ROUTE_FOUND':
        suggestions = [
          '• 起点和终点距离可能太远',
          '• 所选交通方式不支持该路线',
          '• 可能需要网络连接来计算路线',
          '• 某些区域可能没有可用的路线数据',
        ];
        break;
      case 'SERVER_FAILURE':
        suggestions = [
          '• Apple Maps 服务器暂时不可用',
          '• 请检查网络连接',
          '• 稍后再试',
        ];
        break;
      case 'LOADING_THROTTLED':
        suggestions = [
          '• 请求过于频繁',
          '• 请等待几秒后再试',
        ];
        break;
      case 'INVALID_COORDINATES':
        suggestions = [
          '• 提供的坐标无效',
          '• 请检查纬度和经度是否在有效范围内',
        ];
        break;
      case 'PLACEMARK_NOT_FOUND':
        suggestions = [
          '• 无法识别指定的地理位置',
          '• 请尝试其他坐标',
        ];
        break;
      case 'NETWORK_ERROR':
        suggestions = [
          '• 请检查网络连接',
          '• 确保设备已连接到互联网',
        ];
        break;
      case 'UNKNOWN':
        suggestions = [
          '• 可能是不支持的功能或区域限制',
          '• 尝试切换不同的交通方式',
          '• 检查网络连接',
          '• 确保设备已连接到互联网',
        ];
        break;
      default:
        suggestions = [
          '• 请检查网络连接',
          '• 确保已授予位置权限',
          '• 尝试重新启动应用',
        ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: suggestions.map((suggestion) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            suggestion,
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }
}
