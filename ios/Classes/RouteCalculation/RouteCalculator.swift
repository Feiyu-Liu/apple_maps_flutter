//
//  RouteCalculator.swift
//  apple_maps_flutter
//
//  Created by Route Calculation Feature
//

import Foundation
import MapKit

/// 路线计算器，封装 MKDirections API
class RouteCalculator {

  /// 计算两点之间的路线
  /// - Parameters:
  ///   - origin: 起点坐标
  ///   - destination: 终点坐标
  ///   - transportType: 交通方式
  ///   - requestsAlternateRoutes: 是否请求备选路线
  ///   - completion: 完成回调
  func calculateRoute(
    origin: CLLocationCoordinate2D,
    destination: CLLocationCoordinate2D,
    transportType: MKDirectionsTransportType,
    requestsAlternateRoutes: Bool = false,
    completion: @escaping (Result<RouteResult, Error>) -> Void
  ) {
    // 验证坐标有效性
    guard CLLocationCoordinate2DIsValid(origin) && CLLocationCoordinate2DIsValid(destination) else {
      completion(.failure(RouteCalculatorError.invalidCoordinates))
      return
    }

    // 创建起点和终点的 MKPlacemark
    let sourcePlacemark = MKPlacemark(coordinate: origin)
    let destinationPlacemark = MKPlacemark(coordinate: destination)

    // 创建 MKMapItem
    let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

    // 创建路线请求
    let request = MKDirections.Request()
    request.source = sourceMapItem
    request.destination = destinationMapItem
    request.transportType = transportType
    request.requestsAlternateRoutes = requestsAlternateRoutes

    // 执行路线计算
    let directions = MKDirections(request: request)
    directions.calculate { [weak self] response, error in
      // 处理错误
      if let error = error {
        completion(.failure(self?.mapDirectionsError(error) ?? error))
        return
      }

      // 检查是否有路线结果
      guard let response = response, let route = response.routes.first else {
        completion(.failure(RouteCalculatorError.noRouteFound(underlying: nil)))
        return
      }

      // 创建结果并返回
      let transportTypeString = self?.transportTypeToString(transportType) ?? "unknown"
      let result = RouteResult(from: route, transportType: transportTypeString)
      completion(.success(result))
    }
  }

  /// 计算多条备选路线
  /// - Parameters:
  ///   - origin: 起点坐标
  ///   - destination: 终点坐标
  ///   - transportType: 交通方式
  ///   - completion: 完成回调，返回多条路线
  func calculateAlternateRoutes(
    origin: CLLocationCoordinate2D,
    destination: CLLocationCoordinate2D,
    transportType: MKDirectionsTransportType,
    completion: @escaping (Result<[RouteResult], Error>) -> Void
  ) {
    // 验证坐标有效性
    guard CLLocationCoordinate2DIsValid(origin) && CLLocationCoordinate2DIsValid(destination) else {
      completion(.failure(RouteCalculatorError.invalidCoordinates))
      return
    }

    let sourcePlacemark = MKPlacemark(coordinate: origin)
    let destinationPlacemark = MKPlacemark(coordinate: destination)

    let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

    let request = MKDirections.Request()
    request.source = sourceMapItem
    request.destination = destinationMapItem
    request.transportType = transportType
    request.requestsAlternateRoutes = true  // 请求备选路线

    let directions = MKDirections(request: request)
    directions.calculate { [weak self] response, error in
      if let error = error {
        completion(.failure(self?.mapDirectionsError(error) ?? error))
        return
      }

      guard let response = response, !response.routes.isEmpty else {
        completion(.failure(RouteCalculatorError.noRouteFound(underlying: nil)))
        return
      }

      // 将所有路线转换为 RouteResult
      let transportTypeString = self?.transportTypeToString(transportType) ?? "unknown"
      let results = response.routes.map { route in
        RouteResult(from: route, transportType: transportTypeString)
      }
      completion(.success(results))
    }
  }

  /// 计算预计到达时间（ETA）
  /// - Parameters:
  ///   - origin: 起点坐标
  ///   - destination: 终点坐标
  ///   - transportType: 交通方式
  ///   - completion: 完成回调
  func calculateETA(
    origin: CLLocationCoordinate2D,
    destination: CLLocationCoordinate2D,
    transportType: MKDirectionsTransportType,
    completion: @escaping (Result<[String: Any], Error>) -> Void
  ) {
    // 验证坐标有效性
    guard CLLocationCoordinate2DIsValid(origin) && CLLocationCoordinate2DIsValid(destination) else {
      completion(.failure(RouteCalculatorError.invalidCoordinates))
      return
    }

    let sourcePlacemark = MKPlacemark(coordinate: origin)
    let destinationPlacemark = MKPlacemark(coordinate: destination)

    let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

    let request = MKDirections.Request()
    request.source = sourceMapItem
    request.destination = destinationMapItem
    request.transportType = transportType

    let directions = MKDirections(request: request)
    directions.calculateETA { [weak self] response, error in
      if let error = error {
        completion(.failure(self?.mapDirectionsError(error) ?? error))
        return
      }

      guard let response = response else {
        completion(.failure(RouteCalculatorError.noRouteFound(underlying: nil)))
        return
      }

      let result: [String: Any] = [
        "distance": response.distance,
        "expectedTravelTime": response.expectedTravelTime,
        "transportType": self?.transportTypeToString(transportType) ?? "unknown",
      ]

      completion(.success(result))
    }
  }

  // MARK: - Helper Methods

  /// 将 MKDirectionsTransportType 转换为字符串
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

  /// 映射 MKDirections 错误到更友好的错误
  private func mapDirectionsError(_ error: Error) -> Error {
    let nsError = error as NSError

    // 添加详细的错误信息
    print("🚨 MKDirections Error Details:")
    print("  - Domain: \(nsError.domain)")
    print("  - Code: \(nsError.code)")
    print("  - Description: \(nsError.localizedDescription)")
    if let reason = nsError.localizedFailureReason {
      print("  - Failure Reason: \(reason)")
    }
    if let suggestion = nsError.localizedRecoverySuggestion {
      print("  - Recovery Suggestion: \(suggestion)")
    }
    print("  - User Info: \(nsError.userInfo)")

    // MKDirections 错误代码
    switch nsError.code {
    case 1:  // MKErrorUnknown
      return RouteCalculatorError.unknownError(underlying: nsError)
    case 2:  // MKErrorServerFailure
      return RouteCalculatorError.serverFailure(underlying: nsError)
    case 3:  // MKErrorLoadingThrottled
      return RouteCalculatorError.loadingThrottled(underlying: nsError)
    case 4:  // MKErrorPlacemarkNotFound
      return RouteCalculatorError.placemarkNotFound(underlying: nsError)
    case 5:  // MKErrorDirectionsNotFound
      return RouteCalculatorError.noRouteFound(underlying: nsError)
    default:
      return RouteCalculatorError.unknownError(underlying: nsError)
    }
  }
}

// MARK: - Error Types

/// 路线计算器错误类型
enum RouteCalculatorError: LocalizedError {
  case invalidCoordinates
  case noRouteFound(underlying: NSError? = nil)
  case unknownError(underlying: NSError? = nil)
  case serverFailure(underlying: NSError? = nil)
  case loadingThrottled(underlying: NSError? = nil)
  case placemarkNotFound(underlying: NSError? = nil)
  case networkError(underlying: NSError? = nil)

  var errorDescription: String? {
    switch self {
    case .invalidCoordinates:
      return "坐标无效：提供的坐标不合法"
    case .noRouteFound(let underlying):
      var message = "找不到路线：无法在指定位置之间找到路线"
      if let error = underlying {
        message += " (错误码: \(error.code), Domain: \(error.domain))"
      }
      return message
    case .unknownError(let underlying):
      var message = "未知错误"
      if let error = underlying {
        message += "：\(error.localizedDescription) (错误码: \(error.code), Domain: \(error.domain))"
      }
      return message
    case .serverFailure(let underlying):
      var message = "服务器错误：Apple Maps 服务器响应失败"
      if let error = underlying {
        message += " (错误码: \(error.code))"
      }
      return message
    case .loadingThrottled(let underlying):
      var message = "请求过于频繁：请稍后再试"
      if let error = underlying {
        message += " (错误码: \(error.code))"
      }
      return message
    case .placemarkNotFound(let underlying):
      var message = "位置未找到：无法识别指定的地理位置"
      if let error = underlying {
        message += " (错误码: \(error.code))"
      }
      return message
    case .networkError(let underlying):
      var message = "网络连接错误：请检查网络连接"
      if let error = underlying {
        message += " (错误码: \(error.code))"
      }
      return message
    }
  }

  /// 获取详细的错误信息字典
  func getDetailedInfo() -> [String: Any] {
    var info: [String: Any] = ["errorType": getErrorType()]

    switch self {
    case .invalidCoordinates:
      info["message"] = "坐标无效"
    case .noRouteFound(let underlying):
      info["message"] = "找不到路线"
      if let error = underlying {
        info["code"] = error.code
        info["domain"] = error.domain
        info["underlyingError"] = error.localizedDescription
        info["userInfo"] = String(describing: error.userInfo)
      }
    case .unknownError(let underlying):
      info["message"] = "未知错误"
      if let error = underlying {
        info["code"] = error.code
        info["domain"] = error.domain
        info["underlyingError"] = error.localizedDescription
        info["userInfo"] = String(describing: error.userInfo)
      }
    case .serverFailure(let underlying):
      info["message"] = "服务器错误"
      if let error = underlying {
        info["code"] = error.code
        info["domain"] = error.domain
        info["underlyingError"] = error.localizedDescription
      }
    case .loadingThrottled(let underlying):
      info["message"] = "请求频率限制"
      if let error = underlying {
        info["code"] = error.code
        info["domain"] = error.domain
      }
    case .placemarkNotFound(let underlying):
      info["message"] = "位置未找到"
      if let error = underlying {
        info["code"] = error.code
        info["domain"] = error.domain
      }
    case .networkError(let underlying):
      info["message"] = "网络错误"
      if let error = underlying {
        info["code"] = error.code
        info["domain"] = error.domain
      }
    }

    return info
  }

  /// 获取错误类型字符串
  private func getErrorType() -> String {
    switch self {
    case .invalidCoordinates:
      return "INVALID_COORDINATES"
    case .noRouteFound:
      return "NO_ROUTE_FOUND"
    case .unknownError:
      return "UNKNOWN_ERROR"
    case .serverFailure:
      return "SERVER_FAILURE"
    case .loadingThrottled:
      return "LOADING_THROTTLED"
    case .placemarkNotFound:
      return "PLACEMARK_NOT_FOUND"
    case .networkError:
      return "NETWORK_ERROR"
    }
  }
}
