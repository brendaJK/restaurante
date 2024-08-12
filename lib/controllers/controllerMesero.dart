import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MeseroController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMesasByUsuario() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? usuarioData = prefs.getString('usuario');

      if (usuarioData != null) {
        final Map<String, dynamic> user = jsonDecode(usuarioData);
        final int userId = user['id'];

        final response =
            await _client.from('mesa').select().eq('idusuario', userId);

        return List<Map<String, dynamic>>.from(response as List<dynamic>);
      } else {
        throw Exception('No user data found in SharedPreferences');
      }
    } catch (e) {
      print('Error getting mesas: $e');
      throw Exception('Error getting mesas: $e');
    }
  }
}
