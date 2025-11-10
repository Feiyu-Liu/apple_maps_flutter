//
//  RouteResult.swift
//  apple_maps_flutter
//
//  Created by Route Calculation Feature
//

import Foundation
import MapKit

/// 路线计算结果数据模型
struct RouteResult {
  let distance: Double  // 路线距离（米）
  let expectedTravelTime: Double  // 预计行驶时间（秒）
  let coordinates: [[String: Double]]  // 路线坐标点数组
  let steps: [[String: Any]]?  // 导航步骤（可选）
  let name: String?  // 路线名称
  let transportType: String  // 交通方式

  /// 从 MKRoute 创建 RouteResult
  init(from route: MKRoute, transportType: String) {
    self.distance = route.distance
    self.expectedTravelTime = route.expectedTravelTime
    self.coordinates = RouteResult.extractCoordinates(from: route.polyline)
    self.steps = RouteResult.extractSteps(from: route.steps)
    self.name = route.name
    self.transportType = transportType
  }

  /// 提取路线坐标点
  private static func extractCoordinates(from polyline: MKPolyline) -> [[String: Double]] {
    var coordinates = [CLLocationCoordinate2D](
      repeating: CLLocationCoordinate2D(),
      count: polyline.pointCount
    )

    polyline.getCoordinates(&coordinates, range: NSRange(location: 0, length: polyline.pointCount))

    return coordinates.map { coord in
      [
        "latitude": coord.latitude,
        "longitude": coord.longitude,
      ]
    }
  }

  /// 提取导航步骤
  private static func extractSteps(from steps: [MKRoute.Step]) -> [[String: Any]] {
    return steps.map { step in
      var stepDict: [String: Any] = [
        "instructions": step.instructions,
        "distance": step.distance,
      ]

      // 提取该步骤的坐标
      if step.polyline.pointCount > 0 {
        stepDict["coordinates"] = extractCoordinates(from: step.polyline)
      }

      // 交通类型
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

      return stepDict
    }
  }

  /// 转换为可通过 MethodChannel 传递的 Dictionary
  func toDictionary() -> [String: Any] {
    var dict: [String: Any] = [
      "distance": distance,
      "expectedTravelTime": expectedTravelTime,
      "coordinates": coordinates,
      "transportType": transportType,
    ]

    if let steps = steps {
      dict["steps"] = steps
    }

    if let name = name {
      dict["name"] = name
    }

    return dict
  }
}
