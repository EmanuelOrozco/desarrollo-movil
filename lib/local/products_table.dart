import 'package:drift/drift.dart';

@DataClassName('ProductRecord')
class ProductsTable extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  IntColumn get inventory => integer()();
  TextColumn get category => text()();
  BoolColumn get isAvailable => boolean()();
  TextColumn get imagePath => text()();
  TextColumn get description => text()();

  @override
  Set<Column> get primaryKey => {id};
}
