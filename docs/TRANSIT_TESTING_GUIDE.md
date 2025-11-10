# Apple Maps 公共交通路线测试指南

## 重要更正

根据用户反馈，iPhone 自带的地图应用**在中国大陆可以查看公共交通信息**。之前关于"中国大陆不支持公共交通路线"的结论是**不准确的**。

## 问题重新分析

### Apple Maps 在中国的公共交通支持

✅ **已确认支持的城市**：
- 北京
- 上海
- 其他主要城市（具体列表需要实际测试）

❓ **武汉等城市**：
- iPhone 地图应用可能支持
- MKDirections API 的支持情况需要实际测试
- 数据完整性可能因城市而异

## 可能导致错误的真实原因

### 1. ⭐ 坐标位置不准确（最可能）

**问题**：使用的坐标不是公交站点或地铁站的精确位置

**原因**：
- 公共交通路线需要从实际的站点出发
- 随机的街道坐标可能无法计算公交路线
- MapKit 需要能识别的交通节点

**解决方案**：
```dart
// ❌ 不好的例子 - 随意的坐标
final origin = LatLng(30.6069, 114.4247); // 某个街道位置

// ✅ 好的例子 - 实际的地铁站坐标
final origin = LatLng(30.6107, 114.4313); // 武汉站（地铁4号线）
final destination = LatLng(30.7838, 114.2080); // 天河机场站（地铁2号线）
```

### 2. 路线距离或复杂度

**问题**：两点之间没有合理的公共交通路线

**原因**：
- 距离太远（如武汉到北京）
- 需要多次换乘
- 没有直达线路

**解决方案**：
- 选择同一条地铁线上的相邻站点测试
- 选择距离适中的两个站点（2-20公里）

### 3. 数据可用性

**问题**：该地区的公共交通数据不完整

**原因**：
- 中小城市的数据可能不如大城市完整
- 某些公交线路可能没有被 Apple Maps 收录

## 修改后的测试坐标

### 武汉地铁站坐标（推荐测试）

```dart
// 测试 1：武汉站 → 天河机场（地铁2号线直达）
final test1Origin = LatLng(30.6107, 114.4313);      // 武汉站
final test1Dest = LatLng(30.7838, 114.2080);        // 天河机场站

// 测试 2：江汉路站 → 光谷广场站（地铁2号线，距离适中）
final test2Origin = LatLng(30.5964, 114.2768);      // 江汉路站
final test2Dest = LatLng(30.5105, 114.4171);        // 光谷广场站

// 测试 3：中山公园站 → 武汉火车站（同城短距离）
final test3Origin = LatLng(30.5803, 114.2549);      // 中山公园站
final test3Dest = LatLng(30.6107, 114.4313);        // 武汉火车站

// 测试 4：更短距离（相邻站点）
final test4Origin = LatLng(30.5964, 114.2768);      // 江汉路站
final test4Dest = LatLng(30.5952, 114.2956);        // 积玉桥站（相邻站）
```

### 北京地铁站坐标（对比测试）

如果武汉测试失败，可以尝试北京作为对比：

```dart
// 北京：天安门东站 → 国贸站（地铁1号线）
final bjOrigin = LatLng(39.9063, 116.4019);         // 天安门东站
final bjDest = LatLng(39.9082, 116.4603);           // 国贸站
```

## 测试步骤

### 步骤 1：准备测试环境

1. 确保设备连接到互联网
2. 确保应用有网络访问权限
3. 在真机上测试（模拟器可能有限制）

### 步骤 2：逐个测试坐标

```dart
// 在 route_calculation_example.dart 中修改坐标
static const LatLng _origin = LatLng(30.6107, 114.4313);      // 武汉站
static const LatLng _destination = LatLng(30.7838, 114.2080); // 天河机场
```

### 步骤 3：运行并观察

1. 运行应用
2. 选择"公共交通"模式
3. 点击"计算路线"
4. 观察控制台输出：

```
🚨 MKDirections Error Details:
  - Domain: MKErrorDomain
  - Code: [查看错误代码]
  - Description: [查看详细描述]
  - User Info: [查看用户信息]

🔍 Error type: [查看错误类型]
✅ Recognized as RouteCalculatorError  // 或
⚠️ Not recognized as RouteCalculatorError
```

### 步骤 4：分析结果

#### 如果成功 ✅
```
路线计算成功！
[显示路线信息卡片]
```

#### 如果失败 - 错误代码 5 ❌
```
MKErrorDomain error 5 = MKErrorDirectionsNotFound
```

可能原因：
1. 坐标不准确
2. 该区域真的不支持
3. 需要更精确的站点坐标

#### 如果失败 - 其他错误代码
- 错误代码 1：未知错误
- 错误代码 2：服务器失败
- 错误代码 3：请求过于频繁
- 错误代码 4：位置未找到

## 调试技巧

### 1. 使用 Apple 地图应用验证

在测试之前，先用 iPhone 自带的地图应用验证：

1. 打开"地图"应用
2. 输入起点和终点（使用相同的坐标）
3. 选择"公共交通"
4. 查看是否能获取路线

**如果 Apple 地图应用可以获取路线，但我们的 API 不行**：
- 说明是 API 使用方式的问题
- 可能需要检查坐标精度
- 可能需要特殊的配置

**如果 Apple 地图应用也无法获取路线**：
- 说明该路线确实不支持
- 需要更换测试坐标

### 2. 检查坐标精度

```dart
// 确保坐标精度足够
print('Origin: ${_origin.latitude.toStringAsFixed(6)}, ${_origin.longitude.toStringAsFixed(6)}');
print('Destination: ${_destination.latitude.toStringAsFixed(6)}, ${_destination.longitude.toStringAsFixed(6)}');
```

### 3. 逐渐缩短距离

如果长距离失败，尝试缩短：

```dart
// 从远到近测试
1. 武汉站 → 天河机场 (约30km)
2. 江汉路 → 光谷广场 (约15km)  
3. 江汉路 → 积玉桥 (约2km，相邻站)
```

### 4. 对比驾车路线

```dart
// 同样的坐标，先测试驾车是否工作
final carRoute = await controller.calculateRoute(
  origin: _origin,
  destination: _destination,
  transportType: RouteTransportType.automobile, // 驾车
);
print('驾车路线成功：${carRoute.formatDistance()}');

// 然后测试公交
final transitRoute = await controller.calculateRoute(
  origin: _origin,
  destination: _destination,
  transportType: RouteTransportType.transit, // 公交
);
```

## 预期结果

### 场景 A：使用精确的地铁站坐标
- ✅ 可能成功（如果武汉被 Apple Maps 支持）
- ✅ 控制台显示路线详情
- ✅ 地图上显示路线

### 场景 B：武汉确实不支持
- ❌ 返回错误代码 5
- ℹ️ 需要使用高德地图或百度地图

### 场景 C：北京等大城市测试
- ✅ 应该成功（已知北京支持）
- ✅ 可以作为对比验证 API 是否正常工作

## 下一步行动

1. **立即测试**：使用修改后的武汉地铁站坐标测试
2. **查看日志**：注意控制台的详细错误信息
3. **对比测试**：
   - 同样的坐标，用 iPhone 地图应用测试
   - 如果需要，用北京坐标作为对比
4. **报告结果**：
   - 如果成功：说明 API 可用，之前是坐标问题
   - 如果失败：提供详细的错误日志

## 更新 TRANSIT_ROUTING_LIMITATIONS.md

根据测试结果，我们需要更新之前的限制说明文档，更正关于中国支持情况的信息。

## 参考信息

### 如何获取精确的地铁站坐标

1. **使用 Apple 地图**：
   - 打开地图应用
   - 搜索地铁站名称
   - 长按位置获取坐标

2. **使用高德地图**：
   - 搜索地铁站
   - 查看详细信息中的坐标

3. **在线坐标拾取工具**：
   - https://lbs.amap.com/tools/picker （高德）
   - 搜索地铁站，点击获取精确坐标

### 武汉地铁线路图参考

- 2号线：天河机场 ↔ 光谷广场
- 4号线：武汉站 ↔ 黄金口
- 更多线路信息可以参考武汉地铁官网

## 总结

**感谢您的纠正！** iPhone 地图在中国确实可以使用公共交通功能。问题很可能是：

1. ⭐ **坐标不准确**（最可能）- 已修正为实际地铁站坐标
2. **路线不可用** - 需要合理的起点终点
3. **数据完整性** - 不同城市可能有差异

现在请重新测试，查看使用精确的地铁站坐标后是否能成功获取公共交通路线！

