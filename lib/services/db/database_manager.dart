import 'package:auditext/services/db/initial_data/defecto_data.dart';
import 'package:auditext/services/db/initial_data/estilo_data.dart';
import 'package:auditext/services/db/initial_data/inspeccion/inspeccion_data.dart';
import 'package:auditext/services/db/initial_data/inspeccion/margen_error_data.dart';
import 'package:auditext/services/db/initial_data/inspeccion/nivel_inspeccion_data.dart';
import 'package:auditext/services/db/initial_data/inspeccion/nqa_data.dart';
import 'package:auditext/services/db/initial_data/inspeccion/tipo_inspeccion_data.dart';
import 'package:auditext/services/db/initial_data/tolerancia_data.dart';
import 'package:auditext/services/db/initial_data/user_settings_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'initial_data/color_data.dart';
import 'initial_data/descripcion_data.dart';
import 'initial_data/talla_data.dart';

// Este archivo se encarga de configurar la base de datos,
// crear tablas y exponer una única instancia de SQLite.

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();

  factory DatabaseManager() => _instance;

  DatabaseManager._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Delete the database if it exists
    /*
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');
    await deleteDatabase(path);
    */
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 9,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: _createTables,
      onUpgrade: _onUpgrade,

    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Color (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE Talla (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rango TEXT NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE Estilo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      );
    ''');
    await db.execute('''
        CREATE TABLE Descripcion (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          descripcion TEXT NOT NULL
        )
      ''');
    await db.execute('''
        CREATE TABLE Defecto (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          codigo TEXT NOT NULL,
          nombre TEXT NOT NULL,
          elementos TEXT NOT NULL
        )
      ''');

    await db.execute('''
      CREATE TABLE Tolerancia (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_estilo INTEGER NOT NULL,
        datos TEXT NOT NULL,
        FOREIGN KEY (id_estilo) REFERENCES Estilo (id) ON DELETE CASCADE
      );
    ''');
    await db.execute('''
      CREATE TABLE TipoInspeccion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT UNIQUE
      );
    ''');
    await db.execute('''
      CREATE TABLE NivelInspeccion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT UNIQUE
      );
    ''');
    await db.execute('''
      CREATE TABLE Nqa (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT UNIQUE
      );
    ''');

    await db.execute('''
      CREATE TABLE Inspeccion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nqaId INTEGER,
        tipoInspeccionId INTEGER,
        nivelInspeccionId INTEGER,
        tamanoLote TEXT,
        tamanoMuestra INTEGER,
        aprobar INTEGER,
        rechazar INTEGER,
        FOREIGN KEY (nqaId) REFERENCES Nqa (id),
        FOREIGN KEY (tipoInspeccionId) REFERENCES TipoInspeccion (id),
        FOREIGN KEY (nivelInspeccionId) REFERENCES NivelInspeccion (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE MargenError (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        margen INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE UserSettings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        seccion TEXT NOT NULL,
        tipoInspeccionId INTEGER,
        nivelInspeccionId INTEGER,
        nqaId INTEGER,
        margenErrorId INTEGER,
        FOREIGN KEY (tipoInspeccionId) REFERENCES TipoInspeccion (id),
        FOREIGN KEY (nivelInspeccionId) REFERENCES NivelInspeccion (id),
        FOREIGN KEY (nqaId) REFERENCES Nqa (id),
        FOREIGN KEY (margenErrorId) REFERENCES MargenError (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE Auditoria (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        proveedor TEXT NOT NULL,
        paisOrigen TEXT NOT NULL,
        paisDestino TEXT NOT NULL,
        marca TEXT NOT NULL,
        fechaEntrega TEXT NOT NULL,
        fechaAuditoria TEXT NOT NULL,
        auditora TEXT NOT NULL,
        po TEXT NOT NULL,
        subgrupo TEXT NOT NULL,
        resultado TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE ImagenVisual (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        elementoId INTEGER NOT NULL,
        imagen TEXT NOT NULL,
        FOREIGN KEY (elementoId) REFERENCES Elemento (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE ImagenEmpaque (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        elementoId INTEGER NOT NULL,
        imagen TEXT NOT NULL,
        FOREIGN KEY (elementoId) REFERENCES Elemento (id) ON DELETE CASCADE
      );
    ''');
    await db.execute('''
      CREATE TABLE ImagenMedida (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        elementoId INTEGER NOT NULL,
        imagen TEXT NOT NULL,
        FOREIGN KEY (elementoId) REFERENCES Elemento (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE DefectoVisual (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        elementoId INTEGER NOT NULL,
        codigo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        color TEXT NOT NULL,
        talla TEXT NOT NULL,
        origenZona TEXT NOT NULL,
        mayor INTEGER NOT NULL,
        menor INTEGER NOT NULL,
        FOREIGN KEY (elementoId) REFERENCES Elemento (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE AnalisisDimensional (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        elementoId INTEGER NOT NULL,
        talla TEXT NOT NULL,
        toleranciaDescripcion TEXT NOT NULL,
        color TEXT NOT NULL,
        valor REAL,
        FOREIGN KEY (elementoId) REFERENCES Elemento (id) ON DELETE CASCADE
    );
    ''');

    await db.execute('''
      CREATE TABLE Elemento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        auditoriaId INTEGER NOT NULL,
        codigo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        totalGeneral INTEGER NOT NULL,
        totalAuditar INTEGER NOT NULL,
        colores TEXT NOT NULL, 
        tallas TEXT NOT NULL,
        FOREIGN KEY (auditoriaId) REFERENCES Auditoria (id) ON DELETE CASCADE
      );
    ''');

    // Insertar datos iniciales
    await ColorData.insertInitialColors(db);
    await TallaData.insertInitialSizes(db);
    await DescripcionData.insertInitialDescriptions(db);
    await TipoInspeccionData.insertInitialTipoInspecciones(db);
    await EstiloData.insertInitialStyles(db);
    await NivelInspeccionData.insertInitialNivelInspecciones(db);
    await NqaData.insertInitialNQA(db);
    await MargenErrorData.insertInitialMargenErrores(db);
    await InspeccionData.insertInitialInspecciones(db);
    await UserSettingsData.insertInitialUserSettings(db);
    await ToleranciaData.insertInitialTolerancias(db);
    await DefectoData.insertInitialDefects(db);


  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar un nuevo defecto a la tabla Defecto
      await db.execute('''
        INSERT INTO Defecto (codigo, nombre, elementos) 
        VALUES ('10', 'TEÑIDO', '["TEÑIDO","OTROS"]');
      ''');

      //Agregar nuevos estilos
      await db.execute('''
        INSERT INTO Estilo (nombre) VALUES 
          ('428-118'),
          ('428-122'),
          ('428-123');
       ''');

      //iNSERTAR NUESVAS DESCRIPCIPCIONES DE DEFECTOS
      //33,34,35,36,37,38,39,40,41,42,43     -6

      await db.execute('''
        INSERT INTO Descripcion (descripcion) VALUES 
          ('ALTO DESDE HPS'),
          ('ANCHO DE BUSTO'),
          ('ANCHO DE ESCOTE'),
          ('CAÍDA DE ESCOTE'),
          ('ALTO TOTAL CENTRO DELANTERO'),
          ('ALTO TOTAL CENTRO ESPALDA'),
          ('SEPARACIÓN DE TIRAS'),
          ('SEPARACIÓN TIRANTES'),
          ('LARGO DE TIRAS'),
          ('LARGO DE TIRANTES DELANTERO'),
          ('RECOGIDO EN MEDIO');
       ''');

      // Insertar nuevos datos en Tolerancia
      //428-118
      //428-122
      //428-123
      await db.execute('''
        INSERT INTO Tolerancia (id_estilo, datos) VALUES
          (70, '{"9": {"22": 91.0},"10": {"22": 99.0}}'),
          (71, '{"8": {"20": 90.0},"9": {"20": 95.0},"10": {"20": 99.0}}'),
          (72, '{"8": {"21": 91.0},"9": {"21": 96.0},"10": {"21": 101.0}}');
      ''');

      // Modificar datos existentes en Tolerancia
      await db.execute('''
        UPDATE Tolerancia SET 
        datos = '{"8": {"22": 92.0},"9": {"22": 93.0},"10": {"22": 101.0}}'
        WHERE id_estilo = 28;
      ''');

      await db.execute('''
        UPDATE Tolerancia SET 
        datos = '{
        "6": {"20": 18.0, "28": 25.5, "5": 10.0, "30": 8.0, "29": 14.0, "12": 23.0, "6": 3.0, "31": 8.5, "32": 8.0, "33": 10.0, "35": 29.0},
        "7": {"20": 19.0, "28": 27.5, "5": 10.0, "30": 10.0, "29": 15.0, "12": 25.5, "6": 3.0, "31": 9.0, "32": 8.0, "33": 10.0, "35": 29.5}
        }'
        WHERE id_estilo = 64;
      ''');

      await db.execute('''
        UPDATE Tolerancia SET 
        datos = '{
        "6": {"27": 18.0, "28": 25.0, "12": 26.0, "6": 2.5, "29": 15.0, "30": 3.0, "31": 14.5, "32": 7.0, "33": 9.0, "5": 9.5},
        "7": {"27": 19.0, "28": 26.5, "12": 28.0, "6": 2.5, "29": 15.5, "30": 3.5, "31": 15.5, "32": 7.5, "33": 9.5, "5": 10.0}
        }'
        WHERE id_estilo = 65;
      ''');

      await db.execute('''
        UPDATE Tolerancia SET 
        datos = '{
        "8": {"11": 29.5, "12": 29.0, "19": 20.0, "16": 12.0, "4": 13.0, "7": 3.5, "34": 13.0, "17": 10.0, "36": 35.0, "37": 7.0},
        "9": {"11": 31.5, "12": 30.0, "19": 21.5, "16": 13.0, "4": 14.0, "7": 4.0, "34": 13.0, "17": 10.5, "36": 35.0, "37": 7.0},
        "10": {"11": 33.0, "12": 32.5, "19": 23.0, "16": 13.5, "4": 15.0, "7": 4.5, "34": 13.0, "17": 11.5, "36": 35.0, "37": 7.0}
        }'
        WHERE id_estilo = 68;
      ''');

      await db.execute('''
        UPDATE Tolerancia SET 
        datos = '{
        "8": {"23": 17.0, "12": 29.0},
        "9": {"23": 19.7, "12": 31.0},
        "10": {"23": 22.0, "12": 33.0}
        }'
        WHERE id_estilo = 69;
      ''');


      // Agregar columna "titulo" a las tablas de imágenes
      await db.execute('ALTER TABLE ImagenVisual ADD COLUMN titulo TEXT;');
      await db.execute('ALTER TABLE ImagenEmpaque ADD COLUMN titulo TEXT;');
      await db.execute('ALTER TABLE ImagenMedida ADD COLUMN titulo TEXT;');

      // Agregar columna "nota" a la tabla Elemento
      await db.execute('ALTER TABLE Elemento ADD COLUMN nota TEXT;');

    }

    if (oldVersion <= 6) {

      await db.execute('''
        INSERT INTO Estilo (nombre) VALUES 
          ('428-132')
       ''');
    }

    if (oldVersion <= 7) {


      await db.execute('''
        UPDATE Tolerancia SET 
        datos = '{
        "8": {"22": 90.0},
        "9": {"22": 95.0},
        "10": {"22": 100.0}
        }'
        WHERE id_estilo = 71;
      ''');

      await db.execute('''
        UPDATE Tolerancia SET 
        datos = '{
        "8": {"22": 87.5},
        "9": {"22": 100.0},
        "10": {"22": 102.0}
        }'
        WHERE id_estilo = 31;
      '''); //428-131

      await db.execute('''
        UPDATE Tolerancia SET 
        datos = '{
        "8": {"21": 97.0, "12": 28.5, "3": 9.5},
        "9": {"21": 100.0, "12": 31.0, "3": 10.7},
        "10": {"21": 103.0, "12": 33.5, "3": 11.5}
        }'
        WHERE id_estilo = 63;
      '''); //SLLM01-101

      await db.execute('''
        UPDATE Tolerancia SET 
        datos = '{
        "8": {"11": 29.0, "12": 28.5, "19": 20.5, "16": 16.5, "5": 13.0, "6": 4.0, "34": 15.0, "17": 10.0},
        "9": {"11": 31.5, "12": 30.0, "19": 22.5, "16": 18.0, "5": 14.0, "6": 4.0, "34": 15.0, "17": 11.0},
        "10": {"11": 33.5, "12": 31.5, "19": 24.0, "16": 19.0, "5": 15.0, "6": 4.5, "34": 15.5, "17": 11.5}
        }'
        WHERE id_estilo = 67;
      '''); //SLT2-101

    }


    if(oldVersion <9){
      await db.execute('''
        INSERT INTO Tolerancia (id_estilo, datos) VALUES
          (73, 
          '{ "9": {"22": 92.0},
          "10": {"22": 97.0}}'
          )
      ''');
    }


  }
}