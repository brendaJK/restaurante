import 'package:flutter/material.dart';
import 'package:restaurante/controllers/controllerCorredor.dart';

class CorredorPage extends StatefulWidget {
  const CorredorPage({super.key});

  @override
  _CorredorPageState createState() => _CorredorPageState();
}

class _CorredorPageState extends State<CorredorPage> {
  late Future<List<Map<String, dynamic>>> _mesasDelCorredorFuture;
  final CorredorController _controller = CorredorController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _mesasDelCorredorFuture = _controller.getMesasDelCorredor();
    });
  }

  void _limpiarMesa(int idMesa) async {
    bool success = await _controller.limpiarMesa(idMesa);
    if (success) {
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al limpiar la mesa')),
      );
    }
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'Libre':
        return Colors.green;
      case 'Asignada':
        return Colors.blue;
      case 'Pedido':
        return Colors.yellow;
      case 'Comiendo':
        return Colors.orange;
      case 'Limpieza':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corredor Page'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _mesasDelCorredorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay mesas asignadas.'));
          } else {
            final mesas = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0,
                ),
                itemCount: mesas.length,
                itemBuilder: (context, index) {
                  final mesa = mesas[index];
                  return Card(
                    color: _getColorForStatus(mesa['estatus']),
                    child: InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
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
                            ElevatedButton(
                              onPressed: () {
                                _limpiarMesa(mesa['id']);
                              },
                              child: const Text('Limpiar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
