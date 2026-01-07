// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

///
/// 独立运行的BackdropFilter + MapView演示页面
///
/// 运行方式：
/// 1. 修改example/lib/main.dart，将home改为BackdropFilterDemoStandalone()
/// 2. 或者直接运行: flutter run lib/backdrop_filter_demo_standalone.dart
///

import 'dart:ui';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BackdropFilterDemoApp());
}

class BackdropFilterDemoApp extends StatelessWidget {
  const BackdropFilterDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BackdropFilter + MapView Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BackdropFilterDemoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BackdropFilterDemoPage extends StatefulWidget {
  const BackdropFilterDemoPage({Key? key}) : super(key: key);

  @override
  State<BackdropFilterDemoPage> createState() => _BackdropFilterDemoPageState();
}

class _BackdropFilterDemoPageState extends State<BackdropFilterDemoPage> {
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(31.2304, 121.4737), // 上海
    zoom: 12,
  );

  bool _showWrongExample = false; // 切换显示错误示例

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ============================
          // 底层：MapView (Platform View)
          // ============================
          AppleMap(
            initialCameraPosition: _kInitialPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            mapType: MapType.standard,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            pitchGesturesEnabled: true,
            zoomGesturesEnabled: true,
          ),

          // ============================
          // 上层：高斯模糊演示卡片
          // ============================
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题说明卡片
                _buildTitleCard(),

                const SizedBox(height: 20),

                // 正确示例
                _buildCorrectExample(),

                const SizedBox(height: 20),

                // 错误示例（可选显示）
                _buildWrongExample(),

                const SizedBox(height: 20),

                // 切换按钮
                _buildToggleButton(),

                const SizedBox(height: 20),

                // 说明文字
                _buildExplanation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 标题卡片
  Widget _buildTitleCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'BackdropFilter + Platform View',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'MapView是Platform View，渲染在原生iOS层。\n'
                '使用BackdropFilter时必须用ClipRRect裁剪。',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ 正确示例：使用ClipRRect包裹BackdropFilter
  Widget _buildCorrectExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 绿色标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '✅ 正确写法',
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // 正确的高斯模糊卡片
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ClipRRect + BackdropFilter',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '完美！高斯模糊效果被正确裁剪为圆角。',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ❌ 错误示例：仅使用BoxDecoration
  Widget _buildWrongExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 红色标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '❌ 错误写法',
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // 如果显示错误示例
        if (_showWrongExample)
          Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BoxDecoration + BackdropFilter',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '注意观察：高斯模糊效果延伸到圆角之外！\n'
                    '因为BoxDecoration无法裁剪Platform View。',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 如果不显示错误示例，显示占位
        if (!_showWrongExample)
          Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.3),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Center(
              child: Text(
                '点击下方按钮查看错误示例',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 切换按钮
  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showWrongExample = !_showWrongExample;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _showWrongExample ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  _showWrongExample ? '隐藏错误示例' : '显示错误示例',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 技术说明
  Widget _buildExplanation() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.code, color: Colors.white70, size: 16),
                  SizedBox(width: 8),
                  Text(
                    '技术原理',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                '│ Flutter Widget层     │  ← ClipRRect在此层裁剪',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
              ),
              Text(
                '│ └─ BackdropFilter   │  ← 捕获后方内容并模糊',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
              ),
              Text(
                '├─────────────────────┤',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
              ),
              Text(
                '│ Platform View粘合层  │',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
              ),
              Text(
                '├─────────────────────┤',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
              ),
              Text(
                '│ 原生视图层 (MKMapView)│  ← Platform View在此层渲染',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
