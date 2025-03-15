import 'package:sqflite/sqflite.dart';

class DefectoData {
  static Future<void> insertInitialDefects(Database db) async {
    await db.execute('''
    INSERT INTO Defecto (codigo, nombre, elementos) VALUES
      ('01', 'COSTURA', 
        '["ACORDONADO", "REVENTADO", "DESCASADO EMBOLSADO", "PUNTADA SALTADA",
          "PESTAÑA INCORRECTA", "PLIEGUES", "PUNTADA CAÍDA", "PUNTADA RECORTADA",
          "RECOSIDO", "PICADO DE AGUJA", "HEUCO ONDEADO"]'
      ),
      ('02', 'ACABADO', 
        '["MANCHAS", "ACEITE", "TIERRA", "LAPIZ",
          "LAPICERO", "OTROS"]'
      ),
      ('03', 'LIMPIEZA', 
        '["HILO SIN RECORTAR"]'
      ),
      ('04', 'AVIOS', 
        '["ETIQUETA ROTA", "DECENTRADO", "TRANFER INCOMPLETO", "SIMBOLOS INCOMPLETOS"]'
      ),
      ('05', 'COSTURA PROCESO', 
        '["ADHESIVO POR RETIRAR", "TONO HILO", "TALLA CAMBIADA"]'
      ),
      ('06', 'ACABADO SIMETRÍAS', 
        '["LARGOS", "ANCHOS", "MANGA", "HOMBROS"]'
      ),
      ('07', 'LAVANDERÍA', 
        '["OTRO TONO", "HUECO MIGRADO", "MANCHA SILICONA", "PILLING",
          "QUEBRADURA", "TACTO ÁSPERO", "TONO VETEADOS"]'
      ),
      ('08', 'TEJIDOS', 
        '["HILO CORRIDO", "DISEÑO DISPAREJO", "HILO IRREGULAR", "OTROS"]'
      ),
      ('09', 'EMPAQUE', 
        '["CÓDIGO INCOMPLETO", "BOLSA ROTA", "RÓTULO INCOMPLETO", "TONO CAJA",
        "OTROS"]'
      );
      ('10', 'TEÑIDO', 
        '["TEÑIDO","OTROS"]'
      );
    ''');
  }
}
