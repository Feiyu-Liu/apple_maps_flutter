// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:apple_maps_flutter_example/page.dart';
import 'package:flutter/material.dart';

class CameraLocationExample extends StatefulWidget {
  const CameraLocationExample({Key? key}) : super(key: key);

  static const String route = '/camera_location_example';

  @override
  State<CameraLocationExample> createState() => _CameraLocationExampleState();
}

class _CameraLocationExampleState extends State<CameraLocationExample> {
  late AppleMapController mapController;
  LocationData? currentLocation;
  String locationStatus = '等待定位...';
  CameraBoundary? boundary;
  CameraZoomRange? zoomRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('相机约束与位置跟踪')),
      body: Stack(
        children: [
          AppleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194),
              zoom: 12,
            ),
            // Camera constraints
            cameraBoundary: boundary,
            cameraZoomRange: zoomRange,
            // Location tracking
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            trackingMode: TrackingMode.follow,
            onLocationChanged: _onLocationChanged,
            onLocationError: _onLocationError,
            onUserTrackingModeChanged: _onTrackingModeChanged,
            onMapCreated: _onMapCreated,
          ),
          // Info panel
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('位置状态: $locationStatus',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (currentLocation != null) ...[
                      const SizedBox(height: 8),
                      Text(
                          '纬度: ${currentLocation!.latitude.toStringAsFixed(6)}'),
                      Text(
                          '经度: ${currentLocation!.longitude.toStringAsFixed(6)}'),
                      if (currentLocation!.accuracy != null)
                        Text(
                            '精度: ${currentLocation!.accuracy!.toStringAsFixed(1)}m'),
                      if (currentLocation!.altitude != null)
                        Text(
                            '海拔: ${currentLocation!.altitude!.toStringAsFixed(1)}m'),
                      if (currentLocation!.speed != null &&
                          currentLocation!.speed! > 0)
                        Text(
                            '速度: ${currentLocation!.speed!.toStringAsFixed(1)}m/s'),
                      if (currentLocation!.heading != null &&
                          currentLocation!.heading! >= 0)
                        Text(
                            '方向: ${currentLocation!.heading!.toStringAsFixed(0)}°'),
                      if (currentLocation!.timestamp != null)
                        Text(
                            '时间: ${currentLocation!.timestamp!.toLocal().toString().substring(0, 19)}'),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Control panel
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('相机约束',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () => _setCameraBoundary(true),
                          child: const Text('边界(Bounds)',
                              style: TextStyle(fontSize: 12)),
                        ),
                        ElevatedButton(
                          onPressed: () => _setCameraBoundary(false),
                          child: const Text('边界(Region)',
                              style: TextStyle(fontSize: 12)),
                        ),
                        ElevatedButton(
                          onPressed: _clearCameraBoundary,
                          child: const Text('清除边界',
                              style: TextStyle(fontSize: 12)),
                        ),
                        ElevatedButton(
                          onPressed: _setCameraZoomRange,
                          child: const Text('缩放限制',
                              style: TextStyle(fontSize: 12)),
                        ),
                        ElevatedButton(
                          onPressed: _clearCameraZoomRange,
                          child: const Text('清除缩放',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                        '当前: ${boundary != null ? "已设置边界" : "无边界"}, ${zoomRange != null ? "已限制缩放" : "无缩放限制"}',
                        style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(AppleMapController controller) {
    mapController = controller;
  }

  void _onLocationChanged(LocationData location) {
    setState(() {
      currentLocation = location;
      locationStatus = '位置更新';
    });
  }

  void _onLocationError(LocationError error) {
    setState(() {
      locationStatus = '错误: ${error.message}';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('位置错误: ${error.message}')),
    );
  }

  void _onTrackingModeChanged(TrackingMode mode, bool animated) {
    debugPrint('跟踪模式变化: $mode, 动画: $animated');
  }

  void _setCameraBoundary(bool useBounds) {
    setState(() {
      if (useBounds) {
        // San Francisco Bay Area
        boundary = CameraBoundary.fromBounds(
          LatLngBounds(
            southwest: LatLng(37.4, -122.5),
            northeast: LatLng(37.8, -122.0),
          ),
        );
      } else {
        // Center on SF with delta
        boundary = CameraBoundary.fromRegion(
          center: LatLng(37.7749, -122.4194),
          latitudeDelta: 0.2,
          longitudeDelta: 0.2,
        );
      }
    });
  }

  void _clearCameraBoundary() {
    setState(() {
      boundary = CameraBoundary.unbounded;
    });
  }

  void _setCameraZoomRange() {
    setState(() {
      zoomRange = const CameraZoomRange(
        minCenterCoordinateDistance: 1000, // 1km minimum
        maxCenterCoordinateDistance: 50000, // 50km maximum
      );
    });
  }

  void _clearCameraZoomRange() {
    setState(() {
      zoomRange = CameraZoomRange.unbounded;
    });
  }
}

class CameraLocationPage extends ExamplePage {
  const CameraLocationPage()
      : super(
          const Icon(Icons.map),
          '相机约束与位置跟踪',
        );

  @override
  Widget build(BuildContext context) {
    return const CameraLocationExample();
  }
}
