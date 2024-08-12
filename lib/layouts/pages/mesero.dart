import 'package:flutter/material.dart';
import 'package:restaurante/controllers/controllerMesero.dart';
import 'package:restaurante/layouts/pages/productos.dart'; // Asegúrate de importar la pantalla de productos
import 'package:shared_preferences/shared_preferences.dart';

class MeseroPage extends StatefulWidget {
  const MeseroPage({super.key});

  @override
  _MeseroPageState createState() => _MeseroPageState();
}

class _MeseroPageState extends State<MeseroPage> {
  late Future<List<Map<String, dynamic>>> _mesasFuture;
  final MeseroController _controller = MeseroController();

  @override
  void initState() {
    super.initState();
    _loadMesas();
  }

  void _loadMesas() async {
    setState(() {
      _mesasFuture = _controller.getMesasByUsuario();
    });
  }

  Future<void> _navigateToProductos(int idMesa) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('idMesa', idMesa);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductosPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesas'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _mesasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay mesas disponibles.'));
          } else {
            final mesas = snapshot.data!;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 2.0,
                mainAxisSpacing: 2.0,
              ),
              itemCount: mesas.length,
              itemBuilder: (context, index) {
                final mesa = mesas[index];
                return Card(
                  color: Colors.grey,
                  child: InkWell(
                    onTap: () {
                      _navigateToProductos(mesa['id']);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mesa['mesanombre'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Estatus: ${mesa['estatus']}',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
