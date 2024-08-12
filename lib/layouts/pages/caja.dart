import 'package:flutter/material.dart';
import 'package:restaurante/controllers/controllerCaja.dart'; // Asegúrate de que la importación sea correcta

class CajaPage extends StatefulWidget {
  const CajaPage({super.key});

  @override
  _CajaPageState createState() => _CajaPageState();
}

class _CajaPageState extends State<CajaPage> {
  final CajaController _controller = CajaController();
  late Future<List<Map<String, dynamic>>> _mesasFuture;
  Map<String, dynamic>? _comandaDetails;

  @override
  void initState() {
    super.initState();
    _loadMesas();
  }

  Future<void> _loadMesas() async {
    setState(() {
      _mesasFuture = _controller.getMesas();
    });
  }

  Future<void> _loadComandaDetails(int idMesa) async {
    final details = await _controller.getComandaDetails(idMesa);
    setState(() {
      _comandaDetails = details;
    });
  }

  Future<void> _pagar() async {
    if (_comandaDetails == null) {
      return;
    }

    await _controller.guardarPago(
      _comandaDetails!['idComanda'] as int,
      _comandaDetails!['totalSum'] as num,
      _comandaDetails!['idMesa'] as int,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pago realizado con éxito')),
    );

    setState(() {
      _comandaDetails = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caja'),
      ),
      body: Column(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
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
                return DropdownButton<int>(
                  hint: const Text('Seleccionar Mesa'),
                  items: mesas.map((mesa) {
                    return DropdownMenuItem<int>(
                      value: mesa['id'],
                      child: Text(mesa['mesanombre']),
                    );
                  }).toList(),
                  onChanged: (idMesa) {
                    if (idMesa != null) {
                      _loadComandaDetails(idMesa);
                    }
                  },
                );
              }
            },
          ),
          if (_comandaDetails != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Nombre del Cliente: ${_comandaDetails!['nombrecliente']}'),
                  Text('Número de Comanda: ${_comandaDetails!['numComan']}'),
                  Text('Total: ${_comandaDetails!['totalSum']}'),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _pagar,
                    child: const Text('Pagar'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
