# 备选路线 UI 功能

## 概述

本次更新为 `apple_maps_flutter` 示例应用添加了完整的备选路线显示和切换功能，提供了直观的 UI 让用户可以对比和选择不同的路线方案。

## 新增功能

### 1. 路线状态管理

```dart
class _RouteCalculationExampleState extends State<RouteCalculationExample> {
  List<RouteResult> _allRoutes = [];      // 存储所有备选路线
  int _selectedRouteIndex = 0;             // 当前选中的路线索引
  RouteResult? _currentRoute;              // 当前显示的路线详情
}
```

### 2. 备选路线底部表单

当计算出多条路线时，会自动弹出底部表单显示所有路线：

**特性：**
- 📊 显示所有路线的对比信息
- 🎨 选中路线高亮显示
- 🏷️ 第一条路线标记为"推荐"
- ⚖️ 显示相对于推荐路线的差异
- ✅ 选中状态指示器
- 👆 点击切换路线

**UI 布局：**
```
┌─────────────────────────────────┐
│ 备选路线 (3)                 [X]│
├─────────────────────────────────┤
│ [路线 1] [推荐] ✓               │
│ 📏 10.5 km   ⏱️ 25 min         │
│ 推荐路线                        │
├─────────────────────────────────┤
│ [路线 2]                        │
│ 📏 12.3 km   ⏱️ 28 min         │
│ 相比推荐: +1.8 km, +3 min      │
├─────────────────────────────────┤
│ [路线 3]                        │
│ 📏 9.8 km    ⏱️ 30 min         │
│ 相比推荐: -0.7 km, +5 min      │
└─────────────────────────────────┘
```

### 3. 路线信息卡片增强

在底部路线信息卡片中新增：
- 📊 显示备选路线数量
- 🔘 "其他路线" 按钮（当有多条路线时）
- 📋 "详细步骤" 按钮（当有导航步骤时）

**示例 UI：**
```
┌─────────────────────────────────┐
│ 🚗 驾车                         │
├─────────────────────────────────┤
│ 📏 距离    10.5 km              │
│ ⏱️ 时间    25 min               │
│ 🔀 备选路线 3 条                │
├─────────────────────────────────┤
│ [详细步骤] [其他路线]          │
└─────────────────────────────────┘
```

### 4. 地图路线可视化

**路线显示逻辑：**
- ✅ **选中路线**：完全不透明 + 较粗线条 + 交通方式对应颜色
- ⚪ **其他路线**：半透明灰色 + 较细线条

```dart
Polyline(
  polylineId: PolylineId('route_$index'),
  points: route.coordinates,
  color: isSelected
      ? _getColorForTransportType(_selectedTransportType)  // 蓝色/绿色/紫色/橙色
      : Colors.grey.withOpacity(0.5),                       // 半透明灰色
  width: isSelected ? 5 : 3,
)
```

### 5. 路线切换功能

点击备选路线列表中的任意路线，会：
1. ✅ 更新选中状态
2. 🎨 重绘地图上的所有路线（高亮新选中的路线）
3. 📍 调整地图视图以显示新路线
4. 📊 更新底部信息卡片显示新路线详情
5. 🔄 刷新 UI

### 6. 路线对比算法

```dart
Widget _buildRouteComparison(RouteResult route, RouteResult recommended) {
  final distanceDiff = route.distance - recommended.distance;
  final timeDiff = route.expectedTravelTime - recommended.expectedTravelTime;
  
  final comparisons = [];
  
  // 距离差异 > 100 米才显示
  if (distanceDiff.abs() > 100) {
    comparisons.add('${distanceDiff > 0 ? '+' : ''}${(distanceDiff / 1000).toStringAsFixed(1)} km');
  }
  
  // 时间差异 > 1 分钟才显示
  if (timeDiff.abs() > 60) {
    comparisons.add('${timeDiff > 0 ? '+' : ''}${(timeDiff / 60).round()} min');
  }
  
  return comparisons.isEmpty ? '相近' : '相比推荐: ${comparisons.join(', ')}';
}
```

## 使用流程

### 用户操作流程

1. **计算备选路线**
   - 点击浮动按钮中的 "备选路线" 图标
   - 等待路线计算完成

2. **查看备选路线**
   - 自动弹出备选路线列表（如果有多条）
   - 或点击底部卡片的 "其他路线" 按钮

3. **对比路线**
   - 查看每条路线的距离和时间
   - 查看相对于推荐路线的差异

4. **选择路线**
   - 点击列表中的路线卡片
   - 地图自动更新，高亮显示选中路线
   - 底部信息卡片更新显示新路线详情

5. **查看详情**
   - 点击 "详细步骤" 查看逐步导航指示

## 代码示例

### 完整的备选路线功能实现

```dart
class _RouteExampleState extends State<RouteExample> {
  List<RouteResult> _allRoutes = [];
  int _selectedRouteIndex = 0;

  // 1. 计算备选路线
  Future<void> _calculateAlternateRoutes() async {
    final routes = await _mapController!.calculateAlternateRoutes(
      origin: _origin,
      destination: _destination,
      transportType: _selectedTransportType,
    );
    
    setState(() {
      _allRoutes = routes;
      _selectedRouteIndex = 0;
      _drawAllRoutes();
    });
    
    if (routes.length > 1) {
      _showAlternateRoutesSheet();
    }
  }

  // 2. 绘制所有路线
  void _drawAllRoutes() {
    _polylines = _allRoutes.asMap().entries.map((entry) {
      final index = entry.key;
      final isSelected = index == _selectedRouteIndex;
      
      return Polyline(
        polylineId: PolylineId('route_$index'),
        points: _allRoutes[index].coordinates,
        color: isSelected
            ? _getColorForTransportType(_selectedTransportType)
            : Colors.grey.withOpacity(0.5),
        width: isSelected ? 5 : 3,
      );
    }).toSet();
  }

  // 3. 切换路线
  void _selectRoute(int index) {
    setState(() {
      _selectedRouteIndex = index;
      _currentRoute = _allRoutes[index];
      _drawAllRoutes();
    });
    _fitRouteToBounds(_allRoutes[index].coordinates);
  }

  // 4. 显示备选路线表单
  void _showAlternateRoutesSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => /* ... 见文档完整代码 ... */,
    );
  }
}
```

## 技术细节

### 状态管理

- **路线列表**：`List<RouteResult> _allRoutes`
- **选中索引**：`int _selectedRouteIndex`
- **当前路线**：`RouteResult? _currentRoute`

### UI 组件

- **DraggableScrollableSheet**：可拖动的底部表单
- **StatefulBuilder**：在模态框内管理状态
- **ListTile**：路线列表项
- **InkWell**：点击交互

### 颜色方案

| 交通方式 | 颜色 |
|---------|------|
| 驾车 (automobile) | 🔵 蓝色 |
| 步行 (walking) | 🟢 绿色 |
| 骑行 (cycling) | 🟣 紫色 |
| 公交 (transit) | 🟠 橙色 |
| 未选中路线 | ⚪ 半透明灰色 |

## 用户体验优化

### 1. 自动显示
- ✅ 计算出多条路线时自动弹出列表
- ✅ 无需额外点击即可看到所有选项

### 2. 视觉反馈
- ✅ 选中路线高亮显示
- ✅ 推荐路线特殊标记
- ✅ 选中状态图标（✓）
- ✅ 颜色区分

### 3. 信息丰富
- ✅ 显示距离和时间
- ✅ 显示相对差异
- ✅ 路线编号
- ✅ 推荐标记

### 4. 操作便捷
- ✅ 点击切换
- ✅ 实时更新
- ✅ 视图自动调整
- ✅ 双按钮布局（详细步骤 + 其他路线）

## 测试建议

### 功能测试

1. **单条路线**
   - 确认不显示备选路线按钮
   - 确认 `_allRoutes` 为空

2. **多条路线**
   - 确认自动弹出备选路线表单
   - 确认所有路线都显示在地图上
   - 确认默认选中第一条路线

3. **路线切换**
   - 点击不同路线
   - 确认地图高亮正确
   - 确认信息卡片更新
   - 确认视图自动调整

4. **路线对比**
   - 确认第一条路线显示 "推荐"
   - 确认其他路线显示差异
   - 确认差异计算正确

### UI 测试

1. **底部表单**
   - 可拖动调整高度
   - 标题显示路线数量
   - 列表滚动流畅
   - 关闭按钮工作正常

2. **信息卡片**
   - 显示备选路线数量
   - 按钮布局合理
   - 点击响应正常

3. **地图显示**
   - 所有路线都可见
   - 颜色区分明显
   - 线条粗细合适
   - 视图范围合理

## 相关文件

- `example/lib/route_calculation_example.dart` - 完整实现
- `docs/route_calculation_guide.md` - 使用文档
- `lib/src/route_result.dart` - 数据模型

## 更新日志

### v1.2.0 (2024-11-10)
- ✨ 新增备选路线 UI 显示功能
- ✨ 新增路线切换功能
- ✨ 新增路线对比功能
- 🎨 优化路线信息卡片布局
- 📝 更新使用文档

## 参考

- [Flutter ModalBottomSheet](https://api.flutter.dev/flutter/material/showModalBottomSheet.html)
- [DraggableScrollableSheet](https://api.flutter.dev/flutter/widgets/DraggableScrollableSheet-class.html)
- [Apple MapKit Directions](https://developer.apple.com/documentation/mapkit/mkdirections)

