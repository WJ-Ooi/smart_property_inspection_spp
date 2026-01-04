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

  Future<void> loadData() async {
    final db = await DBHelper.database;
    final data = await db.query('tbl_inspections', orderBy: 'id DESC');
    setState(() {
      inspections = data.map((e) => Inspection.fromMap(e)).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: inspections.isEmpty
          ? const Center(child: Text("No inspections found"))
          : ListView.builder(
              itemCount: inspections.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(inspections[i].propertyName),
                subtitle: Text(inspections[i].dateCreated),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InspectionDetailScreen(inspection: inspections[i]),
                    ),
                  );
                  loadData();
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddInspectionScreen()));
          loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
