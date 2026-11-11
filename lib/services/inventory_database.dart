
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/inventory_item.dart';

class InventoryDatabase {
  InventoryDatabase._();

  static final InventoryDatabase instance = InventoryDatabase._();

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;

    final path = p.join(
      await getDatabasesPath(),
      'majova_agriworks_inventory.db',
    );

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE inventory_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT NOT NULL,
            category TEXT NOT NULL,
            unit TEXT NOT NULL,
            quantity REAL NOT NULL,
            minimum_stock_level REAL NOT NULL,
            unit_cost REAL NOT NULL,
            supplier TEXT NOT NULL,
            storage_location TEXT NOT NULL,
            purchase_date TEXT,
            expiry_date TEXT,
            notes TEXT NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  Map<String, Object?> _toMap(InventoryItem item) => {
    'item_name': item.itemName,
    'category': item.category,
    'unit': item.unit,
    'quantity': item.quantity,
    'minimum_stock_level': item.minimumStockLevel,
    'unit_cost': item.unitCost,
    'supplier': item.supplier,
    'storage_location': item.storageLocation,
    'purchase_date': item.purchaseDate?.toIso8601String(),
    'expiry_date': item.expiryDate?.toIso8601String(),
    'notes': item.notes,
  };

  InventoryItem _fromMap(Map<String, Object?> row) => InventoryItem(
    itemName: row['item_name'] as String,
    category: row['category'] as String,
    unit: row['unit'] as String,
    quantity: (row['quantity'] as num).toDouble(),
    minimumStockLevel: (row['minimum_stock_level'] as num).toDouble(),
    unitCost: (row['unit_cost'] as num).toDouble(),
    supplier: row['supplier'] as String,
    storageLocation: row['storage_location'] as String,
    purchaseDate: row['purchase_date'] == null
        ? null
        : DateTime.parse(row['purchase_date'] as String),
    expiryDate: row['expiry_date'] == null
        ? null
        : DateTime.parse(row['expiry_date'] as String),
    notes: row['notes'] as String,
  );

  Future<List<InventoryItem>> loadOrSeed(
      List<InventoryItem> seedItems,
      ) async {
    final db = await _database;
    var rows = await db.query('inventory_items', orderBy: 'id ASC');

    if (rows.isEmpty && seedItems.isNotEmpty) {
      await saveAll(seedItems);
      rows = await db.query('inventory_items', orderBy: 'id ASC');
    }

    return rows.map(_fromMap).toList();
  }

  Future<void> saveAll(List<InventoryItem> items) async {
    final db = await _database;

    await db.transaction((transaction) async {
      await transaction.delete('inventory_items');

      for (final item in items) {
        await transaction.insert('inventory_items', _toMap(item));
      }
    });
  }
}
