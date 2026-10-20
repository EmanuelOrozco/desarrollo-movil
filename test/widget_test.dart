import 'package:flutter_test/flutter_test.dart';
import 'package:practica_clase/models/product_note.dart';

void main() {
  test('ProductNote conserva los campos al serializar', () {
    final updatedAt = DateTime.utc(2026, 10, 20, 12);
    final note = ProductNote(
      productId: 3,
      note: 'Buena consola',
      rating: 4,
      updatedAt: updatedAt,
    );

    final restored = ProductNote.fromJson(note.toJson());

    expect(restored.productId, 3);
    expect(restored.note, 'Buena consola');
    expect(restored.rating, 4);
    expect(restored.updatedAt, updatedAt);
  });
}
