import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_application_3/models/check_in_out_history_model.dart';
import 'package:flutter_application_3/models/user_model.dart';
import 'package:flutter_application_3/services/checkInTime_services.dart';
import 'package:flutter_application_3/services/user_data_services.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng mainPosition = LatLng(13.714280586680793, 100.53849493871955);
  List<UserModel> users = [];
  List<CheckInOutHistoryModel> workHistory = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // ดึงข้อมูลผู้ใช้
    users = await UserDataServices().getUserData();

    for (var user in users) {
      List<CheckInOutHistoryModel> userWorkHistory = await CheckInTimeServices()
          .getWorkHistory(user.uid);
      workHistory.addAll(userWorkHistory); // รวมข้อมูลทั้งหมด
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map View")),
      body: FlutterMap(
        options: MapOptions(initialCenter: mainPosition, initialZoom: 13.0),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            maxNativeZoom: 19,
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: mainPosition,
                child: Container(
                  child: Icon(Icons.home, color: Colors.blue, size: 40),
                ),
              ),
              ...workHistory.map((history) {
                return Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(history.latitude, history.longitude),
                  child: Container(
                    child: Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('แผนที่'),
    //     backgroundColor: Colors.blueAccent,
    //   ),
    //   body: FlutterMap(
    //     mapController: _mapController,
    //     options: MapOptions(
    //       initialCenter: _currentPosition ??
    //           LatLng(51.509364, -0.128928), // ศูนย์กลางแผนที่ที่ London
    //       maxZoom: 20,
    //     ),
    //     children: [
    //       TileLayer(
    //         urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    //         userAgentPackageName: 'com.example.app',
    //         maxNativeZoom: 19,
    //       ),
    //       RichAttributionWidget(
    //         attributions: [
    //           TextSourceAttribution(
    //             'OpenStreetMap contributors',
    //             onTap: () =>
    //                 launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
    //           ),
    //         ],
    //       ),
    //       if (_currentPosition != null)
    //         MarkerLayer(
    //           markers: [
    //             Marker(
    //               point: _currentPosition!,
    //               child: const Icon(
    //                 Icons.location_on,
    //                 color: Colors.red,
    //                 size: 40.0,
    //               ),
    //             )
    //           ],
    //         ),
    //     ],
    //   ),
    // );
  }
}
