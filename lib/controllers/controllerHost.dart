import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HostController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getFreeMesas() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final response =
        await _client.from('mesa').select('*').eq('estatus', 'Libre');

    final List<String> mesaStatusesToSave =
        response.map((e) => jsonEncode(e as Map<String, dynamic>)).toList();
    await prefs.setStringList('mesaStatuses', mesaStatusesToSave);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<int> getNextComandaNumber() async {
    final response = await _client
        .from('comandas')
        .select('numComan')
        .order('numComan', ascending: false)
        .limit(1);

    final lastNumComan =
        response.isNotEmpty ? int.parse(response[0]['numComan']) : 0;
    return lastNumComan + 1;
  }

  Future<void> assignComanda(
      int numComanda, int idMesa, String nombreCliente) async {
    try {
      final response1 = await _client
          .from('comandas')
          .select('id')
          .eq('numComan', numComanda.toString())
          .maybeSingle();

      final exists =
          response1 != null && response1.isNotEmpty && response1['id'] != null;

      if (exists) {
        await _client
            .from('comandas')
            .update({'idMesa': idMesa, 'nombrecliente': nombreCliente}).eq(
                'numComan', numComanda.toString());
      } else {
        await _client.from('comandas').insert({
          'numComan': numComanda.toString(),
          'idMesa': idMesa,
          'nombrecliente': nombreCliente
        });
      }

      await _client
          .from('mesa')
          .update({'estatus': 'Asignada'}).eq('id', idMesa);

      await saveMesaStatuses();
    } catch (e) {
      print('Error assigning comanda: $e');
      throw Exception('Error assigning comanda: $e');
    }
  }

  Future<void> saveMesaStatuses() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final response =
          await _client.from('mesa').select('id, mesanombre, estatus');

      final List<String> mesaStatuses =
          response.map((e) => jsonEncode(e as Map<String, dynamic>)).toList();

      await prefs.setStringList('mesaStatuses', mesaStatuses);
    } catch (e) {
      print('Error saving mesa statuses: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMesasWithStatus() async {
    final response =
        await _client.from('mesa').select('id, mesanombre, estatus');

    return List<Map<String, dynamic>>.from(response);
  }
}
