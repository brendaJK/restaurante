import 'package:flutter/material.dart';
import 'package:restaurante/controllers/controllerCocina.dart';

class CocinaPage extends StatefulWidget {
  const CocinaPage({super.key});

  @override
  _CocinaPageState createState() => _CocinaPageState();
}

class _CocinaPageState extends State<CocinaPage> {
  final CocinaController _controller = CocinaController();
  late Future<List<Map<String, dynamic>>> _comprasTomadas;

  @override
  void initState() {
    super.initState();
    _comprasTomadas = _controller.getComprasTomadas();
  }

  Future<void> _cambiarEstatus(int idCompra, int idComanda, int idMesa) async {
    try {
      await _controller.updateCompraEstatus(idCompra, 'Cocinado');
      await _controller.updateComandaEstatus(idComanda, 'Servida');
      await _controller.updateMesaEstatus(idMesa);

      setState(() {
        _comprasTomadas = _controller.getComprasTomadas();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estatus actualizado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar estatus: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compras en Cocina'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _comprasTomadas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay compras tomadas.'));
          } else {
            final compras = snapshot.data!;
            return ListView.builder(
              itemCount: compras.length,
              itemBuilder: (context, index) {
                final compra = compras[index];
                final productos = compra['detallecompra'] as List<dynamic>;
                final idMesa = compra['idMesa'] as int;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Comanda: ${compra['idcomanda']}'),
                        Text('Total: \$${compra['total']}'),
                        const SizedBox(height: 8.0),
                        const Text('Productos:'),
                        ...productos.map((detalle) {
                          return Text(
                            '${detalle['nombreProducto']} - ${detalle['cantidad']}',
                            style: const TextStyle(fontSize: 16),
                          );
                        }).toList(),
                        const SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            _cambiarEstatus(
                              compra['id'] as int,
                              compra['idcomanda'] as int,
                              idMesa,
                            );
                          },
                          child: const Text('Cocinado'),
                        ),
                      ],
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
