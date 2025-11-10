# 路线计算功能使用指南

## 概述

apple_maps_flutter 现已支持路线计算功能，使用 Apple MapKit 的 MKDirections API 来计算两点之间的路线。此功能允许您：

- 计算驾车、步行、骑行和公共交通路线
- 获取路线坐标点用于在地图上绘制
- 获取距离和预计时间信息
- 获取详细的导航步骤
- 计算多条备选路线
- 查看分步导航指示

## 功能特性

### ✅ 已支持

- **单条路线计算** - 计算两点之间的最优路线
- **多条备选路线** - 获取多个路线选项
- **ETA 计算** - 快速获取预计到达时间（不包含完整路线坐标）
- **多种交通方式** - 驾车、步行、骑行（使用步行近似）、公交
- **详细路线信息** - 距离、时间、坐标点、导航步骤
- **分步导航指示** - 每个转弯和路段的详细说明
- **增强的错误处理** - 详细的错误信息和解决建议

### ⚠️ 限制

- **需要网络连接** - MKDirections API 需要网络
- **公共交通限制** - 公共交通路线仅在部分地区可用（中国大陆不支持）
- **骑行路线限制** - 骑行路线需要 iOS 17+，且可用性因地区而异
- **使用配额** - Apple 可能对请求频率有限制
- **仅支持 iOS** - 此功能仅在 iOS 平台可用

## 快速开始

### 1. 基本用法

```dart
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

class MyMapPage extends StatefulWidget {
  @override
  State<MyMapPage> createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
  AppleMapController? _mapController;
  Set<Polyline> _polylines = {};
  
  void _onMapCreated(AppleMapController controller) {
    _mapController = controller;
  }
  
  Future<void> _calculateRoute() async {
    if (_mapController == null) return;
    
    try {
      // 计算路线
      final route = await _mapController!.calculateRoute(
        origin: LatLng(37.7749, -122.4194),  // 旧金山
        destination: LatLng(34.0522, -118.2437),  // 洛杉矶
        transportType: RouteTransportType.automobile,
      );
      
      // 打印路线信息
      print('距离: ${route.formatDistance()}');
      print('时间: ${route.formatDuration()}');
      
      // 在地图上绘制路线
      setState(() {
        _polylines = {
          Polyline(
            polylineId: PolylineId('route'),
            points: route.coordinates,
            color: Colors.blue,
            width: 5,
          ),
        };
      });
      
    } catch (e) {
      print('路线计算失败: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(36.0, -120.0),
          zoom: 6,
        ),
        polylines: _polylines,
        onMapCreated: _onMapCreated,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _calculateRoute,
        child: Icon(Icons.directions),
      ),
    );
  }
}
```

### 2. 计算多条备选路线

```dart
Future<void> _calculateAlternateRoutes() async {
  try {
    final routes = await _mapController!.calculateAlternateRoutes(
      origin: LatLng(37.7749, -122.4194),
      destination: LatLng(34.0522, -118.2437),
      transportType: RouteTransportType.automobile,
    );
    
    print('找到 ${routes.length} 条路线');
    
    // 显示所有路线
    setState(() {
      _polylines = routes.asMap().entries.map((entry) {
        final index = entry.key;
        final route = entry.value;
        
        return Polyline(
          polylineId: PolylineId('route_$index'),
          points: route.coordinates,
          color: index == 0 ? Colors.blue : Colors.grey,
          width: index == 0 ? 5 : 3,
        );
      }).toSet();
    });
    
  } catch (e) {
    print('路线计算失败: $e');
  }
}
```

### 3. 仅计算 ETA（更快）

如果只需要距离和时间信息，不需要完整路线坐标：

```dart
Future<void> _calculateETA() async {
  try {
    final eta = await _mapController!.calculateETA(
      origin: LatLng(37.7749, -122.4194),
      destination: LatLng(34.0522, -118.2437),
      transportType: RouteTransportType.automobile,
    );
    
    final distanceKm = eta['distance'] / 1000;
    final timeMinutes = eta['expectedTravelTime'] / 60;
    
    print('距离: ${distanceKm.toStringAsFixed(1)} 公里');
    print('时间: ${timeMinutes.round()} 分钟');
    
  } catch (e) {
    print('ETA 计算失败: $e');
  }
}
```

## API 参考

### AppleMapController.calculateRoute()

计算单条最优路线。

**参数：**
- `origin: LatLng` - 起点坐标（必需）
- `destination: LatLng` - 终点坐标（必需）
- `transportType: RouteTransportType` - 交通方式（可选，默认 automobile）

**返回值：** `Future<RouteResult>`

**异常：**
- 坐标无效
- 未找到路线
- 网络错误
- 服务不可用

### AppleMapController.calculateAlternateRoutes()

计算多条备选路线。

**参数：**
- `origin: LatLng` - 起点坐标（必需）
- `destination: LatLng` - 终点坐标（必需）
- `transportType: RouteTransportType` - 交通方式（可选，默认 automobile）

**返回值：** `Future<List<RouteResult>>`

### AppleMapController.calculateETA()

仅计算预计到达时间和距离，不包含完整路线坐标。

**参数：**
- `origin: LatLng` - 起点坐标（必需）
- `destination: LatLng` - 终点坐标（必需）
- `transportType: RouteTransportType` - 交通方式（可选，默认 automobile）

**返回值：** `Future<Map<String, dynamic>>`
- `distance: double` - 距离（米）
- `expectedTravelTime: double` - 时间（秒）
- `transportType: String` - 交通方式

## 数据模型

### RouteResult

路线计算结果。

**属性：**
```dart
class RouteResult {
  final double distance;                 // 距离（米）
  final double expectedTravelTime;       // 时间（秒）
  final List<LatLng> coordinates;        // 路线坐标点
  final List<RouteStep>? steps;          // 导航步骤（可选）
  final String? name;                    // 路线名称（可选）
  final String transportType;            // 交通方式
  
  // 便捷方法
  double get distanceKm;                 // 距离（公里）
  double get distanceMiles;              // 距离（英里）
  int get durationMinutes;               // 时间（分钟）
  double get durationHours;              // 时间（小时）
  
  String formatDistance({bool useMetric = true});  // 格式化距离
  String formatDuration();                         // 格式化时间
}
```

### RouteStep

导航步骤。

**属性：**
```dart
class RouteStep {
  final String instructions;            // 导航指示文本
  final double distance;                 // 该步骤距离（米）
  final List<LatLng>? coordinates;       // 该步骤坐标点
  final String? transportType;           // 该步骤交通方式
  
  double get distanceKm;                 // 距离（公里）
  String formatDistance({bool useMetric = true});
}
```

### RouteTransportType

交通方式枚举。

```dart
enum RouteTransportType {
  automobile,  // 驾车 - 使用机动车道路
  walking,     // 步行 - 避开高速公路，使用人行道
  cycling,     // 骑行 - 使用步行路线近似（MapKit 不原生支持）
  transit,     // 公共交通 - 仅在部分地区可用
  any,         // 任意方式
}
```

**重要说明：**

- **骑行模式**：MapKit 在 **iOS 17+** 原生支持骑行路线（参考 [Apple Maps 功能](https://developer.apple.com/cn/maps/)）。
  - ✅ iOS 17.0 及以上：使用原生 `.cycling` 类型
  - ⚠️ iOS 17.0 以下：自动降级为步行路线
  - ⚠️ **地区限制**：骑行路线的可用性和准确性因地区而异，某些地区数据可能不完整
  
- **公共交通限制**：公共交通路线仅在以下地区可用：
  - ✅ 美国、加拿大主要城市
  - ✅ 欧洲主要城市
  - ✅ 日本、澳大利亚等部分城市
  - ❌ 中国大陆地区**不支持**

## 高级用法

### 1. 骑行路线计算

MapKit 在 **iOS 17+** 原生支持骑行路线：

```dart
// 计算骑行路线（需要 iOS 17+）
final route = await _mapController!.calculateRoute(
  origin: LatLng(30.6069, 114.4247),
  destination: LatLng(30.5224, 114.3641),
  transportType: RouteTransportType.cycling, // 🚴 骑行
);

print('距离: ${route.formatDistance()}');
print('时间: ${route.formatDuration()}'); // iOS 17+ 返回准确的骑行时间

// 在地图上绘制骑行路线（紫色）
setState(() {
  _polylines = {
    Polyline(
      polylineId: PolylineId('cycling_route'),
      points: route.coordinates,
      color: Colors.purple, // 骑行使用紫色
      width: 5,
    ),
  };
});
```

**重要提示：**

- **iOS 17+**：使用 MapKit 原生的 `.cycling` 交通方式，时间估算准确
- **iOS 17 以下**：自动降级为 `.walking` 模式，需要手动调整时间（÷3-4）

**版本检测示例：**
```dart
// 检查是否在支持原生骑行的设备上
if (Platform.isIOS) {
  // iOS 17+ 使用原生骑行路线
  // iOS 17- 会自动降级为步行路线
  print('骑行路线已请求，实际类型取决于 iOS 版本');
}
```

### 2. 处理导航步骤

```dart
final route = await _mapController!.calculateRoute(
  origin: origin,
  destination: destination,
);

// 遍历导航步骤
if (route.steps != null) {
  for (var i = 0; i < route.steps!.length; i++) {
    final step = route.steps![i];
    print('步骤 ${i + 1}: ${step.instructions}');
    print('  距离: ${step.formatDistance()}');
  }
}
```

### 3. 显示和切换备选路线

```dart
class _RouteExampleState extends State<RouteExample> {
  List<RouteResult> _allRoutes = [];
  int _selectedRouteIndex = 0;

  Future<void> _calculateAlternateRoutes() async {
    try {
      final routes = await _mapController!.calculateAlternateRoutes(
        origin: _origin,
        destination: _destination,
        transportType: _selectedTransportType,
      );
      
      setState(() {
        _allRoutes = routes;
        _selectedRouteIndex = 0;
        
        // 绘制所有路线，选中的路线高亮
        _polylines = routes.asMap().entries.map((entry) {
          final index = entry.key;
          final route = entry.value;
          final isSelected = index == _selectedRouteIndex;
          
          return Polyline(
            polylineId: PolylineId('route_$index'),
            points: route.coordinates,
            color: isSelected
                ? Colors.blue  // 选中路线使用蓝色
                : Colors.grey.withOpacity(0.5),  // 其他路线使用半透明灰色
            width: isSelected ? 5 : 3,
          );
        }).toSet();
      });
      
      // 如果有多条路线，显示备选路线列表
      if (routes.length > 1) {
        _showAlternateRoutesSheet();
      }
    } catch (e) {
      print('备选路线计算失败: $e');
    }
  }

  /// 选择某条备选路线
  void _selectRoute(int index) {
    if (index < 0 || index >= _allRoutes.length) return;
    
    setState(() {
      _selectedRouteIndex = index;
      
      // 更新路线显示
      _polylines = _allRoutes.asMap().entries.map((entry) {
        final routeIndex = entry.key;
        final route = entry.value;
        final isSelected = routeIndex == index;
        
        return Polyline(
          polylineId: PolylineId('route_$routeIndex'),
          points: route.coordinates,
          color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.5),
          width: isSelected ? 5 : 3,
        );
      }).toSet();
    });
  }

  /// 显示备选路线列表的底部表单
  void _showAlternateRoutesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (context, scrollController) {
          return Column(
            children: [
              // 标题
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.alt_route),
                    const SizedBox(width: 12),
                    Text(
                      '备选路线 (${_allRoutes.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              // 路线列表
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _allRoutes.length,
                  itemBuilder: (context, index) {
                    final route = _allRoutes[index];
                    final isSelected = index == _selectedRouteIndex;
                    
                    return ListTile(
                      selected: isSelected,
                      leading: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey,
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
                      title: Row(
                        children: [
                          Icon(Icons.straighten, size: 16),
                          const SizedBox(width: 4),
                          Text(route.formatDistance()),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 4),
                          Text(route.formatDuration()),
                        ],
                      ),
                      subtitle: index > 0 ? _buildComparison(route, _allRoutes[0]) : const Text('推荐路线'),
                      trailing: isSelected ? const Icon(Icons.check_circle) : null,
                      onTap: () {
                        _selectRoute(index);
                        setState(() {}); // 刷新 UI
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建路线对比信息
  Widget _buildComparison(RouteResult route, RouteResult recommended) {
    final distanceDiff = route.distance - recommended.distance;
    final timeDiff = route.expectedTravelTime - recommended.expectedTravelTime;
    
    final comparisons = <String>[];
    if (distanceDiff.abs() > 100) {
      comparisons.add('${distanceDiff > 0 ? '+' : ''}${(distanceDiff / 1000).toStringAsFixed(1)} km');
    }
    if (timeDiff.abs() > 60) {
      comparisons.add('${timeDiff > 0 ? '+' : ''}${(timeDiff / 60).round()} min');
    }
    
    return Text(comparisons.isEmpty ? '相近' : '相比推荐: ${comparisons.join(', ')}');
  }
}
```

**关键功能：**
- ✅ 同时显示多条路线（选中的高亮，其他半透明）
- ✅ 路线对比（距离、时间差异）
- ✅ 点击切换路线
- ✅ 推荐标记（第一条路线）
- ✅ 实时 UI 更新

### 4. 显示路线详细步骤

```dart
void _showRouteDetails(RouteResult route) {
  if (route.steps == null || route.steps!.isEmpty) {
    print('此路线没有详细步骤');
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '路线详情 - ${route.formatDistance()} · ${route.formatDuration()}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // 步骤列表
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: route.steps!.length,
                itemBuilder: (context, index) {
                  final step = route.steps![index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(step.instructions),
                    subtitle: Text(step.formatDistance()),
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );
}
```

### 5. 调整视图以显示路线

```dart
void _fitRouteToBounds(List<LatLng> coordinates) {
  if (coordinates.isEmpty) return;
  
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
    CameraUpdate.newLatLngBounds(bounds, 50),  // 50 像素边距
  );
}
```

### 6. 根据交通方式选择颜色和图标

```dart
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

// 使用
final polyline = Polyline(
  polylineId: PolylineId('route'),
  points: route.coordinates,
  color: _getColorForTransportType(route.transportType),
  width: 5,
);
```


## 性能优化

### 1. 使用 ETA 代替完整路线计算

如果只需要距离和时间信息：

```dart
// ❌ 慢 - 返回完整路线坐标
final route = await controller.calculateRoute(origin, destination);
print('时间: ${route.durationMinutes} 分钟');

// ✅ 快 - 仅返回 ETA 信息
final eta = await controller.calculateETA(origin, destination);
print('时间: ${eta['expectedTravelTime'] / 60} 分钟');
```

### 2. 缓存路线结果

```dart
class RouteCache {
  final Map<String, RouteResult> _cache = {};
  
  String _getCacheKey(LatLng origin, LatLng dest, RouteTransportType type) {
    return '${origin.latitude},${origin.longitude}-'
           '${dest.latitude},${dest.longitude}-${type.toValue()}';
  }
  
  RouteResult? get(LatLng origin, LatLng dest, RouteTransportType type) {
    return _cache[_getCacheKey(origin, dest, type)];
  }
  
  void put(LatLng origin, LatLng dest, RouteTransportType type, RouteResult route) {
    _cache[_getCacheKey(origin, dest, type)] = route;
  }
}
```

### 3. 防抖动

避免频繁计算路线：

```dart
Timer? _debounceTimer;

void _calculateRouteDebounced() {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 500), () {
    _calculateRoute();
  });
}
```

## 示例代码

完整的示例代码请参考：
- `example/lib/route_calculation_example.dart` - 完整的路线计算示例
  - 交通方式选择器
  - 路线绘制
  - 详细步骤查看
  - 备选路线显示
  - 错误处理
  - 视图自动调整

## 更新日志

### v1.2.0 (2024-11-10)
- 🐛 **修正骑行路线实现** - 使用 MapKit 原生 `.cycling` 类型（iOS 17+）
- ✨ 添加 iOS 版本适配 - iOS 17 以下自动降级为步行路线
- 📝 更新文档说明骑行路线的地区限制和版本要求

### v1.1.0 (2024-11-10)
- ✨ 新增骑行路线计算
- ✨ 增强错误处理，提供详细的错误信息和建议
- ✨ 添加路线详细步骤显示 UI
- 🐛 修复类型转换错误
- 📝 完善文档和示例

### v1.0.0 (2024-11-10)
- ✨ 新增路线计算功能
- ✨ 支持单条路线和多条备选路线
- ✨ 支持驾车、步行、公交三种交通方式
- ✨ 提供详细的导航步骤信息

