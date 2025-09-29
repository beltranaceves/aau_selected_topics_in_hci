import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:fl_chart/fl_chart.dart';

class SensorGraphsPage extends StatefulWidget {
  const SensorGraphsPage({super.key});

  @override
  State<SensorGraphsPage> createState() => _SensorGraphsPageState();
}

class _SensorGraphsPageState extends State<SensorGraphsPage> {
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  
  // Data storage for graphs (keeping last 100 points)
  final Queue<FlSpot> _userAccelXData = Queue<FlSpot>();
  final Queue<FlSpot> _userAccelYData = Queue<FlSpot>();
  final Queue<FlSpot> _userAccelZData = Queue<FlSpot>();
  
  final Queue<FlSpot> _accelXData = Queue<FlSpot>();
  final Queue<FlSpot> _accelYData = Queue<FlSpot>();
  final Queue<FlSpot> _accelZData = Queue<FlSpot>();
  
  final Queue<FlSpot> _gyroXData = Queue<FlSpot>();
  final Queue<FlSpot> _gyroYData = Queue<FlSpot>();
  final Queue<FlSpot> _gyroZData = Queue<FlSpot>();
  
  final Queue<FlSpot> _magnetoXData = Queue<FlSpot>();
  final Queue<FlSpot> _magnetoYData = Queue<FlSpot>();
  final Queue<FlSpot> _magnetoZData = Queue<FlSpot>();
  
  final Queue<FlSpot> _barometerData = Queue<FlSpot>();
  
  double _timeCounter = 0;
  final int _maxDataPoints = 100;
  
  Duration sensorInterval = SensorInterval.normalInterval;

  @override
  void initState() {
    super.initState();
    _initializeSensorStreams();
  }

  void _initializeSensorStreams() {
    // Clear existing subscriptions
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();

    // User Accelerometer
    _streamSubscriptions.add(
      userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _addDataPoint(_userAccelXData, event.x);
            _addDataPoint(_userAccelYData, event.y);
            _addDataPoint(_userAccelZData, event.z);
            _timeCounter += 0.1; // Increment time
          });
        },
        onError: (e) => print('User Accelerometer error: $e'),
        cancelOnError: true,
      ),
    );

    // Accelerometer
    _streamSubscriptions.add(
      accelerometerEventStream(samplingPeriod: sensorInterval).listen(
        (AccelerometerEvent event) {
          setState(() {
            _addDataPoint(_accelXData, event.x);
            _addDataPoint(_accelYData, event.y);
            _addDataPoint(_accelZData, event.z);
          });
        },
        onError: (e) => print('Accelerometer error: $e'),
        cancelOnError: true,
      ),
    );

    // Gyroscope
    _streamSubscriptions.add(
      gyroscopeEventStream(samplingPeriod: sensorInterval).listen(
        (GyroscopeEvent event) {
          setState(() {
            _addDataPoint(_gyroXData, event.x);
            _addDataPoint(_gyroYData, event.y);
            _addDataPoint(_gyroZData, event.z);
          });
        },
        onError: (e) => print('Gyroscope error: $e'),
        cancelOnError: true,
      ),
    );

    // Magnetometer
    _streamSubscriptions.add(
      magnetometerEventStream(samplingPeriod: sensorInterval).listen(
        (MagnetometerEvent event) {
          setState(() {
            _addDataPoint(_magnetoXData, event.x);
            _addDataPoint(_magnetoYData, event.y);
            _addDataPoint(_magnetoZData, event.z);
          });
        },
        onError: (e) => print('Magnetometer error: $e'),
        cancelOnError: true,
      ),
    );

    // Barometer
    _streamSubscriptions.add(
      barometerEventStream(samplingPeriod: sensorInterval).listen(
        (BarometerEvent event) {
          setState(() {
            _addDataPoint(_barometerData, event.pressure);
          });
        },
        onError: (e) => print('Barometer error: $e'),
        cancelOnError: true,
      ),
    );
  }

  void _addDataPoint(Queue<FlSpot> dataQueue, double value) {
    dataQueue.add(FlSpot(_timeCounter, value));
    if (dataQueue.length > _maxDataPoints) {
      dataQueue.removeFirst();
    }
  }

  Widget _buildChart(String title, Queue<FlSpot> xData, Queue<FlSpot> yData, Queue<FlSpot> zData) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: xData.toList(),
                    isCurved: false,
                    color: Colors.red,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: yData.toList(),
                    isCurved: false,
                    color: Colors.green,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: zData.toList(),
                    isCurved: false,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('X', Colors.red),
              const SizedBox(width: 16),
              _buildLegendItem('Y', Colors.green),
              const SizedBox(width: 16),
              _buildLegendItem('Z', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleChart(String title, Queue<FlSpot> data, Color color) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.toList(),
                    isCurved: false,
                    color: color,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Data Graphs'),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _userAccelXData.clear();
                _userAccelYData.clear();
                _userAccelZData.clear();
                _accelXData.clear();
                _accelYData.clear();
                _accelZData.clear();
                _gyroXData.clear();
                _gyroYData.clear();
                _gyroZData.clear();
                _magnetoXData.clear();
                _magnetoYData.clear();
                _magnetoZData.clear();
                _barometerData.clear();
                _timeCounter = 0;
              });
            },
            tooltip: 'Clear Data',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildChart('User Accelerometer', _userAccelXData, _userAccelYData, _userAccelZData),
            const Divider(),
            _buildChart('Accelerometer', _accelXData, _accelYData, _accelZData),
            const Divider(),
            _buildChart('Gyroscope', _gyroXData, _gyroYData, _gyroZData),
            const Divider(),
            _buildChart('Magnetometer', _magnetoXData, _magnetoYData, _magnetoZData),
            const Divider(),
            _buildSingleChart('Barometer (hPa)', _barometerData, Colors.purple),
            const SizedBox(height: 20),
            // Sensor interval controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Update Interval:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SegmentedButton(
                    segments: [
                      ButtonSegment(
                        value: SensorInterval.gameInterval,
                        label: Text('Game\n(${SensorInterval.gameInterval.inMilliseconds}ms)'),
                      ),
                      ButtonSegment(
                        value: SensorInterval.uiInterval,
                        label: Text('UI\n(${SensorInterval.uiInterval.inMilliseconds}ms)'),
                      ),
                      ButtonSegment(
                        value: SensorInterval.normalInterval,
                        label: Text('Normal\n(${SensorInterval.normalInterval.inMilliseconds}ms)'),
                      ),
                    ],
                    selected: {sensorInterval},
                    showSelectedIcon: false,
                    onSelectionChanged: (value) {
                      setState(() {
                        sensorInterval = value.first;
                        _initializeSensorStreams();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}