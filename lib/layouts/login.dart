import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    try {
      print('Username: ${_usernameController.text}');
      print('Password: ${_passwordController.text}');

      final response = await Supabase.instance.client
          .from('usuarios')
          .select('id, correo, contrasenia, rol')
          .eq('correo', _usernameController.text)
          .eq('contrasenia', _passwordController.text)
          .single();

      if (response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no encontrado')),
        );
        return;
      }

      final user = response;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuario', jsonEncode(user));
      await prefs.setString('rol', user['rol']);
      await prefs.setInt('idUsuario', user['id']);

      print('User Data: ${prefs.getString('usuario')}');
      print('User Role: ${user['rol']}');
      print('User ID: ${prefs.getInt('idUsuario')}');

      String role = user['rol'];
      if (role == 'Host') {
        Navigator.pushReplacementNamed(context, '/host');
      } else if (role == 'Mesero') {
        Navigator.pushReplacementNamed(context, '/mesero');
      } else if (role == 'Cocina') {
        Navigator.pushReplacementNamed(context, '/cocina');
      } else if (role == 'Corredor') {
        Navigator.pushReplacementNamed(context, '/corredor');
      } else if (role == 'Caja') {
        Navigator.pushReplacementNamed(context, '/caja');
      } else if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        print('Rol no reconocido: $role');
      }
    } catch (error) {
      print('Exception: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.5),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Usuario',
                  helperText: 'Ingresa tu usuario',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.5),
              child: TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: 'Contraseña',
                  helperText: 'Ingresa tu contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                login(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CC896),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Iniciar Sesión',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
