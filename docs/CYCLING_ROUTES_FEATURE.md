# 骑行路线功能说明

## 功能概述

已添加**骑行路线**计算功能到 `apple_maps_flutter` 包中。用户现在可以选择骑行作为交通方式来计算路线。

## ⚠️ 重要说明

### MapKit 限制

**Apple MapKit 不原生支持骑行路线计算。**

iOS 的 `MKDirections` API 只支持以下交通方式：
- ✅ `automobile`（驾车）
- ✅ `walking`（步行）
- ✅ `transit`（公共交通）
- ❌ **不支持** `cycling`（骑行）

### 实现方案

为了提供骑行路线功能，我们采用了**近似方案**：

```swift
case "cycling", "bicycle":
  // MapKit 不原生支持骑行路线，使用步行模式作为近似
  // 骑行路线和步行路线都避开高速公路，适合非机动车
  return .walking
```

**工作原理：**
1. 当用户选择"骑行"时，Dart 端发送 `"cycling"` 参数
2. iOS 原生端接收后映射到 `MKDirectionsTransportType.walking`
3. MapKit 使用步行路线算法计算路线
4. 返回的路线数据标记为 `cycling`（保留用户选择）

## 为什么使用步行路线近似？

### 相似性

骑行路线和步行路线有很多共同特点：

| 特性 | 骑行 | 步行 | 驾车 |
|-----|------|------|------|
| **避开高速公路** | ✅ | ✅ | ❌ |
| **使用自行车道** | ✅ | 部分 | ❌ |
| **使用人行道** | 部分 | ✅ | ❌ |
| **适合非机动车** | ✅ | ✅ | ❌ |
| **避开隧道** | 大多数 | 大多数 | ❌ |

### 差异

然而，骑行路线和步行路线也有区别：

| 差异点 | 骑行 | 步行路线近似 |
|-------|------|-------------|
| **平均速度** | 15-20 km/h | 5 km/h |
| **距离限制** | 可远距离 | 较短距离 |
| **坡度考虑** | 重要 | 一般 |
| **自行车专用道** | 优先 | 可能不选择 |
| **楼梯/人行天桥** | 避免 | 可能选择 |

## 使用方法

### Dart 代码

```dart
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

// 计算骑行路线
final route = await controller.calculateRoute(
  origin: LatLng(30.6069, 114.4247),
  destination: LatLng(30.5224, 114.3641),
  transportType: RouteTransportType.cycling, // 🚴 选择骑行
);

print('距离: ${route.formatDistance()}');
print('时间: ${route.formatDuration()}');
print('交通方式: ${route.transportType}'); // 输出: "cycling"
```

### UI 显示

骑行选项会显示在交通方式选择器中：

```
🚗 驾车  |  🚶 步行  |  🚴 骑行  |  🚌 公交
```

- **图标**：`Icons.directions_bike` 🚴
- **颜色**：紫色 (Purple)
- **显示名称**：骑行

## 功能特性

### ✅ 已实现

1. **路线计算**
   - 计算单条骑行路线
   - 计算多条备选骑行路线
   - 计算骑行 ETA（预计到达时间）

2. **UI 支持**
   - 骑行选项按钮
   - 骑行路线地图绘制（紫色折线）
   - 骑行图标和颜色
   - 路线详细步骤显示

3. **数据模型**
   - `RouteTransportType.cycling` 枚举值
   - 正确的类型标识和显示名称
   - 完整的序列化/反序列化支持

### ⚠️ 限制

1. **不是真实的骑行路线**
   - 使用步行路线近似
   - 可能包含不适合骑行的路段（如楼梯）
   - 不考虑自行车专用道

2. **时间估算不准确**
   - 使用步行速度计算（5 km/h）
   - 实际骑行速度通常为 15-20 km/h
   - 需要手动调整时间估算

3. **区域支持**
   - 与步行路线相同的区域限制
   - 在某些地区可能无法获取路线

## 时间调整建议

由于使用步行路线近似，返回的时间估算偏长。建议应用以下调整：

### 方法 1：直接调整时间

```dart
// 获取路线后调整时间
final route = await controller.calculateRoute(
  origin: origin,
  destination: destination,
  transportType: RouteTransportType.cycling,
);

// 步行时间除以 3-4 倍作为骑行时间
final adjustedTime = route.expectedTravelTime / 3.5;

print('原始时间（步行）: ${route.formatDuration()}');
print('调整后时间（骑行）: ${_formatSeconds(adjustedTime)}');
```

### 方法 2：基于距离估算

```dart
// 使用距离和平均速度重新计算时间
const double averageCyclingSpeed = 18.0; // km/h
final estimatedTime = (route.distance / 1000) / averageCyclingSpeed * 3600;

print('基于距离估算的骑行时间: ${_formatSeconds(estimatedTime)}');
```

### 方法 3：创建自定义包装类

```dart
class CyclingRouteResult {
  final RouteResult originalRoute;
  
  CyclingRouteResult(this.originalRoute);
  
  // 调整后的时间（步行时间 / 3.5）
  double get adjustedTravelTime => originalRoute.expectedTravelTime / 3.5;
  
  String formatAdjustedDuration() {
    final minutes = (adjustedTravelTime / 60).round();
    if (minutes < 60) {
      return '$minutes 分钟';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours 小时 $remainingMinutes 分钟';
    }
  }
}

// 使用
final route = await controller.calculateRoute(...);
final cyclingRoute = CyclingRouteResult(route);
print('骑行时间: ${cyclingRoute.formatAdjustedDuration()}');
```

## 替代方案

如果需要真实的骑行路线，考虑以下替代方案：

### 1. Google Maps Directions API

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

Future<Map> getCyclingRoute(LatLng origin, LatLng destination) async {
  final url = 'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}&'
      'destination=${destination.latitude},${destination.longitude}&'
      'mode=bicycling&' // 🚴 真正的骑行模式
      'key=YOUR_API_KEY';
  
  final response = await http.get(Uri.parse(url));
  return json.decode(response.body);
}
```

**优点：**
- ✅ 真实的骑行路线算法
- ✅ 考虑自行车专用道
- ✅ 准确的时间估算
- ✅ 坡度和地形考虑

**缺点：**
- ❌ 需要 API 密钥和费用
- ❌ 需要额外的 HTTP 请求
- ❌ 在中国大陆可能不可用

### 2. 高德地图

```dart
import 'package:amap_flutter_map/amap_flutter_map.dart';

// 高德地图支持骑行路线
final route = await AMapController.calculateRoute(
  origin: origin,
  destination: destination,
  mode: AMapRouteMode.cycling, // 真正的骑行模式
);
```

**优点：**
- ✅ 真实的骑行路线
- ✅ 中国地区数据准确
- ✅ 考虑本地路况

**缺点：**
- ❌ 仅在中国大陆可用
- ❌ 需要高德地图账号

### 3. OpenStreetMap + OSRM

```dart
// 使用开源路线服务
Future<Map> getCyclingRoute(LatLng origin, LatLng destination) async {
  final url = 'https://router.project-osrm.org/route/v1/bicycle/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}?'
      'overview=full&geometries=geojson';
  
  final response = await http.get(Uri.parse(url));
  return json.decode(response.body);
}
```

**优点：**
- ✅ 免费开源
- ✅ 真实的骑行路线
- ✅ 全球数据

**缺点：**
- ❌ 数据质量可能不如商业方案
- ❌ 需要自己处理路线数据
- ❌ 服务器可能不稳定

## 最佳实践

### 1. 提示用户限制

在 UI 中添加说明：

```dart
if (_selectedTransportType == RouteTransportType.cycling) {
  return InfoWidget(
    icon: Icons.info_outline,
    message: '骑行路线使用步行路线近似计算，'
             '实际路线和时间可能有所不同。'
             '建议时间约为显示时间的 1/3。',
  );
}
```

### 2. 距离限制建议

骑行路线适合中短距离：

```dart
void _validateCyclingDistance(double distance) {
  if (distance > 50000) { // 超过 50 公里
    showWarningDialog(
      '建议骑行距离在 50 公里以内。'
      '长距离骑行建议使用专业骑行导航应用。'
    );
  }
}
```

### 3. 自定义路线优化

如果需要更好的骑行体验：

```dart
// 检查路线是否包含不适合骑行的路段
void _checkRouteForCycling(RouteResult route) {
  for (var step in route.steps ?? []) {
    if (step.instructions.contains('stairs') || 
        step.instructions.contains('楼梯')) {
      print('⚠️ 警告：路线包含楼梯，不适合骑行');
    }
  }
}
```

## 测试建议

### 测试场景

1. **短距离骑行**（< 5 公里）
   ```dart
   // 应该能正常计算
   final route = await calculateCyclingRoute(
     distance: 3000, // 3 公里
   );
   expect(route, isNotNull);
   ```

2. **中距离骑行**（5-20 公里）
   ```dart
   // 最适合的距离范围
   final route = await calculateCyclingRoute(
     distance: 15000, // 15 公里
   );
   expect(route.coordinates.length, greaterThan(50));
   ```

3. **长距离骑行**（> 20 公里）
   ```dart
   // 可能不太准确，建议提示用户
   final route = await calculateCyclingRoute(
     distance: 50000, // 50 公里
   );
   // 显示警告
   ```

## 常见问题

### Q: 为什么骑行路线和步行路线看起来一样？

A: 因为底层使用的就是步行路线算法。唯一的区别是：
- 标记为 "cycling" 类型
- UI 显示骑行图标和颜色
- 可以根据需要调整时间估算

### Q: 时间估算为什么这么长？

A: MapKit 使用步行速度（约 5 km/h）计算的。实际骑行速度通常是步行的 3-4 倍。建议将显示时间除以 3-4。

### Q: 路线会避开高速公路吗？

A: 是的。步行路线（也就是我们用的算法）会自动避开高速公路和机动车专用道。

### Q: 能否显示自行车专用道？

A: 不能。MapKit 的步行路线不会特别标识自行车专用道。如需此功能，建议使用 Google Maps 或高德地图。

### Q: 在哪些地区可用？

A: 与步行路线相同的地区。基本上全球大部分地区都支持，但偏远地区可能数据不完整。

## 代码示例

### 完整的骑行路线计算示例

```dart
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

class CyclingRouteExample extends StatefulWidget {
  @override
  _CyclingRouteExampleState createState() => _CyclingRouteExampleState();
}

class _CyclingRouteExampleState extends State<CyclingRouteExample> {
  AppleMapController? _controller;
  RouteResult? _route;

  Future<void> _calculateCyclingRoute() async {
    try {
      final route = await _controller!.calculateRoute(
        origin: LatLng(30.6069, 114.4247),
        destination: LatLng(30.5224, 114.3641),
        transportType: RouteTransportType.cycling,
      );
      
      setState(() {
        _route = route;
      });
      
      // 调整时间估算
      final adjustedTime = route.expectedTravelTime / 3.5;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.directions_bike, color: Colors.purple),
              SizedBox(width: 8),
              Text('骑行路线'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('距离: ${route.formatDistance()}'),
              Text('步行时间: ${route.formatDuration()}'),
              Divider(),
              Text(
                '预计骑行时间: ${_formatSeconds(adjustedTime)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'ℹ️ 使用步行路线近似计算',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('确定'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('计算骑行路线失败: $e');
    }
  }

  String _formatSeconds(double seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) {
      return '$minutes 分钟';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours 小时 $remainingMinutes 分钟';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppleMap(
        onMapCreated: (controller) {
          _controller = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(30.5650, 114.3939),
          zoom: 12,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _calculateCyclingRoute,
        child: Icon(Icons.directions_bike),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
```

## 总结

✅ **已实现：**
- 骑行路线类型枚举
- UI 选择器和图标
- 路线计算功能
- 地图显示

⚠️ **限制：**
- 使用步行路线近似
- 时间估算需要手动调整
- 不考虑自行车专用道

💡 **建议：**
- 适合短中距离骑行（< 20km）
- 提示用户这是近似计算
- 时间调整为显示值的 1/3 - 1/4
- 如需真实骑行导航，使用 Google Maps 或高德地图

## 参考资源

- [Apple MapKit Documentation](https://developer.apple.com/documentation/mapkit)
- [MKDirections TransportType](https://developer.apple.com/documentation/mapkit/mkdirections/request/transporttype)
- [Google Maps Directions API - Bicycling](https://developers.google.com/maps/documentation/directions/get-directions#TravelModes)
- [高德地图骑行路线规划](https://lbs.amap.com/api/webservice/guide/api/direction#riding)

