import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:restaurante/controllers/controllerCompra.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductoComprasPage extends StatefulWidget {
  const ProductoComprasPage({super.key});

  @override
  _ProductoComprasPageState createState() => _ProductoComprasPageState();
}

class _ProductoComprasPageState extends State<ProductoComprasPage> {
  final CompraController _controller = CompraController();
  List<Map<String, dynamic>> _productosAgregados = [];
  Map<String, int> _cantidades = {};
  Map<String, List<String>> _ingredientesSeleccionados = {};
  double _totalCompra = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProductosAgregados();
  }

  Future<void> _loadProductosAgregados() async {
    final prefs = await SharedPreferences.getInstance();
    final String? productosJson = prefs.getString('productosAgregados');

    if (productosJson != null) {
      setState(() {
        _productosAgregados =
            List<Map<String, dynamic>>.from(json.decode(productosJson));
        _productosAgregados.forEach((producto) {
          _cantidades[producto['id'].toString()] = 1;
        });
        _calcularTotalCompra();
      });
    }
  }

  void _calcularTotalCompra() {
    double total = 0.0;
    _productosAgregados.forEach((producto) {
      final productoId = producto['id'].toString();
      final precio = producto['precio'] as double;
      final cantidad = _cantidades[productoId] ?? 1;
      total += precio * cantidad;
    });
    setState(() {
      _totalCompra = total;
    });
  }

  Future<void> _removeProduct(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? productosJson = prefs.getString('productosAgregados');
    List<Map<String, dynamic>> productos = [];

    if (productosJson != null) {
      productos = List<Map<String, dynamic>>.from(json.decode(productosJson));
    }

    productos = productos.map((producto) {
      producto['id'] = producto['id'].toString();
      return producto;
    }).toList();

    final productoEncontrado = productos.firstWhere(
      (producto) => producto['id'] == productId,
      orElse: () => {},
    );

    if (productoEncontrado.isNotEmpty) {
      productos.removeWhere((producto) => producto['id'] == productId);

      await prefs.setString('productosAgregados', json.encode(productos));

      setState(() {
        _productosAgregados = productos;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto no encontrado')),
      );
    }
  }

  void _incrementarCantidad(String productId) {
    setState(() {
      _cantidades[productId] = (_cantidades[productId] ?? 1) + 1;
      _calcularTotalCompra();
    });
  }

  void _disminuirCantidad(String productId) {
    setState(() {
      if (_cantidades[productId]! > 1) {
        _cantidades[productId] = (_cantidades[productId] ?? 1) - 1;
        _calcularTotalCompra();
      }
    });
  }

  void debugIngredientesSeleccionados(List<Map<String, dynamic>> productos) {
    for (var producto in productos) {
      print('Producto ID: ${producto['id']}');
      if (producto['ingredientes'] != null &&
          producto['ingredientes'].isNotEmpty) {
        for (var ingrediente in producto['ingredientes']) {
          print(' - Ingrediente ID: $ingrediente');
        }
      } else {
        print(' - No se seleccionaron ingredientes');
      }
    }
  }

  Future<void> _printSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final String? productosJson = prefs.getString('productosAgregados');
    print('Productos Agregados: $productosJson');

    final int? idMesaSeleccionada = prefs.getInt('idMesaSeleccionada');
    print('ID Mesa Seleccionada: $idMesaSeleccionada');

    final allKeys = prefs.getKeys();
    for (String key in allKeys) {
      print('Clave: $key, Valor: ${prefs.get(key)}');
    }
  }

  Future<void> _guardarCompra() async {
    final int idMesaSeleccionada = 1;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('idMesaSeleccionada', idMesaSeleccionada);

    await _printSharedPreferences();

    final int? idComanda =
        await _controller.getIdComandaActivada(idMesaSeleccionada);

    if (idComanda != null) {
      List<Map<String, dynamic>> productosConCantidades =
          _productosAgregados.map((producto) {
        final productoId = producto['id'].toString();
        final cantidad = _cantidades[productoId] ?? 1;
        final ingredientes = _ingredientesSeleccionados[productoId]
                ?.map((ingrediente) => int.tryParse(ingrediente) ?? 0)
                .toList() ??
            [];

        return {
          'id': producto['id'],
          'cantidad': cantidad,
          'ingredientes': ingredientes,
        };
      }).toList();

      try {
        await _controller.saveCompra(
            idComanda, 'Tomada', _totalCompra, productosConCantidades);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compra guardada exitosamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la compra: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener el idComanda')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos en la Compra'),
      ),
      body: ListView.builder(
        itemCount: _productosAgregados.length,
        itemBuilder: (context, index) {
          final producto = _productosAgregados[index];
          final productoId = producto['id'].toString();
          final precio = producto['precio'] as double;
          final cantidad = _cantidades[productoId] ?? 1;
          return Card(
            child: Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(
                    'assets/$productoId.webp',
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto['nombre'],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${precio * cantidad}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      FutureBuilder<List<String>>(
                        future: _controller.getIngredientes(productoId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Text(
                                'No hay ingredientes disponibles.');
                          } else {
                            final ingredientes = snapshot.data!;
                            return MultiSelectDialogField<String>(
                              items: ingredientes.map((String ingrediente) {
                                return MultiSelectItem<String>(
                                    ingrediente, ingrediente);
                              }).toList(),
                              title: Text('Selecciona los ingredientes'),
                              selectedColor: Colors.blue,
                              onConfirm: (values) {
                                setState(() {
                                  _ingredientesSeleccionados[productoId] =
                                      values
                                          .map((value) => value.toString())
                                          .toList();
                                });
                              },
                              initialValue:
                                  _ingredientesSeleccionados[productoId] ?? [],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => _disminuirCantidad(productoId),
                              ),
                              Text(cantidad.toString()),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () =>
                                    _incrementarCantidad(productoId),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => _removeProduct(productoId),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$$_totalCompra',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _guardarCompra,
                child: const Text('Guardar Compra'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
