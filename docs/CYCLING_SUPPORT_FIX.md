# 骑行路线支持修正

## 问题描述

之前的实现错误地认为 MapKit 不支持骑行路线，将 `cycling` 映射到了 `walking` 模式。

## 正确的实现

根据 [Apple 官方文档](https://developer.apple.com/cn/maps/) 和 [MKDirectionsTransportType 文档](https://developer.apple.com/documentation/mapkit/mkdirectionstransporttype)，MapKit **在 iOS 17+ 原生支持** `.cycling` 交通方式。

## 修改内容

### 1. iOS 原生代码 (Swift)

#### `AppleMapController.swift`

```swift
private func parseTransportType(_ typeString: String) -> MKDirectionsTransportType {
  switch typeString.lowercased() {
  case "automobile", "driving":
    return .automobile
  case "walking":
    return .walking
  case "cycling", "bicycle":
    // iOS 17+ 支持骑行路线
    // 注意：骑行路线的可用性因地区而异
    if #available(iOS 17.0, *) {
      return .cycling
    } else {
      // iOS 17 以下版本使用步行路线近似
      return .walking
    }
  case "transit":
    return .transit
  case "any":
    return .any
  default:
    return .automobile
  }
}
```

#### `RouteCalculator.swift`

```swift
private func transportTypeToString(_ type: MKDirectionsTransportType) -> String {
  switch type {
  case .automobile:
    return "automobile"
  case .walking:
    return "walking"
  case .transit:
    return "transit"
  default:
    // iOS 17+ 支持 .cycling
    if #available(iOS 17.0, *) {
      if type == .cycling {
        return "cycling"
      }
    }
    return "any"
  }
}
```

#### `RouteResult.swift`

```swift
// 步骤的交通类型处理
switch step.transportType {
case .automobile:
  stepDict["transportType"] = "automobile"
case .walking:
  stepDict["transportType"] = "walking"
case .transit:
  stepDict["transportType"] = "transit"
default:
  // iOS 17+ 支持 .cycling
  if #available(iOS 17.0, *) {
    if step.transportType == .cycling {
      stepDict["transportType"] = "cycling"
    } else {
      stepDict["transportType"] = "any"
    }
  } else {
    stepDict["transportType"] = "any"
  }
}
```

### 2. 示例应用

#### `route_calculation_example.dart`

```dart
// 检查是否是骑行路线（提示用户地区限制）
if (_selectedTransportType == RouteTransportType.cycling) {
  if (errorDetails != null) {
    errorDetails['cyclingNote'] = true;
    errorDetails['cyclingMessage'] = 
        'iOS 17+ 支持骑行路线，但数据完整性因地区而异。\n'
        'iOS 17 以下会自动降级为步行路线。';
  }
}
```

### 3. 文档更新

更新了 `route_calculation_guide.md`，说明：
- iOS 17+ 原生支持 `.cycling`
- iOS 17 以下自动降级为 `.walking`
- 骑行路线数据的地区限制
- 数据完整性因地区而异

## 重要说明

### iOS 版本要求
- ✅ **iOS 17.0+**：使用 MapKit 原生 `.cycling` 类型
- ⚠️ **iOS 17.0 以下**：自动降级为 `.walking` 模式

### 地区限制

骑行路线的可用性和数据完整性因地区而异：

| 地区 | 数据状态 | 说明 |
|------|---------|------|
| 🇺🇸 美国 | ✅ 完整 | 完整的骑行路线和自行车道数据 |
| 🇨🇦 加拿大 | ✅ 完整 | 主要城市数据完善 |
| 🇪🇺 西欧 | ✅ 完整 | 英、法、德等国家数据完善 |
| 🇯🇵 日本 | ⚠️ 部分 | 部分城市有数据 |
| 🇨🇳 中国 | ❌ 有限 | 数据不完整，建议使用本地地图服务 |

参考：[Apple Maps 功能可用性](https://www.apple.com/ios/feature-availability/#maps-cycling)

### 推荐做法

**对于中国用户：**
- 建议使用高德地图或百度地图的骑行路线 API
- 这些本地服务提供更准确和完整的骑行数据

**对于国际用户：**
- iOS 17+ 设备：直接使用 MapKit 的 `.cycling`
- 检查用户所在地区是否支持骑行路线
- 提供适当的用户提示

## API 使用示例

```dart
// 请求骑行路线
final route = await _mapController!.calculateRoute(
  origin: LatLng(37.7749, -122.4194), // 旧金山
  destination: LatLng(37.8044, -122.2712), // 奥克兰
  transportType: RouteTransportType.cycling,
);

// iOS 17+ 返回准确的骑行时间和路线
print('距离: ${route.formatDistance()}');
print('时间: ${route.formatDuration()}');

// 绘制路线
setState(() {
  _polylines = {
    Polyline(
      polylineId: PolylineId('cycling_route'),
      points: route.coordinates,
      color: Colors.purple,
      width: 5,
    ),
  };
});
```

## 相关资源

- [Apple Maps Features](https://developer.apple.com/cn/maps/)
- [MKDirectionsTransportType Documentation](https://developer.apple.com/documentation/mapkit/mkdirectionstransporttype)
- [Apple Maps Feature Availability](https://www.apple.com/ios/feature-availability/#maps-cycling)
- [高德地图骑行路径规划 API](https://lbs.amap.com/api/webservice/guide/api/direction)

## 致谢

感谢用户指出这个错误，促使我们查阅官方文档并正确实现了骑行路线功能。

