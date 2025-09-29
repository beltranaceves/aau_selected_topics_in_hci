import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/geolocation.dart'; //
import 'screens/IMU.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const GeolocalizationApp());
}

class GeolocalizationApp extends StatelessWidget {
  const GeolocalizationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geolocation App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // home: const LocationScreen(),
      home: const NavigationScreen(),
    );
  }
}

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Screen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Exercise 02 - Geolocation.'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationScreen(),
                  ),
                );
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Exrcise 03 - IMU'),
              onTap: () {
                // Update the state of the app.
                //
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IMUPage(title: "IMU Demo page")),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(child: Text('This is the navigation screen.')),
    );
  }
}
