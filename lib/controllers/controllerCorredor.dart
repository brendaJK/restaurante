import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CorredorController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMesasDelCorredor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? idUsuario = prefs.getInt('idUsuario');

      if (idUsuario == null) {
        print('No se encontró un idUsuario en SharedPreferences');
        return [];
      }

      final mesasResponse = await _client
          .from('mesa')
          .select('id, estatus, mesanombre')
          .eq('idCorredor', idUsuario)
          .eq('estatus', 'Limpiar');

      final List<dynamic> mesasData = mesasResponse as List<dynamic>;

      return mesasData.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error al obtener las mesas del corredor: $e');
      return [];
    }
  }

  Future<bool> limpiarMesa(int idMesa) async {
    try {
      final updateResponse = await _client
          .from('mesa')
          .update({'estatus': 'Libre'}).eq('id', idMesa);

      if (updateResponse == null) {
        print('Mesa $idMesa actualizada a Libre');
        return true;
      } else {
        print('Error al actualizar la mesa: ${updateResponse.error!.message}');
        return false;
      }
    } catch (e) {
      print('Error al limpiar la mesa: $e');
      return false;
    }
  }
}
