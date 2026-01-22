import 'package:flutter/material.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class BLEEmojiBroadcasterPage extends StatefulWidget {
  const BLEEmojiBroadcasterPage({super.key});

  @override
  State<BLEEmojiBroadcasterPage> createState() => _BLEEmojiBroadcasterPageState();
}

class _BLEEmojiBroadcasterPageState extends State<BLEEmojiBroadcasterPage> {
  late PeripheralManager _pmanager;
  late CentralManager _cmanager;
  final TextEditingController _emojiController = TextEditingController();
  final List<Map<String, dynamic>> _receivedEmojis = [];
  final Set<String> _seenEmojiPeripheralPairs = {};
  late Timer _pollingTimer;

  @override
  void initState() {
    super.initState();
    _initializeBLE();
  }

  Future<void> _initializeBLE() async {
    _pmanager = PeripheralManager();
    _cmanager = CentralManager();

    // Authorize and set up peripheral (for broadcasting)
    await _pmanager.authorize();

    // Authorize and set up central (for scanning)
    await _cmanager.authorize();

    // Listen for discovered devices
    _cmanager.discovered.listen((eventArgs) {
      final peripheral = eventArgs.peripheral;
      final peripheralId = peripheral.uuid.toString();

      if (eventArgs.advertisement.name != null) {
        final name = eventArgs.advertisement.name!;
        if (name.startsWith('sHCI:')) {
          final emoji = name.substring(5); // Remove 'sHCI:' prefix
          final pairKey = '$peripheralId:$emoji';

          // Only add if we haven't seen this (peripheral, emoji) pair before
          if (!_seenEmojiPeripheralPairs.contains(pairKey)) {
            _seenEmojiPeripheralPairs.add(pairKey);

            setState(() {
              // Insert at the top of the list (latest on top)
              _receivedEmojis.insert(0, {
                'emoji': emoji,
                'timestamp': DateTime.now(),
              });
            });
          }
        }
      }
    });

    // Start scanning for devices
    await _cmanager.startDiscovery();

    // Start polling timer to restart discovery every 2 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        await _cmanager.stopDiscovery();
        await Future.delayed(const Duration(milliseconds: 100));
        await _cmanager.startDiscovery();
      } catch (e) {
        print('Error restarting discovery: $e');
      }
    });
  }

  Future<void> _broadcastEmoji(String emoji) async {
    try {
      await _pmanager.stopAdvertising();
      await Future.delayed(const Duration(milliseconds: 100));
      await _pmanager.startAdvertising(
        Advertisement(name: 'sHCI:$emoji'),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error broadcasting: $e')),
        );
      }
    }
  }

  void _handleSendEmoji() {
    final emoji = _emojiController.text.trim();
    if (emoji.isNotEmpty) {
      _broadcastEmoji(emoji);
      _emojiController.clear();
      // Add our own emoji to the list as well
      setState(() {
        _receivedEmojis.insert(0, {
          'emoji': emoji,
          'timestamp': DateTime.now(),
        });
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer.cancel();
    _cmanager.stopDiscovery();
    _pmanager.stopAdvertising();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 04 - BLE Emoji Broadcaster'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Emoji list (scrollable, latest on top)
          Expanded(
            child: _receivedEmojis.isEmpty
                ? Center(
                    child: Text(
                      'No emojis received yet',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    itemCount: _receivedEmojis.length,
                    itemBuilder: (context, index) {
                      final entry = _receivedEmojis[index];
                      final emoji = entry['emoji'] as String;
                      final timestamp = entry['timestamp'] as DateTime;
                      final formattedTime = DateFormat('HH:mm:ss').format(timestamp);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              emoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(width: 16.0),
                            Text(
                              formattedTime,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Emoji selection field at the bottom
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose emoji to broadcast:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emojiController,
                        decoration: InputDecoration(
                          hintText: 'Select emoji...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSendEmoji(),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    FloatingActionButton(
                      onPressed: _handleSendEmoji,
                      child: const Icon(Icons.broadcast_on_personal),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
