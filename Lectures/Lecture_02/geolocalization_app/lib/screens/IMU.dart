// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, use_build_context_synchronously

import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:fl_chart/fl_chart.dart';

import 'snake.dart';

enum ThrowState { idle, throwing, freeFall, landed }

class IMUPage extends StatefulWidget {
  const IMUPage({super.key, this.title});

  final String? title;

  @override
  State<IMUPage> createState() => _IMUPageState();
}

class _IMUPageState extends State<IMUPage> {
  static const Duration _ignoreDuration = Duration(milliseconds: 20);
  static const int _maxDataPoints = 2000; // Store 2000 points

  UserAccelerometerEvent? _userAccelerometerEvent;
  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  MagnetometerEvent? _magnetometerEvent;

  DateTime? _userAccelerometerUpdateTime;
  DateTime? _accelerometerUpdateTime;
  DateTime? _gyroscopeUpdateTime;
  DateTime? _magnetometerUpdateTime;

  int? _userAccelerometerLastInterval;
  int? _accelerometerLastInterval;
  int? _gyroscopeLastInterval;
  int? _magnetometerLastInterval;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  Duration sensorInterval = SensorInterval.gameInterval;

  // Data storage for graphs
  final Queue<FlSpot> _userAccelXData = Queue();
  final Queue<FlSpot> _userAccelYData = Queue();
  final Queue<FlSpot> _userAccelZData = Queue();
  final Queue<FlSpot> _accelXData = Queue();
  final Queue<FlSpot> _accelYData = Queue();
  final Queue<FlSpot> _accelZData = Queue();
  final Queue<FlSpot> _gyroXData = Queue();
  final Queue<FlSpot> _gyroYData = Queue();
  final Queue<FlSpot> _gyroZData = Queue();
  final Queue<FlSpot> _magXData = Queue();
  final Queue<FlSpot> _magYData = Queue();
  final Queue<FlSpot> _magZData = Queue();
  final Queue<FlSpot> _pressureData = Queue();

  late DateTime _startTime;

  // Throw detection variables - record and analyze approach
  double _bestHeight = 0.0;
  final Queue<MapEntry<DateTime, double>> _zAxisBuffer = Queue();
  DateTime? _lastAnalysisTime;
  static const Duration _analysisInterval = Duration(milliseconds: 100);
  static const int _bufferSize = 200;
  static const double _maxReasonableHeight = 50.0; // meters (prevent cheating)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMU Sensor Dashboard'),
        elevation: 4,
      ),
      body: PageView(
        children: [
          _buildSensorDataScreen(),
          _buildThrowScreen(),
          _buildGraphScreen(),
        ],
      ),
    );
  }

  Widget _buildSensorDataScreen() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Real-time Sensor Data\nSwipe → for Throw Test or Graphs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(width: 1.0, color: Colors.black38),
              ),
              child: SizedBox(
                height: 200,
                width: 200,
                child: Snake(
                  rows: 20,
                  columns: 20,
                  cellSize: 10.0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(4),
                4: FlexColumnWidth(2),
              },
              children: [
                const TableRow(
                  children: [
                    SizedBox.shrink(),
                    Text('X'),
                    Text('Y'),
                    Text('Z'),
                    Text('Interval'),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('UserAccelerometer'),
                    ),
                    Text(_userAccelerometerEvent?.x.toStringAsFixed(1) ?? '?'),
                    Text(_userAccelerometerEvent?.y.toStringAsFixed(1) ?? '?'),
                    Text(_userAccelerometerEvent?.z.toStringAsFixed(1) ?? '?'),
                    Text(
                        '${_userAccelerometerLastInterval?.toString() ?? '?'} ms'),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Accelerometer'),
                    ),
                    Text(_accelerometerEvent?.x.toStringAsFixed(1) ?? '?'),
                    Text(_accelerometerEvent?.y.toStringAsFixed(1) ?? '?'),
                    Text(_accelerometerEvent?.z.toStringAsFixed(1) ?? '?'),
                    Text('${_accelerometerLastInterval?.toString() ?? '?'} ms'),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Gyroscope'),
                    ),
                    Text(_gyroscopeEvent?.x.toStringAsFixed(1) ?? '?'),
                    Text(_gyroscopeEvent?.y.toStringAsFixed(1) ?? '?'),
                    Text(_gyroscopeEvent?.z.toStringAsFixed(1) ?? '?'),
                    Text('${_gyroscopeLastInterval?.toString() ?? '?'} ms'),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Magnetometer'),
                    ),
                    Text(_magnetometerEvent?.x.toStringAsFixed(1) ?? '?'),
                    Text(_magnetometerEvent?.y.toStringAsFixed(1) ?? '?'),
                    Text(_magnetometerEvent?.z.toStringAsFixed(1) ?? '?'),
                    Text('${_magnetometerLastInterval?.toString() ?? '?'} ms'),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(4),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(2),
              },
              children: [
                const TableRow(
                  children: [
                    SizedBox.shrink(),
                    Text('Pressure'),
                    Text('Interval'),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Update Interval:'),
              SegmentedButton(
                segments: [
                  ButtonSegment(
                    value: SensorInterval.gameInterval,
                    label: Text('Game\n'
                        '(${SensorInterval.gameInterval.inMilliseconds}ms)'),
                  ),
                  ButtonSegment(
                    value: SensorInterval.uiInterval,
                    label: Text('UI\n'
                        '(${SensorInterval.uiInterval.inMilliseconds}ms)'),
                  ),
                  ButtonSegment(
                    value: SensorInterval.normalInterval,
                    label: Text('Normal\n'
                        '(${SensorInterval.normalInterval.inMilliseconds}ms)'),
                  ),
                  const ButtonSegment(
                    value: Duration(milliseconds: 500),
                    label: Text('500ms'),
                  ),
                  const ButtonSegment(
                    value: Duration(seconds: 1),
                    label: Text('1s'),
                  ),
                ],
                selected: {sensorInterval},
                showSelectedIcon: false,
                onSelectionChanged: (value) {
                  setState(() {
                    sensorInterval = value.first;
                    _setupSensorStreams();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGraphScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Sensor Data Graphs\nSwipe ← or → to navigate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildChart('User Accelerometer', [
              _createLineChartBarData(_userAccelXData, Colors.red, 'X'),
              _createLineChartBarData(_userAccelYData, Colors.green, 'Y'),
              _createLineChartBarData(_userAccelZData, Colors.blue, 'Z'),
            ]),
            _buildLegend(),
            const SizedBox(height: 20),
            _buildChart('Accelerometer', [
              _createLineChartBarData(_accelXData, Colors.red, 'X'),
              _createLineChartBarData(_accelYData, Colors.green, 'Y'),
              _createLineChartBarData(_accelZData, Colors.blue, 'Z'),
            ]),
            const SizedBox(height: 20),
            _buildChart('Gyroscope', [
              _createLineChartBarData(_gyroXData, Colors.red, 'X'),
              _createLineChartBarData(_gyroYData, Colors.green, 'Y'),
              _createLineChartBarData(_gyroZData, Colors.blue, 'Z'),
            ]),
            const SizedBox(height: 20),
            _buildChart('Magnetometer', [
              _createLineChartBarData(_magXData, Colors.red, 'X'),
              _createLineChartBarData(_magYData, Colors.green, 'Y'),
              _createLineChartBarData(_magZData, Colors.blue, 'Z'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildThrowScreen() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Phone Throw Height Detector',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.green.shade50,
                ),
                child: Column(
                  children: [
                    Text(
                      'Best Throw',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _bestHeight > 0 ? '${_bestHeight.toStringAsFixed(2)} m' : '0.00 m',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _bestHeight = 0.0;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                      ),
                      child: const Text('Reset', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              const Text(
                'Instructions:\n1. Hold phone firmly\n2. Throw straight up\n3. Let phone land (safe surface!)\n\nSwipe → for Graphs',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(String title, List<LineChartBarData> lineBarsData) {
    // Set Y-axis ranges based on sensor type
    final (minY, maxY) = switch (title) {
      'User Accelerometer' || 'Accelerometer' => (-20.0, 20.0),
      'Gyroscope' => (-10.0, 10.0),
      'Magnetometer' => (-100.0, 100.0),
      _ => (-20.0, 20.0),
    };

    // Fixed time window - always show last 30 seconds
    const timeWindow = 30.0;
    final now = DateTime.now().difference(_startTime).inMilliseconds / 1000.0;
    final minX = (now - timeWindow).clamp(0.0, double.infinity);
    final maxX = minX + timeWindow;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: lineBarsData,
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.red, 'X'),
        const SizedBox(width: 20),
        _buildLegendItem(Colors.green, 'Y'),
        const SizedBox(width: 20),
        _buildLegendItem(Colors.blue, 'Z'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 2,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  LineChartBarData _createLineChartBarData(
      Queue<FlSpot> data, Color color, String label) {
    return LineChartBarData(
      spots: data.toList(),
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: false),
    );
  }

  void _addDataPoint(Queue<FlSpot> dataQueue, double value) {
    final timeInSeconds = DateTime.now().difference(_startTime).inMilliseconds / 1000.0;
    dataQueue.add(FlSpot(timeInSeconds, value));
    
    // Remove data points older than 30 seconds to keep the window clean
    const timeWindow = 30.0;
    final cutoffTime = timeInSeconds - timeWindow;
    
    while (dataQueue.isNotEmpty && dataQueue.first.x < cutoffTime) {
      dataQueue.removeFirst();
    }
    
    // Also limit maximum data points as a safety measure
    if (dataQueue.length > _maxDataPoints) {
      dataQueue.removeFirst();
    }
  }

  void _setupSensorStreams() {
    // Cancel existing subscriptions
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();

    // Setup new subscriptions with updated interval
    _streamSubscriptions.add(
      userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
        (UserAccelerometerEvent event) {
          final now = event.timestamp;
          // Always add data points
          _addDataPoint(_userAccelXData, event.x);
          _addDataPoint(_userAccelYData, event.y);
          _addDataPoint(_userAccelZData, event.z);
          
          // Update UI
          setState(() {
            _userAccelerometerEvent = event;
            if (_userAccelerometerUpdateTime != null) {
              final interval = now.difference(_userAccelerometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _userAccelerometerLastInterval = interval.inMilliseconds;
              }
            }
          });
          _userAccelerometerUpdateTime = now;
        },
        onError: (e) {
          _showSensorErrorDialog("User Accelerometer");
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      accelerometerEventStream(samplingPeriod: sensorInterval).listen(
        (AccelerometerEvent event) {
          final now = event.timestamp;
          // Always add data points
          _addDataPoint(_accelXData, event.x);
          _addDataPoint(_accelYData, event.y);
          _addDataPoint(_accelZData, event.z);
          
          // Process throw detection
          _processThrowDetection(event);
          
          // Update UI
          setState(() {
            _accelerometerEvent = event;
            if (_accelerometerUpdateTime != null) {
              final interval = now.difference(_accelerometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _accelerometerLastInterval = interval.inMilliseconds;
              }
            }
          });
          _accelerometerUpdateTime = now;
        },
        onError: (e) {
          _showSensorErrorDialog("Accelerometer");
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEventStream(samplingPeriod: sensorInterval).listen(
        (GyroscopeEvent event) {
          final now = event.timestamp;
          // Always add data points
          _addDataPoint(_gyroXData, event.x);
          _addDataPoint(_gyroYData, event.y);
          _addDataPoint(_gyroZData, event.z);
          
          // Update UI
          setState(() {
            _gyroscopeEvent = event;
            if (_gyroscopeUpdateTime != null) {
              final interval = now.difference(_gyroscopeUpdateTime!);
              if (interval > _ignoreDuration) {
                _gyroscopeLastInterval = interval.inMilliseconds;
              }
            }
          });
          _gyroscopeUpdateTime = now;
        },
        onError: (e) {
          _showSensorErrorDialog("Gyroscope");
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      magnetometerEventStream(samplingPeriod: sensorInterval).listen(
        (MagnetometerEvent event) {
          final now = event.timestamp;
          // Always add data points
          _addDataPoint(_magXData, event.x);
          _addDataPoint(_magYData, event.y);
          _addDataPoint(_magZData, event.z);
          
          // Update UI
          setState(() {
            _magnetometerEvent = event;
            if (_magnetometerUpdateTime != null) {
              final interval = now.difference(_magnetometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _magnetometerLastInterval = interval.inMilliseconds;
              }
            }
          });
          _magnetometerUpdateTime = now;
        },
        onError: (e) {
          _showSensorErrorDialog("Magnetometer");
        },
        cancelOnError: true,
      ),
    );
  }

  void _showSensorErrorDialog(String sensorName) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Sensor Not Found"),
            content: Text(
                "It seems that your device doesn't support $sensorName Sensor"),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _setupSensorStreams();
  }

  // Helper methods for throw detection
  double _calculateHeight(Duration airtime) {
    // h = 0.5 * g * t²
    final seconds = airtime.inMilliseconds / 1000.0;
    const g = 5.0; // adjusted gravity constant for sensor calibration
    return 0.5 * g * seconds * seconds;
  }  void _processThrowDetection(AccelerometerEvent event) {
    // Record Z-axis data with timestamp
    _zAxisBuffer.addLast(MapEntry(DateTime.now(), event.z));
    
    // Keep buffer at fixed size
    while (_zAxisBuffer.length > _bufferSize) {
      _zAxisBuffer.removeFirst();
    }

    // Run analysis on configurable interval
    final now = DateTime.now();
    if (_lastAnalysisTime == null || now.difference(_lastAnalysisTime!) >= _analysisInterval) {
      _lastAnalysisTime = now;
      _analyzeThrowPattern();
    }
  }

  void _analyzeThrowPattern() {
    if (_zAxisBuffer.length < 20) return; // Need enough data points

    final data = _zAxisBuffer.toList();
    
    // Find high acceleration region (throw phase)
    int highPeakIdx = -1;
    double maxZ = double.negativeInfinity;
    for (int i = 0; i < data.length; i++) {
      if (data[i].value > maxZ) {
        maxZ = data[i].value;
        highPeakIdx = i;
      }
    }

    // Need a significant acceleration peak
    if (maxZ < 10.0) return;

    // Look for low acceleration region after the peak (free fall)
    int lowPeakIdx = -1;
    int stableLowCount = 0;
    const lowThreshold = 2.0;
    const minStablePoints = 5;

    for (int i = highPeakIdx + 1; i < data.length; i++) {
      if (data[i].value.abs() < lowThreshold) {
        stableLowCount++;
        if (stableLowCount >= minStablePoints && lowPeakIdx == -1) {
          lowPeakIdx = i - minStablePoints;
          break;
        }
      } else {
        stableLowCount = 0;
      }
    }

    // Need both a throw peak and a low region
    if (lowPeakIdx == -1 || lowPeakIdx <= highPeakIdx) return;

    // Find where low region ends (impact or stabilization)
    int endIdx = lowPeakIdx;
    for (int i = lowPeakIdx + minStablePoints; i < data.length; i++) {
      if (data[i].value.abs() > lowThreshold) {
        endIdx = i;
        break;
      }
      endIdx = i;
    }

    // Calculate free fall duration
    final startTime = data[lowPeakIdx].key;
    final endTime = data[endIdx].key;
    final flightDuration = endTime.difference(startTime);
    
    // Calculate height
    final height = _calculateHeight(flightDuration);

    // Validate and update
    if (height > 0.1 && height < _maxReasonableHeight) {
      if (height > _bestHeight) {
        _bestHeight = height;
        if (mounted) setState(() {});
      }
    }

    // Clear buffer after successful detection to avoid duplicates
    _zAxisBuffer.clear();
  }
}