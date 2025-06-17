import 'package:flutter/material.dart';
import 'package:materias_app/screens/auth/materias_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:materias_app/screens/auth/login_screen.dart';
import 'package:materias_app/screens/auth/profilescreen.dart';
import 'package:http/http.dart' as http;

//  pantalla de bienvenida
class WelcomePage extends StatefulWidget {
  final String email;

  const WelcomePage({super.key, required this.email});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String? tokenApp;



  
  // Mapa que controla la expansión de la información de cada carrera.
  final Map<String, bool> _expandedInfo = {
    'administracion': false,
    'sistemas': false,
    'industriales': false,
  };




  @override
  void initState() {
    super.initState();
    loadAccessToken(); // Carga el access token al iniciar la pantalla.
  }





  // Método para obtener el access token desde SharedPreferences.
  Future<void> loadAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');
    setState(() {
      tokenApp = accessToken ?? "No token found"; // Guarda el token si existe.
    });
    debugPrint("ACCESS TOKEN: $tokenApp");
  }




  // Método de logout: elimina el access token de la API y de SharedPreferences.
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token != null) {
      final url = Uri.parse('https://app-iv-ii-main-td0mcu.laravel.cloud/api/logout');
      final headers = {
        'Authorization': 'Bearer $token', // Envía el token para invalidarlo en la API.
        'Content-Type': 'application/json',
      };

      try {
        final response = await http.post(url, headers: headers);

        if (response.statusCode == 200) {
          debugPrint('Logout exitoso en la API');
        } else {
          debugPrint('Error al hacer logout en la API: ${response.body}');
        }
      } catch (e) {
        debugPrint('Error de conexión con la API: $e');
      }
    }

    await prefs.remove('accessToken'); // Elimina el token de la app localmente.
    
  
    // Redirige al usuario a la pantalla de inicio de sesión y elimina el historial de navegación.
    Navigator.pushAndRemoveUntil(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (_) => SignInScreen()),
      (route) => false,
    );
  }




  // se despliega la información de cada carrera al hacer clic.
  void toggleInfo(String key) {
    setState(() {
      _expandedInfo[key] = !_expandedInfo[key]!;
    });
  }



    // interfaz de usuario de la pantalla de bienvenida.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('Welcome', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),





      // Menú lateral con navegación.
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[


            // Encabezado con el nombre del usuario y logo.
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.lightBlue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/ucem.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome, ${widget.email}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),




            ListTile(
              leading: const Icon(Icons.account_circle, color: Colors.lightBlue),
              title: const Text('Profile', style: TextStyle(color: Colors.lightBlue)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              },             
            ),


            ListTile(
              leading: const Icon(Icons.school, color: Colors.lightBlue),
              title: const Text('Record Académico', style: TextStyle(color: Colors.lightBlue)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MateriasScreen()),
                );
              },
            ),



            ListTile(
              leading: const Icon(Icons.logout, color: Colors.lightBlue),
              title: const Text('Log out', style: TextStyle(color: Colors.lightBlue)),
              onTap: () => logout(context), // Llama la función de logout.
            ),
          ],
        ),
      ),



      // Contenido principal con información de carreras.
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageBox('assets/sistemas.png', 'Ingeniería en Sistemas', 
              'Revisa minuciosamente los datos para la creación de programas, aplicativos y herramientas que faciliten los procesos empresariales en un entorno de información segura y protegida.', 
              'sistemas', 150),
            _buildImageBox('assets/industriales.png', 'Ingeniería Industrial', 
              'Optimiza procesos, sistemas u organizaciones complejos mediante el desarrollo, la mejora y la implementación de sistemas integrados de personas, riqueza, conocimiento, información y equipamiento, energía, materiales y procesos.', 
              'industriales', 168),
            _buildImageBox('assets/administracion.png', 'Administración de Negocios', 
              'Asegura el funcionamiento óptimo de cada elemento dentro de la organización, promoviendo el uso eficiente de los recursos aplicándolos para la obtención de las rentabilidades propuestas.', 
              'administracion', 180),
          ],
        ),
      ),
    );
  }




  // Método para crear los bloques de información de cada carrera.
  Widget _buildImageBox(String imagePath, String title, String info, String key, double imageHeight) {
    return GestureDetector(
      onTap: () => toggleInfo(key),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          children: [
           
            // Imagen de la carrera con diseño responsive.
            Container(
              width: double.infinity,
              height: imageHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 10),
           
            // Título de la carrera.
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
           
            // Información expandible de cada carrera.
            if (_expandedInfo.containsKey(key) && _expandedInfo[key]!)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  info,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
