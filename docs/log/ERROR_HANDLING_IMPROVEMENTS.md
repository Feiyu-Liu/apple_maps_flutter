# 路线计算错误处理改进

## 概述

为了更好地诊断路线计算失败的原因，我们对错误处理机制进行了全面改进，现在可以提供详细的错误信息和可操作的建议。

## 改进内容

### 1. iOS 原生端改进 (`RouteCalculator.swift`)

#### 增强的错误信息
- 在错误映射函数中添加了详细的日志输出，包括：
  - 错误域 (Domain)
  - 错误代码 (Code)
  - 错误描述 (Description)
  - 失败原因 (Failure Reason)
  - 恢复建议 (Recovery Suggestion)
  - 用户信息 (User Info)

#### 错误类型扩展
`RouteCalculatorError` 枚举现在支持关联值，可以携带底层的 `NSError` 对象：

```swift
enum RouteCalculatorError: LocalizedError {
  case invalidCoordinates
  case noRouteFound(underlying: NSError? = nil)
  case unknownError(underlying: NSError? = nil)
  case serverFailure(underlying: NSError? = nil)
  case loadingThrottled(underlying: NSError? = nil)
  case placemarkNotFound(underlying: NSError? = nil)
  case networkError(underlying: NSError? = nil)
}
```

#### 新增方法
- `getDetailedInfo()`: 返回包含错误类型、代码、描述等详细信息的字典
- `getErrorType()`: 返回标准化的错误类型字符串

### 2. Flutter-iOS 通信改进 (`AppleMapController.swift`)

#### 结构化的错误传递
通过 `FlutterError` 的 `details` 参数传递详细错误信息：

```swift
result(
  FlutterError(
    code: errorCode,           // 错误类型 (如 "NO_ROUTE_FOUND")
    message: error.localizedDescription,  // 用户友好的错误消息
    details: errorDetails      // 详细的错误信息字典
  )
)
```

### 3. Flutter UI 层改进 (`route_calculation_example.dart`)

#### 详细错误对话框
新增 `_showDetailedError()` 方法，显示包含以下内容的错误对话框：

1. **错误标题和图标**
   - 清晰的视觉提示

2. **主要错误消息**
   - 用户友好的中文描述
   - 包含错误代码和域信息

3. **详细信息部分**
   - 错误类型 (errorType)
   - 错误代码 (code)
   - 错误域 (domain)
   - 底层错误描述 (underlyingError)
   - 用户信息 (userInfo)

4. **可能的原因和建议**
   - 根据错误类型提供针对性的解决建议
   - 帮助用户快速定位问题

5. **操作按钮**
   - "确定"：关闭对话框
   - "复制详情"：将完整错误信息复制到剪贴板，便于调试或报告

#### 智能建议系统
`_buildErrorSuggestions()` 方法根据不同的错误类型提供相应的解决建议：

| 错误类型 | 建议内容 |
|---------|---------|
| NO_ROUTE_FOUND | 距离太远、交通方式不支持、需要网络连接、缺少路线数据 |
| SERVER_FAILURE | 服务器不可用、检查网络、稍后重试 |
| LOADING_THROTTLED | 请求频繁、等待后重试 |
| INVALID_COORDINATES | 坐标无效、检查经纬度范围 |
| PLACEMARK_NOT_FOUND | 位置无法识别、尝试其他坐标 |
| NETWORK_ERROR | 检查网络连接、确保互联网可用 |

## 使用方法

### 查看控制台日志

运行应用时，详细的错误信息会自动打印到控制台：

```
🚨 MKDirections Error Details:
  - Domain: MKErrorDomain
  - Code: 5
  - Description: Directions Not Available
  - User Info: {...}
```

同时，Flutter 端也会打印错误详情：

```
路线计算失败: PlatformException(NO_ROUTE_FOUND, ...)
错误代码: NO_ROUTE_FOUND
错误消息: 找不到路线：无法在指定位置之间找到路线 (错误码: 5, Domain: MKErrorDomain)
错误详情: {errorType: NO_ROUTE_FOUND, message: 找不到路线, code: 5, domain: MKErrorDomain, ...}
```

### 用户界面反馈

当路线计算失败时，会自动弹出详细的错误对话框，包含：
- 错误描述
- 详细信息
- 可能的原因和建议
- 复制详情功能

## 常见错误分析

### 1. NO_ROUTE_FOUND (找不到路线)

**可能原因：**
- 起点和终点距离过远（如旧金山到洛杉矶）
- 所选交通方式不支持该路线（如步行模式但距离太远）
- 某些区域缺少详细的路线数据
- 需要网络连接来计算长距离路线

**解决方案：**
- 尝试较短距离的路线（如同一城市内的两点）
- 切换不同的交通方式
- 确保设备已连接到互联网
- 选择有详细地图数据的区域

### 2. SERVER_FAILURE (服务器错误)

**可能原因：**
- Apple Maps 服务暂时不可用
- 网络连接不稳定

**解决方案：**
- 检查网络连接
- 稍后重试
- 确认 Apple Maps 服务状态

### 3. LOADING_THROTTLED (请求频率限制)

**可能原因：**
- 短时间内发送了过多请求
- Apple Maps API 有速率限制

**解决方案：**
- 等待几秒后再试
- 避免连续快速点击计算按钮

## 调试技巧

1. **查看完整日志**
   - 使用 `flutter run` 运行应用
   - 关注控制台的 🚨 标记的错误详情

2. **复制错误详情**
   - 点击错误对话框中的"复制详情"按钮
   - 将信息分享给开发者或用于调试

3. **测试不同场景**
   - 尝试不同的距离（近距离 vs 远距离）
   - 测试不同的交通方式
   - 在有网络和无网络环境下测试

## 开发者注意事项

### 扩展错误类型

如需添加新的错误类型，需要同时修改：

1. **Swift 端** (`RouteCalculator.swift`)
   - 在 `RouteCalculatorError` 枚举中添加新的 case
   - 更新 `errorDescription` 属性
   - 更新 `getDetailedInfo()` 方法
   - 更新 `getErrorType()` 方法

2. **Dart 端** (`route_calculation_example.dart`)
   - 在 `_buildErrorSuggestions()` 方法中添加对应的建议

### 错误信息国际化

当前错误消息为中文，如需支持多语言：
- 使用 Flutter 的国际化机制
- 在 Swift 端使用 `NSLocalizedString`

## 总结

通过这些改进，现在可以：
✅ 在控制台看到完整的错误详情
✅ 向用户显示友好的错误对话框
✅ 提供针对性的解决建议
✅ 轻松复制错误信息用于调试
✅ 快速定位路线计算失败的根本原因

