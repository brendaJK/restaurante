import 'package:supabase_flutter/supabase_flutter.dart';

class CocinaController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getComprasTomadas() async {
    try {
      final response = await _client
          .from('compra')
          .select('id, idcomanda, total, detallecompra(idproducto, cantidad)')
          .eq('estatus', 'Tomada');

      if (response is List) {
        final compras =
            response.map((item) => item as Map<String, dynamic>).toList();

        final productosResponse =
            await _client.from('producto').select('id, nombre');

        final productos = Map<String, String>.fromEntries(
          (productosResponse as List).map((item) {
            return MapEntry(item['id'].toString(), item['nombre']);
          }),
        );

        final comandasResponse =
            await _client.from('comandas').select('id, idMesa');

        final comandasMap = Map<int, int>.fromEntries(
          (comandasResponse as List).map((item) {
            return MapEntry(item['id'] as int, item['idMesa'] as int);
          }),
        );

        for (var compra in compras) {
          final detalles = compra['detallecompra'] as List<dynamic>;
          for (var detalle in detalles) {
            final productoId = detalle['idproducto'].toString();
            detalle['nombreProducto'] = productos[productoId] ?? 'Desconocido';
          }
          compra['idMesa'] = comandasMap[compra['idcomanda']];
        }

        return compras;
      } else {
        throw Exception('Error al obtener las compras');
      }
    } catch (e) {
      print('Error al obtener compras tomadas: $e');
      return [];
    }
  }

  Future<void> updateCompraEstatus(int idCompra, String estatus) async {
    try {
      final response = await _client
          .from('compra')
          .update({'estatus': estatus})
          .eq('id', idCompra)
          .select()
          .single();
      print('Compra actualizada: $response');
    } catch (e) {
      print('Error al actualizar estatus de compra: $e');
      throw Exception('Error al actualizar estatus de compra');
    }
  }

  Future<void> updateComandaEstatus(int idComanda, String estatus) async {
    try {
      final response = await _client
          .from('comandas')
          .update({'estatus': estatus})
          .eq('id', idComanda)
          .select()
          .single();
      print('Comanda actualizada: $response');
    } catch (e) {
      print('Error al actualizar estatus de comanda: $e');
      throw Exception('Error al actualizar estatus de comanda');
    }
  }

  Future<void> updateMesaEstatus(int idMesa) async {
    try {
      final response = await _client
          .from('mesa')
          .update({'estatus': 'Comiendo'})
          .eq('id', idMesa)
          .select()
          .single();
      print('Mesa actualizada: $response');
    } catch (e) {
      print('Error al actualizar estatus de mesa: $e');
      throw Exception('Error al actualizar estatus de mesa');
    }
  }
}
