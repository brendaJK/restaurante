import 'package:supabase_flutter/supabase_flutter.dart';

class CompraController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int?> getIdComandaActivada(int idMesa) async {
    try {
      final response = await _client
          .from('comandas')
          .select('id')
          .eq('idMesa', idMesa)
          .eq('estatus', 'Activa')
          .maybeSingle();

      if (response == null || response.isEmpty) {
        print('No se encontró una comanda activa para la mesa ID $idMesa.');
        return null;
      } else {
        final comandaId = response['id'] as int?;
        print('Comanda encontrada para mesa ID $idMesa: $comandaId');
        return comandaId;
      }
    } catch (e) {
      print('Error al obtener idComanda: $e');
      return null;
    }
  }

  Future<void> saveCompra(int idComanda, String estatus, double total,
      List<Map<String, dynamic>> productos) async {
    try {
      print(idComanda);
      final compraResponse = await _client
          .from('compra')
          .insert({
            'idcomanda': idComanda,
            'estatus': estatus,
            'total': total,
          })
          .select()
          .single();

      final int idCompra = compraResponse['id'] as int;
      print('Compra Insertada: $idCompra');

      // Insertar detalles de la compra
      for (var producto in productos) {
        final detalleCompraResponse = await _client
            .from('detallecompra')
            .insert({
              'idcompra': idCompra,
              'idproducto': producto['id'],
              'estatus': 'Ordenado',
              'cantidad': producto['cantidad'],
            })
            .select()
            .single();

        final int idDetalle = detalleCompraResponse['id'] as int;
        print('DetalleCompra Insertado: $idDetalle');

        if (producto['ingredientes'] != null &&
            producto['ingredientes'].isNotEmpty) {
          for (var ingrediente in producto['ingredientes']) {
            print(
                'Insertando ingrediente $ingrediente para detalle $idDetalle');
            await _client.from('detalleProducto').insert({
              'idetalle': idDetalle,
              'idingrediente': ingrediente,
            });
          }
        }
      }

      print('Compra guardada exitosamente');
    } catch (e) {
      print('Error al guardar la compra: $e');
    }
  }

  Future<List<String>> getIngredientes(String productoId) async {
    try {
      final response = await _client
          .from('ingrediente')
          .select('nombre')
          .eq('idproducto', productoId);

      List<String> ingredientes = List<String>.from(
        response.map((ingrediente) => ingrediente['nombre'] as String),
      );

      return ingredientes;
    } catch (e) {
      throw Exception('Error al obtener los ingredientes: $e');
    }
  }
}
