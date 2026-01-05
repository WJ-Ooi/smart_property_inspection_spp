import 'dart:io';
import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import '../models/inspection.dart';
import 'add_inspection_screen.dart';
import 'inspection_detail_screen.dart';
import '../services/session_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Inspection> inspections = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final db = await DBHelper.database;
    final data = await db.query('tbl_inspections', orderBy: 'id DESC');
    setState(() {
      inspections = data.map((e) => Inspection.fromMap(e)).toList();
    });
  }

  // ---------------- Format Date/Time ----------------
  String formatDateTime(String isoString) {
    final dt = DateTime.parse(isoString);
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? "PM" : "AM";
    final minute = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month;
    final year = dt.year;

    const monthNames = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];

    return "$day ${monthNames[month]}, $year, $hour:$minute $ampm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inspections"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SessionService.logout();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: inspections.isEmpty
          ? const Center(
              child: Text(
              "No inspections found",
              style: TextStyle(fontSize: 16),
            ))
          : ListView.builder(
              itemCount: inspections.length,
              itemBuilder: (ctx, i) {
                final insp = inspections[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: insp.photos.isNotEmpty
                        ? Image.file(
                            File(insp.photos.first),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          ),
                    title: Text(insp.propertyName),
                    subtitle: Text(formatDateTime(insp.dateCreated)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              InspectionDetailScreen(inspection: insp),
                        ),
                      );
                      loadData();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddInspectionScreen()));
          loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
