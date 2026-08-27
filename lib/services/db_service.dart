import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/producto.dart';

/// Servicio que gestiona la base de datos local (SQLite).
/// Todo se guarda en el dispositivo del usuario, sin necesidad de
/// conexión a internet para el uso básico de la app.
class DBService {
  static final DBService instance = DBService._init();
  static Database? _database;

  DBService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tiqora.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        categoria TEXT NOT NULL,
        tienda TEXT NOT NULL,
        fechaCompra TEXT NOT NULL,
        mesesGarantia INTEGER NOT NULL,
        importe REAL,
        rutaFotoTicket TEXT,
        notas TEXT,
        numeroSerie TEXT
      )
    ''');
  }

  Future<Producto> crearProducto(Producto producto) async {
    final db = await instance.database;
    final id = await db.insert('productos', producto.toMap());
    return producto.copyWith(id: id);
  }

  Future<List<Producto>> obtenerProductos() async {
    final db = await instance.database;
    final result = await db.query('productos', orderBy: 'fechaCompra DESC');
    return result.map((map) => Producto.fromMap(map)).toList();
  }

  Future<int> actualizarProducto(Producto producto) async {
    final db = await instance.database;
    return db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  Future<int> eliminarProducto(int id) async {
    final db = await instance.database;
    return db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> contarProductos() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM productos');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
