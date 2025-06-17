// Ignora la advertencia sobre el uso de context de forma asíncrona.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Pantalla de edición del perfil del usuario.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();



  // Controladores para los campos de nombre, email y nueva contraseña.
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false; // Estado para indicar si la solicitud está en progreso.

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }


  // Obtiene los datos del usuario desde SharedPreferences.
  Future<void> cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('user_name') ?? '';
      emailController.text = prefs.getString('user_email') ?? '';
    });
  }



  // Actualiza los datos del usuario en la API.
  Future<void> actualizarUsuarioEnAPI() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      mostrarSnackBar('No active session', Colors.red);
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse('https://app-iv-ii-main-td0mcu.laravel.cloud/api/edit');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      debugPrint('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson.containsKey('user')) {
          await guardarDatosLocalmente(responseJson['user']);
          mostrarSnackBar('Profile updated successfully', Colors.green);
        } else {
          mostrarSnackBar('Unexpected error in API', Colors.red);
        }
      } else {
        final responseJson = jsonDecode(response.body);
        final errorMsg = responseJson['message'] ?? 'Error updating profile';
        mostrarSnackBar(errorMsg, Colors.red);
      }
    } catch (e) {
      mostrarSnackBar('Connection error: $e', Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  // Guarda los nuevos datos del usuario en SharedPreferences.
  Future<void> guardarDatosLocalmente(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userData['name']);
    await prefs.setString('user_email', userData['email']);
    if (userData.containsKey('password')) {
      await prefs.setString('user_password', userData['password']);
    }
  }



  // Muestra un mensaje emergente con el resultado de la actualización.
  void mostrarSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }



  @override
  void dispose() {
    // Libera los recursos de los controladores cuando el widget se destruye.
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [


          // Fondo de la pantalla con una imagen.
          Positioned.fill(
            child: Image.asset(
              "assets/profile.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [



                  // Imagen de avatar del usuario.
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/user1.jpg"),
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(height: 12),





                  // Campo de entrada para el nombre del usuario.
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Name',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 0, 188, 212)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  ),





                  // Campo de entrada para el correo electrónico.
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'example@email.com',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 0, 188, 212)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                  ),





                  // Campo de entrada para actualizar la contraseña.
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Enter new password',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 0, 188, 212)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),




                  // Botón para guardar cambios.
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: actualizarUsuarioEnAPI,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color.fromARGB(255, 0, 59, 250),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text("Save Changes"),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
