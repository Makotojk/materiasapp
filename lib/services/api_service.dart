import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:materias_app/models/materia.dart'; // Ajusta la ruta según tu proyecto

class ApiService {
  static Future<List<Materia>> fetchMaterias(String token) async {
    final url = Uri.parse('https://app-iv-ii-main-td0mcu.laravel.cloud/api/materias');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List<dynamic> materiasJson = decoded['materias'];
      return materiasJson.map((json) => Materia.fromJson(json)).toList();
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
