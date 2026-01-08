//
//  AppleMapController.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 03.09.19.
//

import Foundation
import MapKit

public class AppleMapController: NSObject, FlutterPlatformView {
  var contentView: UIView
  var mapView: FlutterMapView
  var registrar: FlutterPluginRegistrar
  var channel: FlutterMethodChannel
  var initialCameraPosition: [String: Any]
  var options: [String: Any]
  var currentlySelectedAnnotation: String?
  var snapShotOptions: MKMapSnapshotter.Options = MKMapSnapshotter.Options()
  var snapShot: MKMapSnapshotter?

  public init(
    withFrame frame: CGRect, withRegistrar registrar: FlutterPluginRegistrar,
    withargs args: [String: Any], withId id: Int64
  ) {
    self.options = args["options"] as! [String: Any]
    self.channel = FlutterMethodChannel(
      name: "apple_maps_plugin.luisthein.de/apple_maps_\(id)",
      binaryMessenger: registrar.messenger())

    self.mapView = FlutterMapView(channel: channel, options: options)
    self.registrar = registrar

    // To stop the odd movement of the Apple logo.
    self.contentView = UIScrollView()
    self.contentView.addSubview(mapView)
    mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

    self.initialCameraPosition = args["initialCameraPosition"]! as! [String: Any]

    super.init()

    self.mapView.delegate = self

    self.mapView.setCenterCoordinate(initialCameraPosition, animated: false)
    self.setMethodCallHandlers()

    if let annotationsToAdd: NSArray = args["annotationsToAdd"] as? NSArray {
      self.annotationsToAdd(annotations: annotationsToAdd)
    }
    if let polylinesToAdd: NSArray = args["polylinesToAdd"] as? NSArray {
      self.addPolylines(polylineData: polylinesToAdd)
    }
    if let polygonsToAdd: NSArray = args["polygonsToAdd"] as? NSArray {
      self.addPolygons(polygonData: polygonsToAdd)
    }
    if let circlesToAdd: NSArray = args["circlesToAdd"] as? NSArray {
      self.addCircles(circleData: circlesToAdd)
    }
  }

  public func view() -> UIView {
    return contentView
  }

  private func setMethodCallHandlers() {
    channel.setMethodCallHandler({
      [unowned self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if let args: [String: Any] = call.arguments as? [String: Any] {
        switch call.method {
        case "annotations#update":
          self.annotationUpdate(args: args)
          result(nil)
          break
        case "annotations#showInfoWindow":
          self.selectAnnotation(with: args["annotationId"] as! String)
          break
        case "annotations#hideInfoWindow":
          self.hideAnnotation(with: args["annotationId"] as! String)
          break
        case "annotations#isInfoWindowShown":
          result(self.isAnnotationSelected(with: args["annotationId"] as! String))
          break
        case "polylines#update":
          self.polylineUpdate(args: args)
          result(nil)
          break
        case "polygons#update":
          self.polygonUpdate(args: args)
          result(nil)
          break
        case "circles#update":
          self.circleUpdate(args: args)
          result(nil)
          break
        case "map#update":
          self.mapView.interpretOptions(options: args["options"] as! [String: Any])
          break
        case "camera#animate":
          self.animateCamera(args: args)
          result(nil)
          break
        case "camera#move":
          self.moveCamera(args: args)
          result(nil)
          break
        case "camera#convert":
          self.cameraConvert(args: args, result: result)
          break
        case "map#takeSnapshot":
          self.takeSnapshot(
            options: SnapshotOptions.init(options: args),
            onCompletion: { (snapshot: FlutterStandardTypedData?, error: Error?) -> Void in
              result(snapshot ?? error)
            })
        case "route#calculate":
          self.calculateRoute(args: args, result: result)
          break
        case "route#calculateAlternate":
          self.calculateAlternateRoutes(args: args, result: result)
          break
        case "route#calculateETA":
          self.calculateETA(args: args, result: result)
          break
        case "map#updateConfiguration":
          self.updateMapConfiguration(args: args)
          result(nil)
          break
        case "map#updateSelectableFeatures":
          self.updateSelectableFeatures(args: args)
          result(nil)
          break
        case "camera#setBoundary":
          self.setCameraBoundary(args: args)
          result(nil)
          break
        case "camera#setZoomRange":
          self.setCameraZoomRange(args: args)
          result(nil)
          break
        default:
          result(FlutterMethodNotImplemented)
          break
        }
      } else {
        switch call.method {
        case "map#getVisibleRegion":
          result(self.mapView.getVisibleRegion())
          break
        case "map#isCompassEnabled":
          if #available(iOS 9.0, *) {
            result(self.mapView.showsCompass)
          } else {
            result(false)
          }
          break
        case "map#isPitchGesturesEnabled":
          result(self.mapView.isPitchEnabled)
          break
        case "map#isScrollGesturesEnabled":
          result(self.mapView.isScrollEnabled)
          break
        case "map#isZoomGesturesEnabled":
          result(self.mapView.isZoomEnabled)
          break
        case "map#isRotateGesturesEnabled":
          result(self.mapView.isRotateEnabled)
          break
        case "map#isMyLocationButtonEnabled":
          result(self.mapView.isMyLocationButtonShowing ?? false)
          break
        case "map#getMinMaxZoomLevels":
          result([self.mapView.minZoomLevel, self.mapView.maxZoomLevel])
          break
        case "camera#getZoomLevel":
          result(self.mapView.calculatedZoomLevel)
          break
        default:
          result(FlutterMethodNotImplemented)
          break
        }
      }
    })
  }

  private func annotationUpdate(args: [String: Any]) {
    if let annotationsToAdd = args["annotationsToAdd"] as? NSArray {
      if annotationsToAdd.count > 0 {
        self.annotationsToAdd(annotations: annotationsToAdd)
      }
    }
    if let annotationsToChange = args["annotationsToChange"] as? NSArray {
      if annotationsToChange.count > 0 {
        self.annotationsToChange(annotations: annotationsToChange)
      }
    }
    if let annotationsToDelete = args["annotationIdsToRemove"] as? NSArray {
      if annotationsToDelete.count > 0 {
        self.annotationsIdsToRemove(annotationIds: annotationsToDelete)
      }
    }
  }

  private func polygonUpdate(args: [String: Any]) {
    if let polyligonsToAdd: NSArray = args["polygonsToAdd"] as? NSArray {
      self.addPolygons(polygonData: polyligonsToAdd)
    }
    if let polygonsToChange: NSArray = args["polygonsToChange"] as? NSArray {
      self.changePolygons(polygonData: polygonsToChange)
    }
    if let polygonsToRemove: NSArray = args["polygonIdsToRemove"] as? NSArray {
      self.removePolygons(polygonIds: polygonsToRemove)
    }
  }

  private func polylineUpdate(args: [String: Any]) {
    if let polylinesToAdd: NSArray = args["polylinesToAdd"] as? NSArray {
      self.addPolylines(polylineData: polylinesToAdd)
    }
    if let polylinesToChange: NSArray = args["polylinesToChange"] as? NSArray {
      self.changePolylines(polylineData: polylinesToChange)
    }
    if let polylinesToRemove: NSArray = args["polylineIdsToRemove"] as? NSArray {
      self.removePolylines(polylineIds: polylinesToRemove)
    }
  }

  private func circleUpdate(args: [String: Any]) {
    if let circlesToAdd: NSArray = args["circlesToAdd"] as? NSArray {
      self.addCircles(circleData: circlesToAdd)
    }
    if let circlesToChange: NSArray = args["circlesToChange"] as? NSArray {
      self.changeCircles(circleData: circlesToChange)
    }
    if let circlesToRemove: NSArray = args["circleIdsToRemove"] as? NSArray {
      self.removeCircles(circleIds: circlesToRemove)
    }
  }

  private func moveCamera(args: [String: Any]) {
    let positionData: [String: Any] = self.toPositionData(
      data: args["cameraUpdate"] as! [Any], animated: true)
    if !positionData.isEmpty {
      guard positionData["moveToBounds"] != nil else {
        self.mapView.setCenterCoordinate(positionData, animated: false)
        return
      }
      self.mapView.setBounds(positionData, animated: false)
    }
  }

  private func animateCamera(args: [String: Any]) {
    let positionData: [String: Any] = self.toPositionData(
      data: args["cameraUpdate"] as! [Any], animated: true)
    if !positionData.isEmpty {
      guard positionData["moveToBounds"] != nil else {
        self.mapView.setCenterCoordinate(positionData, animated: true)
        return
      }
      self.mapView.setBounds(positionData, animated: true)
    }
  }

  private func cameraConvert(args: [String: Any], result: FlutterResult) {
    guard let annotation = args["annotation"] as? [Double] else {
      result(nil)
      return
    }
    let point = self.mapView.convert(
      CLLocationCoordinate2D(latitude: annotation[0], longitude: annotation[1]),
      toPointTo: self.view())
    result(["point": [point.x, point.y]])
  }

  private func toPositionData(data: [Any], animated: Bool) -> [String: Any] {
    var positionData: [String: Any] = [:]
    if let update: String = data[0] as? String {
      switch update {
      case "newCameraPosition":
        if let _positionData: [String: Any] = data[1] as? [String: Any] {
          positionData = _positionData
        }
      case "newLatLng":
        if let _positionData: [Any] = data[1] as? [Any] {
          positionData = ["target": _positionData]
        }
      case "newLatLngZoom":
        if let _positionData: [Any] = data[1] as? [Any] {
          let zoom: Double = data[2] as? Double ?? 0
          positionData = ["target": _positionData, "zoom": zoom]
        }
      case "newLatLngBounds":
        if let _positionData: [Any] = data[1] as? [Any] {
          let padding: Double = data[2] as? Double ?? 0
          positionData = ["target": _positionData, "padding": padding, "moveToBounds": true]
        }
      case "zoomBy":
        if let zoomBy: Double = data[1] as? Double {
          mapView.zoomBy(zoomBy: zoomBy, animated: animated)
        }
      case "zoomTo":
        if let zoomTo: Double = data[1] as? Double {
          mapView.zoomTo(newZoomLevel: zoomTo, animated: animated)
        }
      case "zoomIn":
        mapView.zoomIn(animated: animated)
      case "zoomOut":
        mapView.zoomOut(animated: animated)
      default:
        positionData = [:]
      }
      return positionData
    }
    return [:]
  }
}

extension AppleMapController: MKMapViewDelegate {
  // onIdle
  public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if (self.mapView.mapContainerView) != nil {
      let locationOnMap = self.mapView.region.center
      self.channel.invokeMethod(
        "camera#onMove",
        arguments: [
          "position": [
            "heading": self.mapView.actualHeading,
            "target": [locationOnMap.latitude, locationOnMap.longitude],
            "pitch": self.mapView.camera.pitch, "zoom": self.mapView.calculatedZoomLevel,
          ]
        ])
    }
    self.channel.invokeMethod("camera#onIdle", arguments: "")
  }

  // onMoveStarted
  public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    self.channel.invokeMethod("camera#onMoveStarted", arguments: "")
  }

  public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is FlutterPolyline {
      return self.polylineRenderer(overlay: overlay)
    } else if overlay is FlutterPolygon {
      return self.polygonRenderer(overlay: overlay)
    } else if overlay is FlutterCircle {
      return self.circleRenderer(overlay: overlay)
    }
    return MKOverlayRenderer()
  }

  // MARK: - POI Selection (iOS 16+)

  @available(iOS 16.0, *)
  public func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
    if let featureAnnotation = annotation as? MKMapFeatureAnnotation {
      handlePOISelection(featureAnnotation)
    }
  }

  @available(iOS 16.0, *)
  public func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
    // 可以在这里处理取消选择的逻辑
    // 例如发送取消选择事件到Dart端
  }

  // MARK: - User Tracking Mode Changes

  public func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
    channel.invokeMethod("location#onTrackingModeChanged", arguments: [
      "mode": mode.rawValue,
      "animated": animated
    ])
  }

  public func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
    // 可选: 通知 Dart 开始定位
  }

  public func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
    // 可选: 通知 Dart 停止定位
  }

  public func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
    channel.invokeMethod("location#onError", arguments: [
      "code": "unknown",
      "message": error.localizedDescription,
      "details": nil
    ])
  }

  // 处理POI选择事件
  @available(iOS 16.0, *)
  private func handlePOISelection(_ annotation: MKMapFeatureAnnotation) {
    let poiData = POIHandler.serializePOIAnnotation(annotation)
    channel.invokeMethod("poi#onSelected", arguments: poiData)
  }
}

extension AppleMapController {
  private func takeSnapshot(
    options: SnapshotOptions, onCompletion: @escaping (FlutterStandardTypedData?, Error?) -> Void
  ) {
    // MKMapSnapShotOptions setting.
    snapShotOptions.region = self.mapView.region
    snapShotOptions.size = self.mapView.frame.size
    snapShotOptions.scale = UIScreen.main.scale
    snapShotOptions.showsBuildings = options.showBuildings
    snapShotOptions.showsPointsOfInterest = options.showPointsOfInterest

    // Set MKMapSnapShotOptions to MKMapSnapShotter.
    snapShot = MKMapSnapshotter(options: snapShotOptions)

    snapShot?.cancel()

    if #available(iOS 10.0, *) {
      snapShot?.start { [weak self] snapshot, error in
        guard let self = self else {
          return
        }

        guard let snapshot = snapshot, error == nil else {
          onCompletion(nil, error)
          return
        }

        let image = UIGraphicsImageRenderer(size: self.snapShotOptions.size).image {
          [weak self] context in
          guard let self = self else {
            return
          }
          snapshot.image.draw(at: .zero)
          let rect = self.snapShotOptions.mapRect
          if options.showAnnotations {
            for annotation in self.mapView.getMapViewAnnotations() {
              self.drawAnnotations(
                annotation: annotation, point: snapshot.point(for: annotation!.coordinate))
            }
          }
          if options.showOverlays {
            for overlay in self.mapView.overlays {
              if (overlay.intersects?(rect)) != nil {
                self.drawOverlays(overlay: overlay, snapshot: snapshot, context: context)
              }
            }
          }
        }

        if let imageData = image.pngData() {
          onCompletion(FlutterStandardTypedData.init(bytes: imageData), nil)
        }
      }
    }
  }

  private func drawAnnotations(annotation: FlutterAnnotation?, point: CGPoint) {
    guard annotation != nil else {
      return
    }
    let annotationView = self.getAnnotationView(annotation: annotation!)

    var offsetPoint = point

    offsetPoint.x -= annotationView.bounds.width / 2
    offsetPoint.y -= annotationView.bounds.height / 2

    if #available(iOS 11.0, *), annotationView is MKMarkerAnnotationView {
      annotationView.drawHierarchy(
        in: CGRect(
          x: offsetPoint.x, y: offsetPoint.y, width: annotationView.bounds.width,
          height: annotationView.bounds.height), afterScreenUpdates: true)
    } else {
      offsetPoint.x += annotationView.centerOffset.x
      offsetPoint.y += annotationView.centerOffset.y
      let annotationImage = annotationView.image
      annotationImage?.draw(at: offsetPoint)
    }
  }

  @available(iOS 10.0, *)
  private func drawOverlays(
    overlay: MKOverlay?, snapshot: MKMapSnapshotter.Snapshot, context: UIGraphicsRendererContext
  ) {
    guard overlay != nil else {
      return
    }

    if let flutterOverlay: FlutterOverlay = overlay as? FlutterOverlay {
      flutterOverlay.getCAShapeLayer(snapshot: snapshot).render(in: context.cgContext)
    }

  }

  // MARK: - Route Calculation Methods

  /// 计算单条路线
  private func calculateRoute(args: [String: Any], result: @escaping FlutterResult) {
    // 提取参数
    guard let originLat = args["originLat"] as? Double,
      let originLng = args["originLng"] as? Double,
      let destLat = args["destLat"] as? Double,
      let destLng = args["destLng"] as? Double
    else {
      result(
        FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "Missing or invalid coordinates",
          details: "originLat, originLng, destLat, destLng are required"
        ))
      return
    }

    let origin = CLLocationCoordinate2D(latitude: originLat, longitude: originLng)
    let destination = CLLocationCoordinate2D(latitude: destLat, longitude: destLng)

    // 解析交通方式
    let transportTypeString = args["transportType"] as? String ?? "automobile"
    let transportType = self.parseTransportType(transportTypeString)

    // 创建路线计算器
    let calculator = RouteCalculator()

    // 执行计算
    calculator.calculateRoute(
      origin: origin,
      destination: destination,
      transportType: transportType
    ) { routeResult in
      switch routeResult {
      case .success(let route):
        result(route.toDictionary())
      case .failure(let error):
        // 构建详细的错误信息
        print("🔍 Error type: \(type(of: error))")
        print("🔍 Error: \(error)")

        var errorCode = "ROUTE_ERROR"
        var errorDetails: [String: Any] = [:]

        if let routeError = error as? RouteCalculatorError {
          print("✅ Recognized as RouteCalculatorError")
          errorCode = routeError.getDetailedInfo()["errorType"] as? String ?? "ROUTE_ERROR"
          errorDetails = routeError.getDetailedInfo()
        } else {
          print("⚠️ Not recognized as RouteCalculatorError, treating as generic error")
          let nsError = error as NSError
          errorDetails = [
            "errorType": "UNKNOWN",
            "code": nsError.code,
            "domain": nsError.domain,
            "description": nsError.localizedDescription,
            "underlyingError": nsError.localizedDescription,
            "userInfo": String(describing: nsError.userInfo),
          ]
        }

        result(
          FlutterError(
            code: errorCode,
            message: error.localizedDescription,
            details: errorDetails
          ))
      }
    }
  }

  /// 计算多条备选路线
  private func calculateAlternateRoutes(args: [String: Any], result: @escaping FlutterResult) {
    guard let originLat = args["originLat"] as? Double,
      let originLng = args["originLng"] as? Double,
      let destLat = args["destLat"] as? Double,
      let destLng = args["destLng"] as? Double
    else {
      result(
        FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "Missing or invalid coordinates",
          details: "originLat, originLng, destLat, destLng are required"
        ))
      return
    }

    let origin = CLLocationCoordinate2D(latitude: originLat, longitude: originLng)
    let destination = CLLocationCoordinate2D(latitude: destLat, longitude: destLng)

    let transportTypeString = args["transportType"] as? String ?? "automobile"
    let transportType = self.parseTransportType(transportTypeString)

    let calculator = RouteCalculator()

    calculator.calculateAlternateRoutes(
      origin: origin,
      destination: destination,
      transportType: transportType
    ) { routeResult in
      switch routeResult {
      case .success(let routes):
        let routeDicts = routes.map { $0.toDictionary() }
        result(routeDicts)
      case .failure(let error):
        // 构建详细的错误信息
        var errorCode = "ROUTE_ERROR"
        var errorDetails: [String: Any] = [:]

        if let routeError = error as? RouteCalculatorError {
          errorCode = routeError.getDetailedInfo()["errorType"] as? String ?? "ROUTE_ERROR"
          errorDetails = routeError.getDetailedInfo()
        } else {
          let nsError = error as NSError
          errorDetails = [
            "errorType": "UNKNOWN",
            "code": nsError.code,
            "domain": nsError.domain,
            "description": nsError.localizedDescription,
            "userInfo": String(describing: nsError.userInfo),
          ]
        }

        result(
          FlutterError(
            code: errorCode,
            message: error.localizedDescription,
            details: errorDetails
          ))
      }
    }
  }

  /// 计算 ETA（预计到达时间）
  private func calculateETA(args: [String: Any], result: @escaping FlutterResult) {
    guard let originLat = args["originLat"] as? Double,
      let originLng = args["originLng"] as? Double,
      let destLat = args["destLat"] as? Double,
      let destLng = args["destLng"] as? Double
    else {
      result(
        FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "Missing or invalid coordinates",
          details: "originLat, originLng, destLat, destLng are required"
        ))
      return
    }

    let origin = CLLocationCoordinate2D(latitude: originLat, longitude: originLng)
    let destination = CLLocationCoordinate2D(latitude: destLat, longitude: destLng)

    let transportTypeString = args["transportType"] as? String ?? "automobile"
    let transportType = self.parseTransportType(transportTypeString)

    let calculator = RouteCalculator()

    calculator.calculateETA(
      origin: origin,
      destination: destination,
      transportType: transportType
    ) { etaResult in
      switch etaResult {
      case .success(let eta):
        result(eta)
      case .failure(let error):
        // 构建详细的错误信息
        var errorCode = "ROUTE_ERROR"
        var errorDetails: [String: Any] = [:]

        if let routeError = error as? RouteCalculatorError {
          errorCode = routeError.getDetailedInfo()["errorType"] as? String ?? "ROUTE_ERROR"
          errorDetails = routeError.getDetailedInfo()
        } else {
          let nsError = error as NSError
          errorDetails = [
            "errorType": "UNKNOWN",
            "code": nsError.code,
            "domain": nsError.domain,
            "description": nsError.localizedDescription,
            "userInfo": String(describing: nsError.userInfo),
          ]
        }

        result(
          FlutterError(
            code: errorCode,
            message: error.localizedDescription,
            details: errorDetails
          ))
      }
    }
  }

  // MARK: - POI and Map Configuration Methods (iOS 16+)

  /// 更新地图配置
  private func updateMapConfiguration(args: [String: Any]) {
    if #available(iOS 16.0, *) {
      if let config = MapConfigurationHandler.createConfiguration(args) {
        mapView.preferredConfiguration = config
      }
    } else {
      // iOS 16以下，回退到mapType
      if let typeString = args["type"] as? String,
         let configType = MapConfigurationType(rawValue: typeString) {
        switch configType {
        case .standard:
          mapView.mapType = .standard
        case .hybrid:
          mapView.mapType = .hybrid
        case .imagery:
          mapView.mapType = .satellite
        }
      }
    }
  }

  /// 更新可选择的地图特性
  private func updateSelectableFeatures(args: [String: Any]) {
    if #available(iOS 16.0, *) {
      if let featuresOptions = args["features"] as? [String: Any] {
        mapView.selectableMapFeatures = POIHandler.parseMapFeatureOptions(featuresOptions)
      }
    }
  }

  // MARK: - Camera Constraints Methods (iOS 13+)

  /// 设置相机平移边界
  private func setCameraBoundary(args: [String: Any]) {
    guard let boundaryData = args["boundary"] as? [Any] else {
      if #available(iOS 13.0, *) {
        // Clear the boundary by setting an empty one
        mapView.setCameraBoundary(MKMapView.CameraBoundary(), animated: false)
      }
      return
    }
    guard let animated = args["animated"] as? Bool else { return }

    if #available(iOS 13.0, *) {
      let boundaryType = boundaryData[0] as! String

      if boundaryType == "bounds" {
        let boundsData = boundaryData[1] as! [[Double]]
        let NE = CLLocationCoordinate2D(
          latitude: boundsData[1][0],
          longitude: boundsData[1][1]
        )
        let SW = CLLocationCoordinate2D(
          latitude: boundsData[0][0],
          longitude: boundsData[0][1]
        )
        let mapRect = MKMapRect(
          origin: MKMapPoint(SW),
          size: MKMapSize(
            width: MKMapPoint(NE).x - MKMapPoint(SW).x,
            height: MKMapPoint(NE).y - MKMapPoint(SW).y
          )
        )
        // Note: mapRect initializer may return optional in some iOS versions
        if let boundary = MKMapView.CameraBoundary(mapRect: mapRect) {
          mapView.setCameraBoundary(boundary, animated: animated)
        }
      } else {
        // region type - note: coordinateRegion initializer returns optional
        let regionData = boundaryData[1] as! [String: Any]
        let center = CLLocationCoordinate2D(
          latitude: (regionData["center"] as! [Double])[0],
          longitude: (regionData["center"] as! [Double])[1]
        )
        let span = MKCoordinateSpan(
          latitudeDelta: regionData["latitudeDelta"] as! Double,
          longitudeDelta: regionData["longitudeDelta"] as! Double
        )
        let coordinateRegion = MKCoordinateRegion(center: center, span: span)
        if let boundary = MKMapView.CameraBoundary(coordinateRegion: coordinateRegion) {
          mapView.setCameraBoundary(boundary, animated: animated)
        }
      }
    }
  }

  /// 设置相机缩放范围
  private func setCameraZoomRange(args: [String: Any]) {
    guard let zoomRangeData = args["zoomRange"] as? [Any] else {
      if #available(iOS 13.0, *) {
        mapView.cameraZoomRange = nil
      }
      return
    }
    guard let animated = args["animated"] as? Bool else { return }

    if #available(iOS 13.0, *) {
      let minDistance = zoomRangeData[0] as! Double
      let maxDistance = zoomRangeData[1] as! Double
      let zoomRange = MKMapView.CameraZoomRange(
        minCenterCoordinateDistance: minDistance,
        maxCenterCoordinateDistance: maxDistance
      )
      mapView.setCameraZoomRange(zoomRange, animated: animated)
    }
  }

  /// 解析交通方式字符串
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
}
