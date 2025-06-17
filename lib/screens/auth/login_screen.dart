import 'package:flutter/material.dart';
import 'package:materias_app/controller/login_controller';
import 'package:materias_app/screens/auth/register_screen.dart';
import 'package:materias_app/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final prefs = snapshot.data;
        final token = prefs?.getString('accessToken');

        // Si el usuario ya está autenticado, mostrar un mensaje y redirigir a la pantalla de bienvenida
       if (token != null && token.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("The user is already authenticated. Log out before continuing."),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          });

          return const Scaffold(
            body: Center(
              child: Text(
                "You are now authenticated. Log out to log in again.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }


        return Scaffold(
          body: Stack(
            children: [

             Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/loginbackground.jpg'),
                    fit: BoxFit.cover, // Ajusta la imagen para llenar la pantalla
                  ),
                ),
              ),

              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          SizedBox(height: constraints.maxHeight * 0.1),

                          // Logo de la UCEM.
                          const CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage("assets/ucem.png"),
                            backgroundColor: Colors.white,
                          ),
                          SizedBox(height: constraints.maxHeight * 0.1),

                          // Título de la pantalla 
                          Text(
                            "Sign In",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(fontWeight: FontWeight.bold, color: Colors.lightBlue),
                          ),

                          SizedBox(height: constraints.maxHeight * 0.05),

                          // Formulario de inicio de sesión 
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [

                                // Campo de entrada para el correo electrónico y validaciónes.
                                TextFormField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'Enter your email', 
                                    labelStyle: TextStyle(color: Colors.cyan),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(Radius.circular(50)),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a valid email address'; 
                                    }
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                      return 'Invalid email format'; 
                                    }
                                    return null;
                                  },
                                ),

                                // Campo de entrada para la contraseña y validaciónes.
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: TextFormField(
                                    controller: passwordController,
                                    obscureText: true, // Oculta la contraseña.
                                    decoration: const InputDecoration(
                                      labelText: 'Password',
                                      hintText: 'Enter your password', 
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
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password'; 
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters long';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                // Botón de inicio de sesión.
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) { 
                                      String? token = (await login(emailController.text, passwordController.text));

                                      if (token != null && token.isNotEmpty) {
                                        final prefs = await SharedPreferences.getInstance();
                                        await prefs.setString('accessToken', token);
                                        await prefs.setString('email', emailController.text);

                                        if (context.mounted) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => WelcomePage(email: emailController.text),
                                            ),
                                          );
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Incorrect credentials")), 
                                          );
                                        }
                                      }
                                    }
                                  },

                                  // Estilo del botón de inicio de sesión.
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: const Color.fromARGB(255, 0, 59, 250),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 48),
                                    shape: const StadiumBorder(),
                                  ),
                                  child: const Text("Sign in"), 
                                ),
                                const SizedBox(height: 16.0),

                                // Enlace para registro de usuario.
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Don't have an account?", 
                                      style: TextStyle(color: Color.fromARGB(255, 0, 59, 250), fontSize: 16),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                                        );
                                      },
                                      child: const Text(
                                        "Register", 
                                        style: TextStyle(color: Colors.purple, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
