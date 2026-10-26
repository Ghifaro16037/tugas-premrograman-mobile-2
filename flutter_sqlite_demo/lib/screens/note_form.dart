import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/note.dart';

class NoteForm extends StatefulWidget {
  final Note? note;
  const NoteForm({super.key, this.note});

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final List<Color> _availableColors = [
    Colors.white,
    const Color(0xFFFFCDD2), // Merah Muda
    const Color(0xFFC8E6C9), // Hijau
    const Color(0xFFBBDEFB), // Biru
    const Color(0xFFFFF9C4), // Kuning
  ];
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = _availableColors[0];
    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
      _selectedColor = Color(widget.note!.color);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      try {
        final db = DatabaseHelper.instance;
        final String now = DateTime.now().toIso8601String();

        final newNote = Note(
          id: widget.note?.id,
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          createdAt: widget.note?.createdAt ?? now,
          color: _selectedColor.value,
        );

        print('[Form] Menyiapkan data untuk disimpan: ${newNote.toMap()}');

        if (widget.note == null) {
          await db.insert(newNote);
        } else {
          await db.update(newNote);
        }

        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        print('[Form ERROR] Gagal menyimpan ke SQLite: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Tambah Catatan' : 'Edit Catatan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Isi catatan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              const Text('Warna Catatan:'),
              const SizedBox(height: 8),
              Row(
                children: _availableColors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color ? Colors.black : Colors.grey.shade400,
                          width: _selectedColor == color ? 2.5 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveNote,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}