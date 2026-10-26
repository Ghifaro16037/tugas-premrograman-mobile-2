import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print('[DB Helper] Membuka database di path: $path');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    print('[DB Helper] Membuat tabel notes versi $version');
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        color INTEGER NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('[DB Helper] OnUpgrade dari v$oldVersion ke v$newVersion');
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE notes ADD COLUMN created_at TEXT NOT NULL DEFAULT ''");
      await db.execute("ALTER TABLE notes ADD COLUMN color INTEGER NOT NULL DEFAULT 4294967295");
    }
  }

  // CREATE (INSERT)
  Future<int> insert(Note note) async {
    final db = await instance.database;
    final id = await db.insert('notes', note.toMap());
    print('[DB Helper] SUCCESS INSERT -> Row ID: $id');
    return id;
  }

  // READ (ALL & SEARCH WITH LIKE)
  Future<List<Note>> getAllNotes({String keyword = ''}) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result;

    if (keyword.isEmpty) {
      result = await db.query('notes', orderBy: 'id DESC');
    } else {
      result = await db.query(
        'notes',
        where: 'title LIKE ? OR content LIKE ?',
        whereArgs: ['%$keyword%', '%$keyword%'],
        orderBy: 'id DESC',
      );
    }

    print('[DB Helper] SUCCESS READ -> Ditemukan ${result.length} catatan');
    return result.map((e) => Note.fromMap(e)).toList();
  }

  // UPDATE
  Future<int> update(Note note) async {
    final db = await instance.database;
    final count = await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
    print('[DB Helper] SUCCESS UPDATE -> Baris diperbarui: $count');
    return count;
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await instance.database;
    final count = await db.delete('notes', where: 'id = ?', whereArgs: [id]);
    print('[DB Helper] SUCCESS DELETE -> ID $id dihapus (Baris terhapus: $count)');
    return count;
  }
}