// Ignora una advertencia sobre el uso de clases privadas en bibliotecas públicas.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:materias_app/controller/register_controller';




// Configuración del borde para los campos de texto en el formulario.
const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF3EA2F3)), 
  borderRadius: BorderRadius.all(Radius.circular(100)), 
);



//  Pantalla principal para el registro de usuarios.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(




      // Imagen de fondo 
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/registerbackground.jpg',
              fit: BoxFit.cover, 
            ),
          ),
          SafeArea(
            child: Center(
              child: SizedBox.expand(
                child: const SignUpForm(), 
              ),
            ),
          ),
        ],
      ),




      //  Configuración de la barra superior de navegación.
      appBar: AppBar(
        backgroundColor: Colors.lightBlue, 
        title: const Text("Sign Up", style: TextStyle(color: Colors.white)), 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }
}

//  Widget del formulario de registro.
class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpFormState createState() => _SignUpFormState();
}



class _SignUpFormState extends State<SignUpForm> {


  //  Creación de controladores para los campos de entrada.
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false; 


  @override
  void dispose() {
    // limpia los controladores 
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  //  Método para manejar el registro de usuario.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // Validación de los campos.

    setState(() => _isLoading = true); 

    // Llama a la función `register()` 
    final result = await register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    setState(() => _isLoading = false); 



    //  Verifica si el registro fue exitoso y obtiene el mensaje de respuesta.
    final bool isSuccessful = result['success'] == true;
    final String message = result['message'] ??
        (isSuccessful ? 'User registered successfully' : 'Error registering user');

    if (!mounted) return;

    // Muestra un mensaje en la pantalla con el resultado del registro.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccessful ? Colors.green : Colors.red, 
      ),
    );


    //  Si el registro fue exitoso, limpia los campos del formulario.
    if (isSuccessful) {
      _formKey.currentState!.reset();
      _nameCtrl.clear();
      _emailCtrl.clear();
      _passCtrl.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),



              // Título de la pantalla 
              const Text(
                "Register Account",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 26, 255),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),


              //  Campo de entrada para el nombre.
              _buildField(
                _nameCtrl,
                "Nombre",
                userIcon,
                (v) {
                  if (v == null || v.isEmpty) return 'Por favor ingresa tu nombre';
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) return 'El nombre solo puede contener letras y espacios';
                  return null;
                },
              ),
              const SizedBox(height: 16),


              //  Campo de entrada para el email.
              _buildField(
                _emailCtrl,
                "Email",
                mailIcon,
                (v) {
                  if (v == null || v.isEmpty) return 'Please enter your email';
                  if (!v.contains('@')) return 'Invalid email';
                  if (!RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$').hasMatch(v)) return 'Formato de correo inválido (Ejemplo: nombre@email.com)';
                  return null;
                },
                keyboard: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),


              //  Campo de entrada para la contraseña.
              _buildField(
                _passCtrl,
                "Password",
                lockIcon,
                (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                obscure: true,
              ),
              const SizedBox(height: 32),



              //  Botón de envío.
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit, 
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color.fromARGB(255, 0, 25, 248),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),


                  //  Muestra una animación de carga mientras se envía el formulario.
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Continue"),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  // Método para construir un campo de entrada de texto.
  Widget _buildField(
    TextEditingController ctrl,
    String label,
    String svgIcon,
    String? Function(String?) validator, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboard,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: "Enter your $label",
        labelText: label,
        labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 126, 243)), 
        hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 126, 243)), 
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: SvgPicture.string(
            svgIcon,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              Color(0xFF3EA2F3),
              BlendMode.srcIn,
            ),
          ),
        ),
        border: authOutlineInputBorder,
        enabledBorder: authOutlineInputBorder,
        focusedBorder: authOutlineInputBorder,
      ),
      validator: validator,
    );
  }
}

// Icons
const mailIcon =
    '''<svg width="18" height="13" viewBox="0 0 18 13" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M15.3576 3.39368C15.5215 3.62375 15.4697 3.94447 15.2404 4.10954L9.80876 8.03862C9.57272 8.21053 9.29421 8.29605 9.01656 8.29605C8.7406 8.29605 8.4638 8.21138 8.22775 8.04204L2.76041 4.11039C2.53201 3.94618 2.47851 3.62546 2.64154 3.39454C2.80542 3.16362 3.12383 3.10974 3.35223 3.27566L8.81872 7.20645C8.93674 7.29112 9.09552 7.29197 9.2144 7.20559L14.6469 3.27651C14.8753 3.10974 15.1937 3.16447 15.3576 3.39368ZM16.9819 10.7763C16.9819 11.4366 16.4479 11.9745 15.7932 11.9745H2.20765C1.55215 11.9745 1.01892 11.4366 1.01892 10.7763V2.22368C1.01892 1.56342 1.55215 1.02632 2.20765 1.02632H15.7932C16.4479 1.02632 16.9819 1.56342 16.9819 2.22368V10.7763ZM15.7932 0H2.20765C0.990047 0 0 0.998092 0 2.22368V10.7763C0 12.0028 0.990047 13 2.20765 13H15.7932C17.01 13 18 12.0028 18 10.7763V2.22368C18 0.998092 17.01 0 15.7932 0Z" fill="#757575"/>
</svg>''';

const lockIcon =
    '''<svg width="15" height="18" viewBox="0 0 15 18" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M9.24419 11.5472C9.24419 12.4845 8.46279 13.2453 7.5 13.2453C6.53721 13.2453 5.75581 12.4845 5.75581 11.5472C5.75581 10.6098 6.53721 9.84906 7.5 9.84906C8.46279 9.84906 9.24419 10.6098 9.24419 11.5472ZM13.9535 14.0943C13.9535 15.6863 12.6235 16.9811 10.9884 16.9811H4.01163C2.37645 16.9811 1.04651 15.6863 1.04651 14.0943V9C1.04651 7.40802 2.37645 6.11321 4.01163 6.11321H10.9884C12.6235 6.11321 13.9535 7.40802 13.9535 9V14.0943ZM4.53488 3.90566C4.53488 2.31368 5.86483 1.01887 7.5 1.01887C8.28488 1.01887 9.03139 1.31943 9.59477 1.86028C10.1564 2.41387 10.4651 3.14066 10.4651 3.90566V5.09434H4.53488V3.90566ZM11.5116 5.12745V3.90566C11.5116 2.87151 11.0956 1.89085 10.3352 1.14028C9.5686 0.405 8.56221 0 7.5 0C5.2875 0 3.48837 1.7516 3.48837 3.90566V5.12745C1.52267 5.37792 0 7.01915 0 9V14.0943C0 16.2484 1.79913 18 4.01163 18H10.9884C13.2 18 15 16.2484 15 14.0943V9C15 7.01915 13.4773 5.37792 11.5116 5.12745Z" fill="#757575"/>
</svg>''';


const userIcon = '''<svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12 12C14.7614 12 17 9.76142 17 7C17 4.23858 14.7614 2 12 2C9.23858 2 7 4.23858 7 7C7 9.76142 9.23858 12 12 12Z" fill="#757575"/>
<path d="M4 20C4 16.6863 7.58172 14 12 14C16.4183 14 20 16.6863 20 20H4Z" fill="#3EA2F3"/>
</svg>''';

