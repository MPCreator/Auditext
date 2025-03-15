class TransformacionDatosService {
  Map<String, Map<String, dynamic>> transformarDatos(List<Map<String, dynamic>> datosProcesados) {
    Map<String, Map<String, dynamic>> agrupado = {};

    for (var dato in datosProcesados) {
      String codigo = dato["CÓDIGO"];
      String descripcion = dato["DESCRIPCIÓN"];
      int total = dato["TOTAL"] is int ? dato["TOTAL"] : int.parse(dato["TOTAL"].toString());
      String talla = dato["TALLA"];
      String color = dato["COLOR"];

      if (!agrupado.containsKey(codigo)) {
        agrupado[codigo] = {
          "CÓDIGO": codigo,
          "DESCRIPCIÓN": descripcion,
          "TOTAL": 0,
          "COLORES": {},
          "TALLAS": {},
        };
      }

      // Suma el total general
      agrupado[codigo]!["TOTAL"] += total;

      // Agrega el subtotal por color
      if (!agrupado[codigo]!["COLORES"].containsKey(color)) {
        agrupado[codigo]!["COLORES"][color] = 0;
      }
      agrupado[codigo]!["COLORES"][color] += total;

      // Agrega el subtotal por talla
      if (!agrupado[codigo]!["TALLAS"].containsKey(talla)) {
        agrupado[codigo]!["TALLAS"][talla] = 0;
      }
      agrupado[codigo]!["TALLAS"][talla] += total;
    }

    return agrupado;
  }
}
