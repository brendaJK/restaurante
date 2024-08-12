import 'package:flutter/material.dart';
import 'package:restaurante/controllers/controllerHost.dart' as host_controller;
import 'package:restaurante/layouts/pages/mesaComanda.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HostPage extends StatefulWidget {
  const HostPage({super.key});

  @override
  _HostPageState createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  late Future<int> _nextComandaNumberFuture;
  late Future<List<Map<String, dynamic>>> _mesasWithStatusFuture;
  final host_controller.HostController _controller =
      host_controller.HostController();

  void _loadData() {
    setState(() {
      _nextComandaNumberFuture = _controller.getNextComandaNumber();
      _mesasWithStatusFuture = _controller.getMesasWithStatus();
    });
  }

  Future<void> _onMesaSelected(int idMesaSeleccionada) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('idMesaSeleccionada', idMesaSeleccionada);

    final storedIdMesa = prefs.getInt('idMesaSeleccionada');
    print('Mesa seleccionada guardada en SharedPreferences: $storedIdMesa');
  }

  Future<void> obtenerIdMesaSeleccionada() async {
    final prefs = await SharedPreferences.getInstance();
    final idMesaSeleccionada = prefs.getInt('idMesaSeleccionada');
    print(
        'Mesa seleccionada recuperada de SharedPreferences: $idMesaSeleccionada');
  }

  Future<void> _navigateToMesaComanda(int numComanda) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MesaComandaPage(numComanda: numComanda),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
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
        title: const Text('Host Page'),
      ),
      body: FutureBuilder<int>(
        future: _nextComandaNumberFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(
                child: Text('No se pudo obtener el número de comanda.'));
          } else {
            final numComanda = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Número de Comanda: $numComanda'),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => _navigateToMesaComanda(numComanda),
                    child: const Text('Asignar'),
                  ),
                  const SizedBox(height: 16.0),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _mesasWithStatusFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData) {
                        return const Center(
                            child: Text('No se pudieron obtener las mesas.'));
                      } else {
                        final mesas = snapshot.data!;
                        return Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  4, // Aumenta el número de columnas para hacer los cuadros más pequeños
                              crossAxisSpacing:
                                  2.0, // Reduce aún más el espacio entre columnas
                              mainAxisSpacing:
                                  2.0, // Reduce aún más el espacio entre filas
                            ),
                            itemCount: mesas.length,
                            itemBuilder: (context, index) {
                              final mesa = mesas[index];
                              return Card(
                                color: _getColorForStatus(mesa['estatus']),
                                child: InkWell(
                                  onTap: () {
                                    final int idMesaSeleccionada = mesa['id'];
                                    print(
                                        'ID de mesa seleccionada en el onTap: $idMesaSeleccionada');
                                    _onMesaSelected(idMesaSeleccionada);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
