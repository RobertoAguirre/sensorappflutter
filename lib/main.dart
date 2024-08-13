import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(SensorApp());
}

class SensorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SensorHomePage(),
    );
  }
}

class SensorHomePage extends StatefulWidget {
  @override
  _SensorHomePageState createState() => _SensorHomePageState();
}

class _SensorHomePageState extends State<SensorHomePage> {
  static const platform = MethodChannel('com.example.sensor_app_flutter/sensors');
  List<String> devices = [];
  String temperature = "N/A";

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_updateSensorData); // Configurar el handler para recibir datos desde la parte nativa
    _startScan(); // Inicia el escaneo cuando se carga la interfaz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devices[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Temperature: $temperature',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startScan,
        child: Icon(Icons.bluetooth_searching),
      ),
    );
  }

  Future<void> _startScan() async {
    try {
      // Llama al método 'startScan' en Java
      await platform.invokeMethod('startScan');
    } on PlatformException catch (e) {
      print("Failed to start scan: '${e.message}'.");
    }
  }

  // Método para recibir actualizaciones de datos desde Java
  Future<void> _updateSensorData(MethodCall call) async {
    if (call.method == 'updateSensorData') {
      final result = Map<String, dynamic>.from(call.arguments);
      setState(() {
        devices = List<String>.from(result['devices']);
        temperature = result['temperature'] ?? "N/A";
      });
    }
  }

  @override
  void dispose() {
    platform.setMethodCallHandler(null);
    super.dispose();
  }
}
