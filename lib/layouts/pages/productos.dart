import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:restaurante/controllers/controllerProducto.dart';
import 'package:restaurante/layouts/pages/productoCompra.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  _ProductosPageState createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final ProductoController _controller = ProductoController();
  late Future<List<Map<String, dynamic>>> _productosFuture;
  String _selectedCategory = 'Bebida';

  @override
  void initState() {
    super.initState();
    _loadProductos(_selectedCategory);
  }

  void _loadProductos(String categoria) {
    setState(() {
      _productosFuture = _controller.getProductosByCategoria(categoria);
    });
  }

  void _navigateToProductoCompras() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductoComprasPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de menú de categorías
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryButton('Bebida'),
                _buildCategoryButton('Comida'),
                _buildCategoryButton('Baguettes'),
                _buildCategoryButton('Postres'),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          // Lista de productos
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _productosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No hay productos disponibles.'));
                } else {
                  final productos = snapshot.data!;
                  return ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final producto = productos[index];
                      return Card(
                        child: ListTile(
                          leading: Image.asset('assets/${producto['id']}.webp'),
                          title: Text(producto['nombre']),
                          subtitle: Text('\$${producto['precio']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_shopping_cart),
                            onPressed: () {
                              _agregarProducto(producto);
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Compra',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            _navigateToProductoCompras();
          }
        },
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    return GestureDetector(
      onTap: () {
        _loadProductos(category);
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Column(
        children: [
          Text(
            category,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _selectedCategory == category ? Colors.blue : Colors.black,
            ),
          ),
          if (_selectedCategory == category)
            Container(
              margin: const EdgeInsets.only(top: 4.0),
              height: 2.0,
              width: 60.0,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }

  void _agregarProducto(Map<String, dynamic> producto) async {
    final prefs = await SharedPreferences.getInstance();
    final String? productosJson = prefs.getString('productosAgregados');
    List<Map<String, dynamic>> productos = [];

    if (productosJson != null) {
      productos = List<Map<String, dynamic>>.from(json.decode(productosJson));
    }

    productos.add({
      'id': producto['id'],
      'nombre': producto['nombre'],
      'precio': producto['precio']
    });

    await prefs.setString('productosAgregados', json.encode(productos));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto agregado')),
    );
  }
}
