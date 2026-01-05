import 'dart:io';
import 'package:flutter/material.dart';
import '../models/inspection.dart';
import '../services/db_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_inspection_screen.dart'; // We'll reuse add screen for update

class InspectionDetailScreen extends StatefulWidget {
  final Inspection inspection;
  const InspectionDetailScreen({super.key, required this.inspection});

  @override
  State<InspectionDetailScreen> createState() => _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends State<InspectionDetailScreen> {
  late Inspection inspection;

  @override
  void initState() {
    super.initState();
    inspection = widget.inspection;
  }

  // --------------------
  // Update Inspection
  // --------------------
  Future<void> _updateInspection() async {
    // Open AddInspectionScreen with prefilled data
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddInspectionScreen(
          existingInspection: inspection,
        ),
      ),
    );

    if (result == true) {
      // Reload updated inspection from DB
      final db = await DBHelper.database;
      final data = await db.query('tbl_inspections',
          where: 'id=?', whereArgs: [inspection.id]);
      if (data.isNotEmpty) {
        setState(() {
          inspection = Inspection.fromMap(data.first);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(inspection.propertyName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inspection.description),
            const SizedBox(height: 5),
            Text("Rating: ${inspection.rating}"),
            const SizedBox(height: 5),
            Text("Lat: ${inspection.latitude}, Lng: ${inspection.longitude}"),
            const SizedBox(height: 5),
            Text(inspection.dateCreated),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: inspection.photos
                  .map((p) => Image.file(File(p), width: 100, height: 100))
                  .toList(),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final url = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=${inspection.latitude},${inspection.longitude}');
                if (!await launchUrl(url)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cannot open Maps")));
                }
              },
              child: const Text("Show Location"),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _updateInspection,
              child: const Text("Update Record"),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm delete'),
                    content: const Text('Are you sure you want to delete this inspection? This action cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                    ],
                  ),
                );

                if (confirm != true) return;

                final db = await DBHelper.database;
                await db.delete('tbl_inspections', where: 'id=?', whereArgs: [inspection.id]);
                if (!context.mounted) return;
                Navigator.pop(context, true);
              },
              child: const Text("Delete"),
            ),
          ],
        ),
      ),
    );
  }
}
