import 'package:flutter/material.dart';
import 'package:restaurante/controllers/controllerHost.dart' as host_controller;

class MesaComandaPage extends StatefulWidget {
  final int numComanda;

  const MesaComandaPage({super.key, required this.numComanda});

  @override
  _MesaComandaPageState createState() => _MesaComandaPageState();
}

class _MesaComandaPageState extends State<MesaComandaPage> {
  final host_controller.HostController _controller =
      host_controller.HostController();
  late Future<List<Map<String, dynamic>>> _freeMesasFuture;
  Map<String, dynamic>? _selectedMesa;
  final TextEditingController _nombreClienteController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _freeMesasFuture = _controller.getFreeMesas();
  }

  Future<void> _assignComanda() async {
    final nombreCliente = _nombreClienteController.text;

    if (_selectedMesa != null && nombreCliente.isNotEmpty) {
      try {
        await _controller.assignComanda(
            widget.numComanda, _selectedMesa!['id'], nombreCliente);
        await _controller.getFreeMesas();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comanda asignada con éxito')),
        );
        Navigator.pop(context, true);

        _nombreClienteController.clear();
        setState(() {
          _selectedMesa = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error asignando comanda: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Por favor, selecciona una mesa y ingresa el nombre del cliente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Comanda a Mesa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Número de Comanda: ${widget.numComanda}'),
            const SizedBox(height: 16.0),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _freeMesasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay mesas libres.'));
                } else {
                  final mesas = snapshot.data!;
                  return DropdownButton<Map<String, dynamic>>(
                    isExpanded: true,
                    value: _selectedMesa,
                    items: mesas.map((mesa) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: mesa,
                        child: Text(mesa['mesanombre']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMesa = value;
                      });
                    },
                    hint: const Text('Selecciona una mesa'),
                  );
                }
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nombreClienteController,
              decoration:
                  const InputDecoration(labelText: 'Nombre del Cliente'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _assignComanda,
              child: const Text('Asignar'),
            ),
          ],
        ),
      ),
    );
  }
}
