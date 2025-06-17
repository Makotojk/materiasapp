// Ignora advertencias sobre el uso de context de forma asíncrona.
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:materias_app/screens/auth/login_screen.dart';
import 'package:materias_app/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:materias_app/models/materia.dart';
import 'package:materias_app/services/api_service.dart';

// Pantalla para visualizar y filtrar materias.
class MateriasScreen extends StatefulWidget {
  const MateriasScreen({super.key});

  @override
  State<MateriasScreen> createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  Future<List<Materia>>? materiasFuture; // Almacena las materias obtenidas de la API.
  String filtroSeleccionado = 'Todas'; // Estado del filtro seleccionado.
  String searchQuery = ''; // Estado para el filtro de búsqueda por nombre.
  Materia? materiaSeleccionada; // Estado de la materia seleccionada.

  // Listado de filtros disponibles.
  final List<String> filtros = ['Todas', 'Aprobadas', 'Pendientes', 'Matriculadas'];

  // Mapa que traduce los filtros a los valores esperados por la API.
  final Map<String, String> filtroToEstado = {'Aprobadas': 'aprobada', 'Pendientes': 'pendiente', 'Matriculadas': 'matriculada'};

  @override
  void initState() {
    super.initState();
    _loadMaterias(); // Carga las materias cuando la pantalla se inicializa.
  }

  // Carga las materias desde la API y aplica filtros según el estado seleccionado.
  Future<void> _loadMaterias() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    // Si no hay token, redirige al usuario a la pantalla de login.
    if (token == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    try {
      final todas = await ApiService.fetchMaterias(token);

      List<Materia> filtradas;
      if (filtroSeleccionado == 'Todas') {
        filtradas = todas;
      } else {
        final estadoReal = filtroToEstado[filtroSeleccionado]!;
        filtradas = todas.where((m) => m.estado.toLowerCase() == estadoReal).toList();
      }

      // Aplica filtro de búsqueda por nombre.
      if (searchQuery.isNotEmpty) {
        filtradas = filtradas.where((m) => m.nombre.toLowerCase().contains(searchQuery.toLowerCase())).toList();
      }

      setState(() {
        materiasFuture = Future.value(filtradas);
      });
    } catch (e) {
      setState(() {
        materiasFuture = Future.error(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con título y botón de retroceso.
      appBar: AppBar(
        title: const Text('Materias', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final email = prefs.getString('email');

            if (!mounted) return;

            // Redirige al usuario según su estado de autenticación.
            if (email != null) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomePage(email: email)));
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
            }
          },
        ),
      ),

      // Contenido principal de la pantalla.
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Barra de búsqueda para filtrar materias por nombre.
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                    _loadMaterias();
                  },
                  style: const TextStyle(color: Colors.lightBlue),
                  decoration: const InputDecoration(
                    labelText: 'Buscar materia',
                    labelStyle: TextStyle(color: Colors.lightBlue),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search, color: Colors.lightBlue),
                  ),
                ),

                const SizedBox(height: 12),

                // Menú desplegable para filtrar por estado de materia.
                DropdownButtonFormField<String>(
                  value: filtroSeleccionado,
                  items: filtros.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        filtroSeleccionado = value;
                        materiaSeleccionada = null;
                      });
                      _loadMaterias();
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Filtrar por estado', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),

          // Lista de materias según el filtro aplicado.
          Expanded(
            child: materiasFuture == null
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<Materia>>(
                    future: materiasFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No hay materias disponibles.'));
                      }

                      final materias = snapshot.data!;
                      return ListView.builder(
                        itemCount: materias.length,
                        itemBuilder: (context, index) {
                          final materia = materias[index];
                          return ListTile(
                            title: Text(materia.nombre),
                            subtitle: Text('Código: ${materia.codigo}'),
                            onTap: () {
                              setState(() {
                                materiaSeleccionada = materia;
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
          ),

          // Contenedor con los detalles de la materia seleccionada.
          SizedBox(
            height: 130,
            width: double.infinity,
            child: Container(
              color: Colors.lightBlue,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: materiaSeleccionada == null
                  ? const Align(
                      alignment: Alignment.topLeft,
                      child: Text('Selecciona una materia para ver su estado.', style: TextStyle(fontSize: 16, color: Colors.white)),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Detalle de la materia:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text('Nombre: ${materiaSeleccionada!.nombre}', style: const TextStyle(fontSize: 16, color: Colors.white)),
                        Text('Código: ${materiaSeleccionada!.codigo}', style: const TextStyle(fontSize: 16, color: Colors.white)),
                        Text('Estado: ${materiaSeleccionada!.estado}', style: const TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
