// blank_screen.dart
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blank Screen'),
      ),
      body: Center(
        child: Text(
          'This is a explore screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// Global key to access the state of MapWidget
final GlobalKey<_ExploreScreenState> ExploreKey = GlobalKey<_ExploreScreenState>();

class MapWidgetWithGlobalKey extends StatefulWidget {
  @override
  _MapWidgetWithGlobalKeyState createState() => _MapWidgetWithGlobalKeyState();
}

class _MapWidgetWithGlobalKeyState extends State<MapWidgetWithGlobalKey> {
  @override
  Widget build(BuildContext context) {
    return ExploreScreen(key: ExploreKey);
  }
}
