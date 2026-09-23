import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/product_note.dart';

class ProductNoteStorage {
  static const _fileName = 'product_notes.json';

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<List<ProductNote>> _readAll() async {
    final file = await _getFile();
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    if (content.isEmpty) return [];

    final List<dynamic> data = jsonDecode(content);
    return data
        .map((item) => ProductNote.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeAll(List<ProductNote> notes) async {
    final file = await _getFile();
    final jsonString =
        jsonEncode(notes.map((note) => note.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  Future<ProductNote?> getNote(int productId) async {
    final notes = await _readAll();
    try {
      return notes.firstWhere((note) => note.productId == productId);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNote(ProductNote note) async {
    final notes = await _readAll();
    final index = notes.indexWhere((n) => n.productId == note.productId);

    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.add(note);
    }

    await _writeAll(notes);
  }

  Future<void> deleteNote(int productId) async {
    final notes = await _readAll();
    notes.removeWhere((note) => note.productId == productId);
    await _writeAll(notes);
  }
}
