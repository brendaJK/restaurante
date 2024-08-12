import 'package:supabase_flutter/supabase_flutter.dart';

class ProductoController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getProductosByCategoria(
      String categoria) async {
    final response = await _client
        .from('producto')
        .select('id, nombre, precio')
        .eq('categoria', categoria);
    return List<Map<String, dynamic>>.from(response as List);
  }
}
