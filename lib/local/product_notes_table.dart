import 'package:drift/drift.dart';

import 'products_table.dart';

@DataClassName('ProductNoteRecord')
class ProductNotesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(ProductsTable, #id)();
  TextColumn get note => text()();
  IntColumn get rating => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();
}
