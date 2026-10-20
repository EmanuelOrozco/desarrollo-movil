import '../local/product_note_local_data_source.dart';
import '../models/product_note.dart';
import '../remote/product_note_remote_data_source.dart';

class ProductNoteRepository {
  final ProductNoteLocalDataSource local;
  final ProductNoteRemoteDataSource? remote;

  ProductNoteRepository({
    required this.local,
    this.remote,
  });

  Future<ProductNote?> getNoteForProduct(int productId) =>
      local.getNoteForProduct(productId);

  Future<void> saveNote(ProductNote note) async {
    await local.saveNote(note);

    final remoteSource = remote;
    if (remoteSource == null) return;

    try {
      await remoteSource.upsertNote(note);
      await local.markSynced(note.productId);
    } catch (_) {
      // La nota ya quedó local y seguirá pendiente.
    }
  }

  Future<void> syncPending() async {
    final remoteSource = remote;
    if (remoteSource == null) return;

    final pending = await local.getPendingNotes();

    for (final note in pending) {
      try {
        await remoteSource.upsertNote(note);
        await local.markSynced(note.productId);
      } catch (_) {
        // Esa nota queda pendiente para otro intento.
      }
    }
  }
}
