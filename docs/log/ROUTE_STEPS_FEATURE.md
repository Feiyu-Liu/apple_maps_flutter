# 路线详细步骤功能

## 功能概述

现在路线计算示例中添加了**详细步骤查看**功能，可以显示路线的每一步导航指示。

## 使用方法

### 1. 计算路线

选择交通方式（驾车/步行），然后点击"计算路线"按钮。

### 2. 查看路线信息

路线计算成功后，地图底部会显示路线信息卡片，包含：
- 交通方式
- 总距离
- 预计时间
- 步骤数量

### 3. 查看详细步骤

如果路线包含导航步骤，信息卡片中会显示 **"查看详细步骤"** 按钮。点击该按钮即可查看详细的导航指示。

## 步骤详情内容

详细步骤弹窗显示以下信息：

### 标题栏
- 交通方式图标
- 路线总距离和总时间
- 关闭按钮

### 步骤列表

每个步骤包含：

1. **步骤编号**
   - 圆形编号（1, 2, 3...）
   - 颜色对应交通方式

2. **导航指示**
   - 详细的文字说明
   - 例如："沿着 Main Street 行驶"、"左转进入 Oak Avenue"等

3. **距离信息**
   - 该步骤的距离
   - 自动格式化（小于1公里显示米，大于1公里显示公里）

4. **交通方式**
   - 该步骤使用的交通方式图标
   - 显示名称（驾车/步行/公交）

5. **技术信息**
   - 该步骤包含的坐标点数量

## UI 特性

### 可拖动滚动表单
- 初始高度：70% 屏幕高度
- 可拖动至：50% ~ 95% 屏幕高度
- 支持滚动查看所有步骤

### 视觉设计
- 清晰的步骤分隔线
- 颜色编码（与选择的交通方式一致）
- 圆形步骤编号
- 图标辅助理解

### 交互设计
- 点击关闭按钮或向下滑动关闭
- 流畅的滚动体验
- 响应式布局

## 示例数据结构

### RouteStep 数据模型

```dart
class RouteStep {
  final String instructions;      // 导航指示文本
  final double distance;           // 距离（米）
  final List<LatLng>? coordinates; // 该步骤的坐标点
  final String? transportType;     // 交通方式
  
  // 格式化距离
  String formatDistance({bool useMetric = true}) {
    if (useMetric) {
      if (distance < 1000) {
        return '${distance.toStringAsFixed(0)} 米';
      } else {
        return '${(distance / 1000).toStringAsFixed(1)} 公里';
      }
    }
    // ...
  }
}
```

## 交通方式图标映射

| 交通方式 | 图标 | 颜色 |
|---------|------|------|
| 驾车 (automobile) | 🚗 `Icons.directions_car` | 蓝色 |
| 步行 (walking) | 🚶 `Icons.directions_walk` | 绿色 |
| 公交 (transit) | 🚌 `Icons.directions_transit` | 橙色 |

## 代码示例

### 显示路线详细步骤

```dart
// 当路线计算成功后
if (route.steps != null && route.steps!.isNotEmpty) {
  print('路线包含 ${route.steps!.length} 个步骤');
  
  // 用户点击"查看详细步骤"按钮后
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => RouteDetailsSheet(route: route),
  );
}
```

### 访问步骤信息

```dart
for (int i = 0; i < route.steps!.length; i++) {
  final step = route.steps![i];
  
  print('步骤 ${i + 1}:');
  print('  指示: ${step.instructions}');
  print('  距离: ${step.formatDistance()}');
  print('  交通方式: ${step.transportType}');
  print('  坐标点: ${step.coordinates?.length ?? 0}');
}
```

## MapKit 步骤数据

### iOS MapKit 提供的步骤信息

从 `MKRoute.Step` 获取的数据：

```swift
// Swift (iOS 原生端)
for step in route.steps {
    let stepData: [String: Any] = [
        "instructions": step.instructions,
        "distance": step.distance,
        "coordinates": extractCoordinates(from: step.polyline),
        "transportType": transportTypeString(from: step.transportType)
    ]
}
```

### 指示文本示例

MapKit 提供的 `instructions` 可能包含：

- "Head north on Main St"（向北前往 Main St）
- "Turn left onto Oak Ave"（左转进入 Oak Ave）
- "Continue straight"（直行）
- "Merge onto Highway 101"（并入 101 高速公路）
- "Take exit 23"（从 23 号出口驶出）
- "Arrive at destination"（到达目的地）

**注意**：指示文本的语言由系统语言决定，中国地区可能显示为英文。

## 注意事项

### 1. 步骤可用性

- ✅ **驾车路线**：通常包含详细步骤
- ✅ **步行路线**：通常包含详细步骤
- ⚠️ **公交路线**：在支持地区才可用（中国大陆不支持）

### 2. 步骤数量

步骤数量取决于：
- 路线复杂度
- 转弯次数
- 道路变化
- MapKit 算法

**示例**：
- 简单路线（2公里直行）：可能只有 2-3 步
- 复杂路线（多次转弯）：可能有 10+ 步

### 3. 语言和本地化

MapKit 返回的指示文本语言取决于：
- 设备系统语言
- 地图数据可用性
- 地区设置

### 4. 坐标点精度

每个步骤可能包含多个坐标点：
- 用于绘制该步骤的详细路径
- 坐标点越多，路径越精确
- 可用于显示子路段

## 扩展功能建议

### 1. 步骤高亮

点击某个步骤时，在地图上高亮显示该步骤的路径：

```dart
void _highlightStep(RouteStep step) {
  if (step.coordinates != null && step.coordinates!.isNotEmpty) {
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('step_highlight'),
          points: step.coordinates!,
          color: Colors.red,
          width: 8,
        ),
      );
    });
    
    // 移动地图到该步骤
    _fitRouteToBounds(step.coordinates!);
  }
}
```

### 2. 语音导航预览

为每个步骤添加朗读按钮：

```dart
import 'package:flutter_tts/flutter_tts.dart';

void _speakInstruction(String instruction) async {
  final tts = FlutterTts();
  await tts.setLanguage('zh-CN');
  await tts.speak(instruction);
}
```

### 3. 步骤时间估算

显示到达每个步骤的预计时间：

```dart
String getStepETA(int stepIndex) {
  double cumulativeTime = 0;
  for (int i = 0; i <= stepIndex; i++) {
    // 简单估算：距离 / 平均速度
    final step = route.steps![i];
    final speedKmh = _selectedTransportType == RouteTransportType.walking 
        ? 5.0  // 步行 5 km/h
        : 40.0; // 驾车 40 km/h
    cumulativeTime += (step.distance / 1000) / speedKmh * 3600;
  }
  
  final eta = DateTime.now().add(Duration(seconds: cumulativeTime.toInt()));
  return DateFormat('HH:mm').format(eta);
}
```

### 4. 导出步骤

将步骤导出为文本或分享：

```dart
String exportStepsAsText(RouteResult route) {
  final buffer = StringBuffer();
  buffer.writeln('路线详情');
  buffer.writeln('总距离: ${route.formatDistance()}');
  buffer.writeln('总时间: ${route.formatDuration()}');
  buffer.writeln('\n步骤：\n');
  
  for (int i = 0; i < route.steps!.length; i++) {
    final step = route.steps![i];
    buffer.writeln('${i + 1}. ${step.instructions}');
    buffer.writeln('   距离: ${step.formatDistance()}\n');
  }
  
  return buffer.toString();
}

// 分享
void _shareRoute() {
  final text = exportStepsAsText(_currentRoute!);
  Share.share(text);
}
```

### 5. 打印路线

添加打印功能：

```dart
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> _printRoute() async {
  final pdf = pw.Document();
  
  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('路线详情', style: pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 20),
          ...route.steps!.asMap().entries.map((entry) {
            return pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 10),
              child: pw.Row(
                children: [
                  pw.Text('${entry.key + 1}. '),
                  pw.Expanded(child: pw.Text(entry.value.instructions)),
                ],
              ),
            );
          }),
        ],
      ),
    ),
  );
  
  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
```

## 故障排除

### 问题：没有显示"查看详细步骤"按钮

**可能原因：**
1. 路线没有包含步骤数据
2. `steps` 为 `null` 或空数组

**解决方法：**
```dart
// 检查步骤数据
print('Steps available: ${route.steps != null}');
print('Steps count: ${route.steps?.length ?? 0}');

// 确保 iOS 端返回了步骤数据
// 查看 RouteResult.swift 中的 extractSteps 方法
```

### 问题：步骤指示文本为空

**可能原因：**
- MapKit 在某些情况下可能不提供指示文本

**解决方法：**
```dart
// 使用默认文本
Text(
  step.instructions.isNotEmpty 
      ? step.instructions 
      : '继续前进 ${step.formatDistance()}',
  // ...
)
```

### 问题：步骤太少

**可能原因：**
- 路线很简单（直线）
- MapKit 简化了步骤

**这是正常行为**，简单路线可能只有 2-3 步。

## 测试建议

### 测试场景

1. **简单路线**
   - 距离：< 5 公里
   - 转弯：1-2 次
   - 预期步骤：2-5 步

2. **复杂路线**
   - 距离：10-20 公里
   - 转弯：多次
   - 预期步骤：10-20 步

3. **长距离路线**
   - 距离：> 50 公里
   - 包含高速公路
   - 预期步骤：20-50 步

### 测试用例

```dart
// 测试代码
void testRouteSteps() {
  final route = RouteResult(
    distance: 5000,
    expectedTravelTime: 600,
    coordinates: [...],
    steps: [
      RouteStep(
        instructions: 'Head north',
        distance: 500,
      ),
      RouteStep(
        instructions: 'Turn left',
        distance: 1000,
      ),
      // ...
    ],
    transportType: 'automobile',
  );
  
  expect(route.steps, isNotNull);
  expect(route.steps!.length, greaterThan(0));
  expect(route.steps![0].instructions, isNotEmpty);
}
```

## 总结

✅ **已实现的功能：**
- 显示路线步骤总数
- 查看详细步骤按钮
- 可拖动的步骤列表
- 步骤编号和导航指示
- 距离和交通方式显示
- 响应式 UI 设计

🎯 **使用场景：**
- 查看路线的详细转弯指示
- 了解每个路段的距离
- 规划出行前预览路线
- 分步导航准备

📱 **用户体验：**
- 直观的视觉设计
- 流畅的交互
- 清晰的信息层次
- 易于理解的图标

