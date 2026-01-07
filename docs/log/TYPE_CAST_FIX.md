# 类型转换错误修复

## 问题描述

在使用路线计算功能时遇到以下错误：

```
type '_Map<Object?, Object?>' is not a subtype of type 'Map<String, dynamic>' in type cast
```

## 根本原因

从 iOS 原生端通过 Platform Channel 返回的数据类型是 `Map<Object?, Object?>`，而 Dart 代码尝试直接将其强制转换为 `Map<String, dynamic>` 导致类型转换失败。

这是 Flutter Platform Channel 的已知行为：原生端返回的集合类型在 Dart 端被接收为更通用的类型（`Object?`）。

## 修复内容

### 1. `lib/src/controller.dart`

#### `calculateRoute` 方法
**修改前：**
```dart
final Map<String, dynamic>? result =
    await channel.invokeMapMethod<String, dynamic>('route#calculate', ...);
return RouteResult.fromMap(result);
```

**修改后：**
```dart
final dynamic result = await channel.invokeMethod('route#calculate', ...);
return RouteResult.fromMap(result as Map);
```

#### `calculateAlternateRoutes` 方法
**修改前：**
```dart
final List<dynamic>? results = await channel.invokeMethod<List<dynamic>>(...);
return results.map((result) => RouteResult.fromMap(result as Map<String, dynamic>)).toList();
```

**修改后：**
```dart
final dynamic results = await channel.invokeMethod(...);
return (results as List).map((result) => RouteResult.fromMap(result as Map)).toList();
```

#### `calculateETA` 方法
**修改前：**
```dart
final Map<String, dynamic>? result =
    await channel.invokeMapMethod<String, dynamic>('route#calculateETA', ...);
return result;
```

**修改后：**
```dart
final dynamic result = await channel.invokeMethod('route#calculateETA', ...);
return Map<String, dynamic>.from(result as Map);
```

### 2. `lib/src/route_result.dart`

#### `RouteResult.fromMap` 方法
**修改前：**
```dart
factory RouteResult.fromMap(Map<String, dynamic> map) {
  return RouteResult(
    coordinates: (map['coordinates'] as List)
        .map((coord) => LatLng(
              (coord['latitude'] as num).toDouble(),
              (coord['longitude'] as num).toDouble(),
            ))
        .toList(),
    steps: map['steps'] != null
        ? (map['steps'] as List)
            .map((step) => RouteStep.fromMap(step as Map<String, dynamic>))
            .toList()
        : null,
    ...
  );
}
```

**修改后：**
```dart
factory RouteResult.fromMap(Map<dynamic, dynamic> map) {
  return RouteResult(
    coordinates: (map['coordinates'] as List)
        .map((coord) {
          final coordMap = coord as Map;
          return LatLng(
            (coordMap['latitude'] as num).toDouble(),
            (coordMap['longitude'] as num).toDouble(),
          );
        })
        .toList(),
    steps: map['steps'] != null
        ? (map['steps'] as List)
            .map((step) => RouteStep.fromMap(step as Map))
            .toList()
        : null,
    ...
  );
}
```

#### `RouteStep.fromMap` 方法
**修改前：**
```dart
factory RouteStep.fromMap(Map<String, dynamic> map) {
  return RouteStep(
    coordinates: map['coordinates'] != null
        ? (map['coordinates'] as List)
            .map((coord) => LatLng(
                  (coord['latitude'] as num).toDouble(),
                  (coord['longitude'] as num).toDouble(),
                ))
            .toList()
        : null,
    ...
  );
}
```

**修改后：**
```dart
factory RouteStep.fromMap(Map<dynamic, dynamic> map) {
  return RouteStep(
    coordinates: map['coordinates'] != null
        ? (map['coordinates'] as List)
            .map((coord) {
              final coordMap = coord as Map;
              return LatLng(
                (coordMap['latitude'] as num).toDouble(),
                (coordMap['longitude'] as num).toDouble(),
              );
            })
            .toList()
        : null,
    ...
  );
}
```

### 3. `example/lib/route_calculation_example.dart`

#### `_showDetailedError` 方法
**修改前：**
```dart
if (error is PlatformException) {
  errorMessage = error.message ?? '未知错误';
  errorDetails = error.details as Map<String, dynamic>?;
  
  // 打印详细信息
  print('错误代码: ${error.code}');
  print('错误消息: ${error.message}');
  print('错误详情: ${error.details}');
}
```

**修改后：**
```dart
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
}
```

## 修复策略

1. **接收数据时使用通用类型**
   - 使用 `dynamic` 而不是 `Map<String, dynamic>`
   - 使用 `invokeMethod` 而不是 `invokeMapMethod`

2. **转换时使用更宽松的类型**
   - 将 `Map<String, dynamic>` 改为 `Map<dynamic, dynamic>` 或 `Map`
   - 使用中间变量进行类型转换

3. **安全的类型转换**
   - 使用 `Map<String, dynamic>.from(map)` 进行安全转换
   - 添加 try-catch 捕获转换失败

4. **避免嵌套强制转换**
   - 先转换外层 Map，再转换内层元素
   - 使用临时变量存储中间结果

## 最佳实践

### ✅ 推荐做法

```dart
// 1. 接收数据
final dynamic result = await channel.invokeMethod('method');

// 2. 类型检查和转换
if (result is Map) {
  final map = Map<String, dynamic>.from(result as Map);
  // 使用 map
}

// 3. 处理嵌套数据
final coordMap = coord as Map;
final lat = (coordMap['latitude'] as num).toDouble();
```

### ❌ 避免做法

```dart
// 1. 直接强制转换
final map = result as Map<String, dynamic>; // 可能失败

// 2. 使用泛型方法调用
final result = await channel.invokeMapMethod<String, dynamic>('method'); // 仍然可能返回 Object?

// 3. 嵌套强制转换
final lat = (coord['latitude'] as num).toDouble(); // coord 可能是 Map<Object?, Object?>
```

## 测试建议

1. **测试不同距离的路线**
   - 短距离（同城，< 10km）
   - 中距离（50-100km）
   - 长距离（> 500km）

2. **测试不同交通方式**
   - 驾车（automobile）
   - 步行（walking）
   - 公交（transit）

3. **测试错误场景**
   - 无网络连接
   - 无效坐标
   - 无可用路线

## 验证方法

运行应用后，在控制台查看详细的类型信息：

```
错误代码: NO_ROUTE_FOUND
错误消息: 找不到路线：无法在指定位置之间找到路线
错误详情: {errorType: NO_ROUTE_FOUND, message: 找不到路线, ...}
错误详情类型: _Map<Object?, Object?>
```

现在应该能够正确显示详细的错误对话框，而不是类型转换错误。

## 相关资源

- [Flutter Platform Channels](https://docs.flutter.dev/development/platform-integration/platform-channels)
- [Dart Type System](https://dart.dev/guides/language/type-system)
- [Flutter Type Safety](https://dart.dev/guides/language/sound-dart)

