# Apple Maps 公共交通路线限制说明

## 问题描述

在使用 `apple_maps_flutter` 的路线计算功能时，您可能会遇到以下情况：

- ✅ **驾车路线（automobile）**：正常工作
- ✅ **步行路线（walking）**：正常工作
- ❌ **公共交通路线（transit）**：返回错误码 5（MKErrorDirectionsNotFound）

## 根本原因

这**不是代码的 bug**，而是 **Apple Maps 服务的地区限制**。

### Apple Maps 公共交通路线的可用性

Apple Maps 的公共交通路线功能仅在以下地区可用：

#### ✅ 完全支持的地区

**北美洲：**
- 🇺🇸 美国（主要城市）
  - 纽约、旧金山、洛杉矶、芝加哥、波士顿、华盛顿等
- 🇨🇦 加拿大（主要城市）
  - 多伦多、温哥华、蒙特利尔等

**欧洲：**
- 🇬🇧 英国（伦敦及主要城市）
- 🇩🇪 德国（柏林、慕尼黑等）
- 🇫🇷 法国（巴黎及主要城市）
- 🇮🇹 意大利（罗马、米兰等）
- 其他欧洲主要城市

**亚洲：**
- 🇯🇵 日本（东京、大阪、京都等）
- 🇦🇺 澳大利亚（悉尼、墨尔本等）

#### ❌ 不支持的地区

- 🇨🇳 **中国大陆**（包括所有城市，如北京、上海、武汉等）
- 大部分发展中国家
- 小城市和乡村地区

### 技术细节

当在不支持的地区请求公共交通路线时：

```swift
// iOS MapKit 返回
MKError.directionsNotFound (错误码 5)
Domain: MKErrorDomain
Description: "The operation couldn't be completed."
```

这表示 Apple Maps 服务器没有该地区的公共交通数据。

## 错误表现

### 典型错误信息

```
路线计算失败
The operation couldn't be completed. (MKErrorDomain error 5.)

详细信息:
- errorType: UNKNOWN 或 NO_ROUTE_FOUND
- code: 5
- domain: MKErrorDomain
- message: 找不到路线
```

### 增强后的错误提示

修复后，当检测到公共交通路线错误时，会显示：

```
公共交通路线不可用

⚠️ Apple Maps 公共交通路线限制说明：

• 公共交通路线仅在部分地区可用
• 主要支持的地区：
  - 美国、加拿大主要城市
  - 欧洲主要城市
  - 日本、澳大利亚等部分城市

• 中国大陆地区暂不支持公共交通路线
• 建议切换到"驾车"或"步行"模式

💡 替代方案：
• 使用高德地图、百度地图等本地地图服务
• 使用 Google Maps（需要在支持的地区）
```

## 解决方案

### 1. 推荐方案：切换交通方式

```dart
// 使用驾车或步行模式
final route = await controller.calculateRoute(
  origin: origin,
  destination: destination,
  transportType: RouteTransportType.automobile, // 或 walking
);
```

### 2. 使用本地地图服务

对于中国大陆地区，推荐使用：

#### 高德地图
```yaml
dependencies:
  amap_flutter_map: ^latest_version
```

特点：
- ✅ 完整的公共交通路线支持
- ✅ 详细的站点和换乘信息
- ✅ 实时公交到站信息

#### 百度地图
```yaml
dependencies:
  flutter_baidu_mapapi_map: ^latest_version
```

特点：
- ✅ 公共交通路线支持
- ✅ 地铁、公交、步行组合路线
- ✅ 详细的导航指引

### 3. 条件性使用不同服务

```dart
RouteTransportType _getAvailableTransportType(
  RouteTransportType preferred,
  LatLng location,
) {
  // 检查地区
  if (preferred == RouteTransportType.transit) {
    if (_isInChinaMainland(location)) {
      // 在中国大陆，改用驾车或提示用户使用本地地图
      return RouteTransportType.automobile;
    } else if (!_isInSupportedTransitRegion(location)) {
      // 在其他不支持的地区，改用驾车
      return RouteTransportType.automobile;
    }
  }
  return preferred;
}

bool _isInChinaMainland(LatLng location) {
  // 粗略检查（实际应该更精确）
  return location.latitude >= 18.0 && 
         location.latitude <= 54.0 &&
         location.longitude >= 73.0 && 
         location.longitude <= 135.0;
}
```

## 实现建议

### 1. UI 层面的处理

**方案 A：隐藏不可用选项**
```dart
List<RouteTransportType> getAvailableTransportTypes(LatLng location) {
  final types = [
    RouteTransportType.automobile,
    RouteTransportType.walking,
  ];
  
  // 只在支持的地区显示公共交通选项
  if (isTransitAvailable(location)) {
    types.add(RouteTransportType.transit);
  }
  
  return types;
}
```

**方案 B：显示但禁用**
```dart
SegmentedButton(
  segments: [
    ButtonSegment(
      value: RouteTransportType.automobile,
      label: Text('驾车'),
      icon: Icon(Icons.directions_car),
    ),
    ButtonSegment(
      value: RouteTransportType.transit,
      label: Text('公交'),
      icon: Icon(Icons.directions_transit),
      enabled: isTransitAvailable(currentLocation), // 根据地区启用/禁用
    ),
  ],
  // ...
)
```

**方案 C：显示警告图标**
```dart
ListTile(
  leading: Icon(Icons.directions_transit),
  title: Text('公共交通'),
  trailing: !isTransitAvailable(currentLocation)
      ? Tooltip(
          message: '当前地区不支持',
          child: Icon(Icons.warning_amber, color: Colors.orange),
        )
      : null,
  enabled: isTransitAvailable(currentLocation),
)
```

### 2. 优雅的错误处理

```dart
Future<RouteResult?> calculateRouteWithFallback({
  required LatLng origin,
  required LatLng destination,
  required RouteTransportType transportType,
}) async {
  try {
    return await controller.calculateRoute(
      origin: origin,
      destination: destination,
      transportType: transportType,
    );
  } on PlatformException catch (e) {
    if (transportType == RouteTransportType.transit && 
        e.code == 'NO_ROUTE_FOUND') {
      // 自动降级到驾车模式
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('公共交通路线不可用'),
          content: Text('当前地区不支持公共交通路线。是否切换到驾车模式？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                calculateRouteWithFallback(
                  origin: origin,
                  destination: destination,
                  transportType: RouteTransportType.automobile,
                );
              },
              child: Text('切换'),
            ),
          ],
        ),
      );
    }
    return null;
  }
}
```

### 3. 预检查机制

```dart
Future<bool> isTransitAvailableForRoute({
  required LatLng origin,
  required LatLng destination,
}) async {
  // 方案 1: 基于地理位置的粗略判断
  if (_isInChinaMainland(origin) || _isInChinaMainland(destination)) {
    return false;
  }
  
  // 方案 2: 尝试快速 ETA 计算来验证
  try {
    await controller.calculateETA(
      origin: origin,
      destination: destination,
      transportType: RouteTransportType.transit,
    );
    return true;
  } catch (e) {
    return false;
  }
}
```

## 测试建议

### 测试不同地区

1. **支持的地区测试**
   ```dart
   // 旧金山湾区（支持）
   final sfOrigin = LatLng(37.7749, -122.4194);
   final sfDest = LatLng(37.8044, -122.2712);
   ```

2. **不支持的地区测试**
   ```dart
   // 武汉（不支持）
   final whOrigin = LatLng(30.6069, 114.4247);
   final whDest = LatLng(30.5224, 114.3641);
   ```

3. **跨地区测试**
   ```dart
   // 从支持地区到不支持地区
   final crossRegionOrigin = LatLng(37.7749, -122.4194); // 旧金山
   final crossRegionDest = LatLng(30.5224, 114.3641);    // 武汉
   ```

## 参考资源

- [Apple Maps Feature Availability](https://www.apple.com/ios/feature-availability/#maps-transit)
- [MKDirections Documentation](https://developer.apple.com/documentation/mapkit/mkdirections)
- [MKError Codes](https://developer.apple.com/documentation/mapkit/mkerror)

## 常见问题

### Q: 为什么中国地区不支持？
A: Apple Maps 在中国使用高德地图的数据，但公共交通数据需要额外的授权和集成，目前尚未完全开放。

### Q: 未来会支持更多地区吗？
A: Apple 持续扩展 Maps 的覆盖范围，但具体时间表由 Apple 决定。建议查看官方的 [Feature Availability](https://www.apple.com/ios/feature-availability/) 页面。

### Q: 有办法强制启用吗？
A: 没有。这是服务器端的限制，无法通过客户端代码绕过。

### Q: 为什么显示 UNKNOWN 而不是 NO_ROUTE_FOUND？
A: 这可能是错误映射的问题。我们已经添加了调试日志来帮助诊断：
```
🔍 Error type: RouteCalculatorError
🔍 Error: noRouteFound(...)
✅ Recognized as RouteCalculatorError
```

如果看到 "⚠️ Not recognized as RouteCalculatorError"，则需要进一步调查。

## 总结

- ✅ Apple Maps 公共交通路线功能在部分地区可用
- ❌ 中国大陆地区**暂不支持**
- 💡 推荐使用本地地图服务（高德、百度）
- 🔄 或切换到驾车/步行模式
- 🎯 实现优雅的降级和错误处理


