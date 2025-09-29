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

// Game enums and data structures
enum GameMode { freeFall, throwCatch }
enum GameState { ready, active, analyzing, finished }

class GameResult {
  final double duration;
  final double maxAcceleration;
  final double minAcceleration;
  final double? estimatedHeight;
  final DateTime timestamp;
  
  GameResult({
    required this.duration,
    required this.maxAcceleration,
    required this.minAcceleration,
    this.estimatedHeight,
    required this.timestamp,
  });
}

class IMUPage extends StatefulWidget {
  const IMUPage({super.key, this.title});

  final String? title;

  @override
  State<IMUPage> createState() => _IMUPageState();
}

class _IMUPageState extends State<IMUPage> {
  static const Duration _ignoreDuration = Duration(milliseconds: 20);
  static const int _maxDataPoints = 100;

  UserAccelerometerEvent? _userAccelerometerEvent;
  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  MagnetometerEvent? _magnetometerEvent;
  BarometerEvent? _barometerEvent;

  DateTime? _userAccelerometerUpdateTime;
  DateTime? _accelerometerUpdateTime;
  DateTime? _gyroscopeUpdateTime;
  DateTime? _magnetometerUpdateTime;
  DateTime? _barometerUpdateTime;

  int? _userAccelerometerLastInterval;
  int? _accelerometerLastInterval;
  int? _gyroscopeLastInterval;
  int? _magnetometerLastInterval;
  int? _barometerLastInterval;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  Duration sensorInterval = SensorInterval.normalInterval;

  // Throttling for graph updates
  DateTime? _lastGraphUpdate;
  static const Duration _graphUpdateInterval = Duration(milliseconds: 100); // Update graphs every 100ms

  // Game variables
  GameMode _gameMode = GameMode.freeFall;
  GameState _gameState = GameState.ready;
  List<GameResult> _gameResults = [];
  
  // Game detection variables
  DateTime? _gameStartTime;
  DateTime? _freeFallStartTime;
  DateTime? _throwStartTime;
  bool _throwDetected = false;
  bool _wasInFreeFall = false;
  double _maxAccelerationDuringGame = 0.0;
  double _minAccelerationDuringGame = double.infinity;
  
  // Free fall detection constants
  static const double _freeFallThreshold = 2.0; // m/s² (much lower than 9.81)
  static const Duration _freeFallMinDuration = Duration(milliseconds: 200);
  
  // Throw detection constants
  static const double _throwThreshold = 20.0; // m/s² (high acceleration indicating throw)

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
          _buildGraphScreen(),
          _buildGameScreen(),
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
              'Real-time Sensor Data\n← Swipe for graphs →',
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
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Barometer'),
                    ),
                    Text(
                        '${_barometerEvent?.pressure.toStringAsFixed(1) ?? '?'} hPa'),
                    Text('${_barometerLastInterval?.toString() ?? '?'} ms'),
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
              'Sensor Data Graphs\n← Real-time Data  |  Game →',
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
            const SizedBox(height: 20),
            _buildChart('Barometer', [
              _createLineChartBarData(_pressureData, Colors.purple, 'Pressure'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Phone Throwing Game',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            '← Graphs  |  Data →',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          
          // Safety Warning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠️ SAFETY FIRST: Use over soft surfaces only! Have good grip!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Game Mode Selection
          SegmentedButton<GameMode>(
            segments: const [
              ButtonSegment<GameMode>(
                value: GameMode.freeFall,
                label: Text('Free Fall'),
                icon: Icon(Icons.arrow_downward),
              ),
              ButtonSegment<GameMode>(
                value: GameMode.throwCatch,
                label: Text('Throw & Catch'),
                icon: Icon(Icons.sports_baseball),
              ),
            ],
            selected: {_gameMode},
            onSelectionChanged: (Set<GameMode> newSelection) {
              setState(() {
                _gameMode = newSelection.first;
                _resetGame();
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Game Status Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getGameStatusColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _getGameStatusText(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_gameState == GameState.ready) ...[
                  const SizedBox(height: 8),
                  Text(
                    _getGameInstructions(),
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Real-time sensor feedback
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text('Live Sensor Data', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Acceleration Magnitude: ${_getAccelerationMagnitude().toStringAsFixed(2)} m/s²'),
                Text('Free Fall Detection: ${_isInFreeFall() ? "🔴 FREE FALL" : "🟢 Normal"}'),
                if (_gameMode == GameMode.throwCatch)
                  Text('Throw Detection: ${_throwDetected ? "🚀 DETECTED" : "⏳ Waiting"}'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Game Results
          if (_gameResults.isNotEmpty) ...[
            const Text(
              'Game Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: _gameResults.length,
                itemBuilder: (context, index) {
                  final result = _gameResults[_gameResults.length - 1 - index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        _gameMode == GameMode.freeFall ? Icons.arrow_downward : Icons.sports_baseball,
                        color: Colors.blue,
                      ),
                      title: Text('Attempt ${_gameResults.length - index}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Duration: ${result.duration.toStringAsFixed(2)}s'),
                          if (result.estimatedHeight != null)
                            Text('Est. Height: ${result.estimatedHeight!.toStringAsFixed(2)}m'),
                          Text('Max Accel: ${result.maxAcceleration.toStringAsFixed(2)} m/s²'),
                        ],
                      ),
                      trailing: Text(
                        '${_calculateScore(result)}pts',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          
          const Spacer(),
          
          // Control Button
          ElevatedButton(
            onPressed: _gameState == GameState.ready ? _startGame : _resetGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: _gameState == GameState.ready ? Colors.green : Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              _gameState == GameState.ready ? 'START GAME' : 'RESET',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(String title, List<LineChartBarData> lineBarsData) {
    // Define appropriate Y-axis ranges for different sensor types
    double minY, maxY;
    switch (title) {
      case 'User Accelerometer':
      case 'Accelerometer':
        minY = -20.0;
        maxY = 20.0;
        break;
      case 'Gyroscope':
        minY = -10.0;
        maxY = 10.0;
        break;
      case 'Magnetometer':
        minY = -100.0;
        maxY = 100.0;
        break;
      case 'Barometer':
        minY = 950.0;
        maxY = 1050.0;
        break;
      default:
        minY = -20.0;
        maxY = 20.0;
    }

    // Fixed time window approach - always show last 30 seconds
    const timeWindow = 30.0; // 30 seconds
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
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: (maxY - minY) / 4,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 10.0,
                        getTitlesWidget: (value, meta) {
                          final relativeTime = value - minX;
                          return Text(
                            '${relativeTime.toStringAsFixed(0)}s',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    horizontalInterval: (maxY - minY) / 4,
                    verticalInterval: 10.0,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  clipData: const FlClipData.all(),
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

  bool _shouldUpdateGraph() {
    final now = DateTime.now();
    if (_lastGraphUpdate == null || now.difference(_lastGraphUpdate!) >= _graphUpdateInterval) {
      _lastGraphUpdate = now;
      return true;
    }
    return false;
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
          
          // Only update UI at throttled intervals
          if (_shouldUpdateGraph()) {
            setState(() {
              _userAccelerometerEvent = event;
              if (_userAccelerometerUpdateTime != null) {
                final interval = now.difference(_userAccelerometerUpdateTime!);
                if (interval > _ignoreDuration) {
                  _userAccelerometerLastInterval = interval.inMilliseconds;
                }
              }
            });
            // Update game logic
            _updateGameLogic();
          }
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
          
          // Only update UI at throttled intervals
          if (_shouldUpdateGraph()) {
            setState(() {
              _accelerometerEvent = event;
              if (_accelerometerUpdateTime != null) {
                final interval = now.difference(_accelerometerUpdateTime!);
                if (interval > _ignoreDuration) {
                  _accelerometerLastInterval = interval.inMilliseconds;
                }
              }
            });
            // Update game logic (main sensor for game)
            _updateGameLogic();
          }
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
          
          // Only update UI at throttled intervals
          if (_shouldUpdateGraph()) {
            setState(() {
              _gyroscopeEvent = event;
              if (_gyroscopeUpdateTime != null) {
                final interval = now.difference(_gyroscopeUpdateTime!);
                if (interval > _ignoreDuration) {
                  _gyroscopeLastInterval = interval.inMilliseconds;
                }
              }
            });
          }
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
          
          // Only update UI at throttled intervals
          if (_shouldUpdateGraph()) {
            setState(() {
              _magnetometerEvent = event;
              if (_magnetometerUpdateTime != null) {
                final interval = now.difference(_magnetometerUpdateTime!);
                if (interval > _ignoreDuration) {
                  _magnetometerLastInterval = interval.inMilliseconds;
                }
              }
            });
          }
          _magnetometerUpdateTime = now;
        },
        onError: (e) {
          _showSensorErrorDialog("Magnetometer");
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      barometerEventStream(samplingPeriod: sensorInterval).listen(
        (BarometerEvent event) {
          final now = event.timestamp;
          // Always add data points
          _addDataPoint(_pressureData, event.pressure);
          
          // Only update UI at throttled intervals
          if (_shouldUpdateGraph()) {
            setState(() {
              _barometerEvent = event;
              if (_barometerUpdateTime != null) {
                final interval = now.difference(_barometerUpdateTime!);
                if (interval > _ignoreDuration) {
                  _barometerLastInterval = interval.inMilliseconds;
                }
              }
            });
          }
          _barometerUpdateTime = now;
        },
        onError: (e) {
          _showSensorErrorDialog("Barometer");
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

  // Game logic methods
  double _getAccelerationMagnitude() {
    if (_accelerometerEvent == null) return 0.0;
    final x = _accelerometerEvent!.x;
    final y = _accelerometerEvent!.y;
    final z = _accelerometerEvent!.z;
    return math.sqrt(x * x + y * y + z * z);
  }

  bool _isInFreeFall() {
    final magnitude = _getAccelerationMagnitude();
    return magnitude < _freeFallThreshold;
  }

  void _startGame() {
    setState(() {
      _gameState = GameState.active;
      _gameStartTime = DateTime.now();
      _freeFallStartTime = null;
      _throwStartTime = null;
      _throwDetected = false;
      _wasInFreeFall = false;
      _maxAccelerationDuringGame = 0.0;
      _minAccelerationDuringGame = double.infinity;
    });
  }

  void _resetGame() {
    setState(() {
      _gameState = GameState.ready;
      _gameStartTime = null;
      _freeFallStartTime = null;
      _throwStartTime = null;
      _throwDetected = false;
      _wasInFreeFall = false;
      _maxAccelerationDuringGame = 0.0;
      _minAccelerationDuringGame = double.infinity;
    });
  }

  void _updateGameLogic() {
    if (_gameState != GameState.active) return;
    
    final magnitude = _getAccelerationMagnitude();
    final now = DateTime.now();
    
    // Track min/max acceleration during game
    _maxAccelerationDuringGame = math.max(_maxAccelerationDuringGame, magnitude);
    _minAccelerationDuringGame = math.min(_minAccelerationDuringGame, magnitude);
    
    // Free fall detection
    final inFreeFall = _isInFreeFall();
    
    if (_gameMode == GameMode.freeFall) {
      // Free fall mode logic
      if (inFreeFall && _freeFallStartTime == null) {
        _freeFallStartTime = now;
        _wasInFreeFall = true;
      } else if (!inFreeFall && _freeFallStartTime != null) {
        // Free fall ended
        final duration = now.difference(_freeFallStartTime!);
        if (duration >= _freeFallMinDuration) {
          _endGame(duration);
        } else {
          _freeFallStartTime = null; // Too short, reset
        }
      }
    } else if (_gameMode == GameMode.throwCatch) {
      // Throw and catch mode logic
      if (!_throwDetected && magnitude > _throwThreshold) {
        _throwDetected = true;
        _throwStartTime = now;
      }
      
      if (_throwDetected) {
        if (inFreeFall && _freeFallStartTime == null) {
          _freeFallStartTime = now;
          _wasInFreeFall = true;
        } else if (!inFreeFall && _freeFallStartTime != null && _wasInFreeFall) {
          // Caught after throw
          final freeFallDuration = now.difference(_freeFallStartTime!);
          final totalDuration = now.difference(_throwStartTime!);
          if (freeFallDuration >= _freeFallMinDuration) {
            _endGame(freeFallDuration, totalDuration: totalDuration);
          }
        }
      }
    }
  }

  void _endGame(Duration freeFallDuration, {Duration? totalDuration}) {
    final gameEndTime = DateTime.now();
    final estimatedHeight = _calculateHeight(freeFallDuration);
    
    final result = GameResult(
      duration: freeFallDuration.inMilliseconds / 1000.0,
      maxAcceleration: _maxAccelerationDuringGame,
      minAcceleration: _minAccelerationDuringGame,
      estimatedHeight: estimatedHeight,
      timestamp: gameEndTime,
    );
    
    setState(() {
      _gameResults.add(result);
      _gameState = GameState.finished;
    });
    
    // Auto-reset after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) _resetGame();
    });
  }

  double? _calculateHeight(Duration freeFallDuration) {
    // Using h = 0.5 * g * t²
    // This is a rough estimation assuming perfect free fall
    final seconds = freeFallDuration.inMilliseconds / 1000.0;
    if (seconds < 0.1) return null; // Too short to be meaningful
    return 0.5 * 9.81 * seconds * seconds;
  }

  int _calculateScore(GameResult result) {
    // Scoring based on duration and estimated height
    int score = (result.duration * 10).round(); // 10 points per second of free fall
    if (result.estimatedHeight != null) {
      score += (result.estimatedHeight! * 100).round(); // 100 points per meter
    }
    return score;
  }

  Color _getGameStatusColor() {
    switch (_gameState) {
      case GameState.ready:
        return Colors.blue;
      case GameState.active:
        return _isInFreeFall() ? Colors.red : Colors.green;
      case GameState.analyzing:
        return Colors.orange;
      case GameState.finished:
        return Colors.purple;
    }
  }

  String _getGameStatusText() {
    switch (_gameState) {
      case GameState.ready:
        return 'Ready to Start!';
      case GameState.active:
        if (_gameMode == GameMode.freeFall) {
          return _isInFreeFall() ? 'FREE FALLING!' : 'Drop the phone!';
        } else {
          if (!_throwDetected) {
            return 'Throw the phone up!';
          } else if (_isInFreeFall()) {
            return 'IN THE AIR!';
          } else {
            return 'Catch it!';
          }
        }
      case GameState.analyzing:
        return 'Analyzing...';
      case GameState.finished:
        final lastResult = _gameResults.last;
        return 'Score: ${_calculateScore(lastResult)} points!';
    }
  }

  String _getGameInstructions() {
    switch (_gameMode) {
      case GameMode.freeFall:
        return 'Hold your phone and let it fall (carefully!). The game will detect free fall automatically.';
      case GameMode.throwCatch:
        return 'Throw your phone straight up and catch it. We\'ll measure how high it goes!';
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
}