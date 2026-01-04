import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/db_helper.dart';
import '../services/location_service.dart';
import '../models/inspection.dart';
import 'package:geolocator/geolocator.dart';

class AddInspectionScreen extends StatefulWidget {
  final Inspection? existingInspection; // Optional for update
  const AddInspectionScreen({super.key, this.existingInspection});

  @override
  State<AddInspectionScreen> createState() => _AddInspectionScreenState();
}

class _AddInspectionScreenState extends State<AddInspectionScreen> {
  late TextEditingController _name;
  late TextEditingController _desc;
  String rating = "Good";
  List<File> images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existingInspection != null) {
      final insp = widget.existingInspection!;
      _name = TextEditingController(text: insp.propertyName);
      _desc = TextEditingController(text: insp.description);
      rating = insp.rating;
      images = insp.photos.map((p) => File(p)).toList();
    } else {
      _name = TextEditingController();
      _desc = TextEditingController();
    }
  }

  // --------------------
  // Pick Image from Camera
  // --------------------
  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        setState(() => images.add(File(picked.path)));
      }
    } catch (e) {
      _showErrorDialog("Error capturing image: $e");
    }
  }

  // --------------------
  // Save / Update Inspection
  // --------------------
  Future<void> _save() async {
  if (_name.text.isEmpty || _desc.text.isEmpty) {
    _showErrorDialog("Please fill all text fields");
    return;
  }

  if (images.length < 3) {
    _showErrorDialog("Please capture at least 3 photos");
    return;
  }

  try {
    // 1️⃣ Get location safely
    Position pos;
    try {
      pos = await _getCurrentLocationSafe();
    } catch (e) {
      _showErrorDialog(
          "Cannot get GPS location. Make sure location is enabled and permissions granted.\n$e");
      return;
    }

    // 2️⃣ Open database safely
    final db = await DBHelper.database;

    // 3️⃣ Insert or Update
    if (widget.existingInspection != null) {
      // UPDATE
      await db.update(
        'tbl_inspections',
        {
          'property_name': _name.text,
          'description': _desc.text,
          'rating': rating,
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'date_created': DateTime.now().toIso8601String(),
          'photos': images.map((e) => e.path).join(','),
        },
        where: 'id=?',
        whereArgs: [widget.existingInspection!.id],
      );
    } else {
      // INSERT
      await db.insert('tbl_inspections', {
        'property_name': _name.text,
        'description': _desc.text,
        'rating': rating,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'date_created': DateTime.now().toIso8601String(),
        'photos': images.map((e) => e.path).join(','),
      });
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  } catch (e, stack) {
    // Catch any other unexpected errors
    print("Error saving inspection: $e\n$stack");
    _showErrorDialog("Unexpected error occurred:\n$e");
  }
}

  // --------------------
  // Safe Location Fetch
  // --------------------
  Future<Position> _getCurrentLocationSafe() async {
    return await LocationService.getCurrentLocation();
  }

  // --------------------
  // Show Error Dialog
  // --------------------
  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // --------------------
  // Build UI
  // --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.existingInspection != null ? "Update Inspection" : "Add Inspection")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: "Property Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _desc,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: rating,
              items: ["Excellent", "Good", "Fair", "Poor"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => rating = v!),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: images
                  .map((e) => Image.file(e, width: 80, height: 80))
                  .toList(),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _pickImage,
              child: const Text("Capture Image"),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              child: Text(
                  widget.existingInspection != null ? "Update Inspection" : "Save Inspection"),
            ),
          ],
        ),
      ),
    );
  }
}
