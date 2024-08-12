import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CajaController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMesas() async {
    try {
      final response = await _client
          .from('mesa')
          .select('id, mesanombre')
          .order('mesanombre', ascending: true);

      if (response is List) {
        return response.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Error al obtener las mesas');
      }
    } catch (e) {
      print('Error al obtener las mesas: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getComandaDetails(int idMesa) async {
    try {
      final comandaResponse = await _client
          .from('comandas')
          .select('id, nombrecliente, numComan, idMesa')
          .eq('idMesa', idMesa)
          .eq('estatus', 'Servida')
          .single();

      if (comandaResponse is Map) {
        final comandaId = comandaResponse['id'] as int;

        final totalResponse = await _client
            .from('compra')
            .select('total')
            .eq('idcomanda', comandaId)
            .eq('estatus', 'Cocinado');

        final totalSum = totalResponse.fold<num>(
            0, (sum, item) => sum + (item['total'] as num));

        return {
          'nombrecliente': comandaResponse['nombrecliente'],
          'numComan': comandaResponse['numComan'],
          'totalSum': totalSum,
          'idComanda': comandaId,
          'idMesa': comandaResponse['idMesa'],
        };
      } else {
        throw Exception('No se encontró información de la comanda');
      }
    } catch (e) {
      print('Error al obtener los detalles de la comanda: $e');
      return {};
    }
  }

  Future<void> guardarPago(int idComanda, num total, int idMesa) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? idUsuario = prefs.getInt('idUsuario');

      if (idUsuario == null) {
        throw Exception('No se encontró idUsuario en SharedPreferences');
      }

      // Insertar el pago en la tabla 'caja'
      final response = await _client
          .from('caja')
          .insert({
            'idComanda': idComanda,
            'idUsuario': idUsuario,
            'total': total,
          })
          .select()
          .single();

      if (response != null) {
        print('Pago registrado exitosamente');

        final mesaUpdateResponse = await _client
            .from('mesa')
            .update({'estatus': 'Limpiar'}).eq('id', idMesa);

        if (mesaUpdateResponse != null) {
          print('Estatus de la mesa actualizado a "Limpiar"');
        } else {
          throw Exception('Error al actualizar el estatus de la mesa');
        }
      } else {
        throw Exception('Error al registrar el pago');
      }
    } catch (e) {
      print('Error al guardar el pago: $e');
    }
  }
}
