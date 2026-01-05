import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/db_helper.dart';
import '../services/location_service.dart';
import '../models/inspection.dart';

class AddInspectionScreen extends StatefulWidget {
  final Inspection? existingInspection; // <-- optional parameter for update

  const AddInspectionScreen({super.key, this.existingInspection});

  @override
  State<AddInspectionScreen> createState() => _AddInspectionScreenState();
}

class _AddInspectionScreenState extends State<AddInspectionScreen> {
  final TextEditingController _propertyController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String rating = "Good";
  List<File> images = [];
  String dateTime =
      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} "
      "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();

    // Prefill form if updating existing inspection
    if (widget.existingInspection != null) {
      _propertyController.text = widget.existingInspection!.propertyName;
      _descController.text = widget.existingInspection!.description;
      rating = widget.existingInspection!.rating;
      images = widget.existingInspection!.photos.map((e) => File(e)).toList();

      // Show existing date/time
      final dt = DateTime.parse(widget.existingInspection!.dateCreated);
      dateTime =
          "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        images.add(File(picked.path));
      });
    }
  }

  Future<void> _saveInspection() async {
    if (_propertyController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (images.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please take at least 3 photos")),
      );
      return;
    }

    final db = await DBHelper.database;

    if (widget.existingInspection == null) {
      // ADD new inspection
      final position = await LocationService.getCurrentLocation();
      await db.insert('tbl_inspections', {
        'property_name': _propertyController.text,
        'description': _descController.text,
        'rating': rating,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'date_created': DateTime.now().toIso8601String(),
        'photos': images.map((e) => e.path).join(','),
      });
    } else {
      // UPDATE existing inspection
      await db.update(
        'tbl_inspections',
        {
          'property_name': _propertyController.text,
          'description': _descController.text,
          'rating': rating,
          'photos': images.map((e) => e.path).join(','),
        },
        where: 'id=?',
        whereArgs: [widget.existingInspection!.id],
      );
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.existingInspection == null ? "Add Inspection" : "Update Inspection")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Property Info ----------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Property Information",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _propertyController,
                      decoration: const InputDecoration(
                        labelText: "Property Name / Address",
                        prefixIcon: Icon(Icons.home),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Inspection Description",
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ---------------- Rating ----------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.star),
                    const SizedBox(width: 10),
                    const Text("Rating: "),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: rating,
                      items: ["Excellent", "Good", "Fair", "Poor"]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          rating = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ---------------- Date & Time ----------------
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text("Inspection Date & Time"),
                subtitle: Text(dateTime),
              ),
            ),

            const SizedBox(height: 15),

            // ---------------- Photos ----------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Inspection Photos (min 3)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: images
                          .map((img) => Image.file(
                                img,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Capture Photo"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- Save Button ----------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveInspection,
                icon: const Icon(Icons.save),
                label: Text(
                    widget.existingInspection == null ? "Save Inspection" : "Update Inspection"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
