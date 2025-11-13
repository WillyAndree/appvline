
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:appvline/constants.dart';
import 'package:appvline/view/principal_page.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _dniController = TextEditingController();
  final subdominioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  //final Telephony telephony = Telephony.instance;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }


  @override
  void dispose() {
    _dniController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }


  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PrincipalPage(
          ),
        ),
      );
    }
  }

  Future<List?> fetchAndStoreUsers(BuildContext context, String login, String clave, String subdominio_local) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando usuarios...'),
            ],
          ),
        );
      },
    );

    List users = [];

    try {
      final response = await http.post(Uri.parse("https://$subdominio_local.vlinesys.com/app/controlador/sesion.iniciar.app.controlador.php"),body:{
        "txtusuario":login, "txtclave":clave
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body) ;
        var userssJson = rptaJson["datos"] ?? [];

        if ( userssJson.isEmpty) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron usuarios en la API.')),
          );

          return [];
        }


        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sesión iniciada correctamente. ')),

        );

        users.add(userssJson);
        return users;
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener usuarios desde la API.')),
        );
        return [];
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return [];
    }
  }

  Future<void> loginSearch(String login, String password, String subdominio_local) async {
    final datos = await fetchAndStoreUsers(context,login, password, subdominio_local);

    if (datos!.isNotEmpty) { // Validamos si se encontró el usuario
      setState(() {
        idusuario = datos[0]["codigo"].toString();
        idsucursal = datos[0]["codigo_sucursal"].toString();
        nombreUsuario = datos[0]["nombre"].toString();
        foto_const = datos[0]["foto"].toString();
        subdominio = subdominio_local;
      });

      _login();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales Incorrectas. Revísalas y vuelve a intentar')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF081323),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: Colors.white,
            child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Card(
              color: Color(0xFF081323),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  Container(
                        width: MediaQuery.sizeOf(context).width*0.5,
                    height: MediaQuery.sizeOf(context).height*0.2,
                          decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                            "assets/images/vyru.png",
                          ),
                            fit: BoxFit.fill),
                      ),),
                      Text('Inicio de Sesión',
                          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.8,
                        child: Row(children: [

                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.sizeOf(context).width * 0.4,
                            height: MediaQuery.sizeOf(context).height * 0.06,
                            child: TextFormField(
                              controller: subdominioController,
                              keyboardType: TextInputType.text,
                              //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: TextStyle(color: Colors.white),
                              decoration:  InputDecoration(labelText: 'Dominio empresa', labelStyle: const TextStyle(color: Colors.white54), enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(color: Colors.white, width: 2.0), // Ajusta el ancho si es necesario
                              ),
                                // También es buena práctica definir el borde para el estado enfocado (cuando el usuario hace clic)
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                ),
                                // Si no usas enabledBorder/focusedBorder, usa 'border' como fallback
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El DOMINIO es requerido.';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                           Container(
                             alignment: Alignment.center,
                            width: MediaQuery.sizeOf(context).width * 0.3,
                            height: MediaQuery.sizeOf(context).height * 0.06,
                            child: const Text('vyrutech.com',
                                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],),
                      ),

                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.8,
                        height: MediaQuery.sizeOf(context).height * 0.06,
                        child: TextFormField(
                          controller: _dniController,
                          keyboardType: TextInputType.text,
                          style: TextStyle(color: Colors.white),
                          //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration:  InputDecoration(labelText: 'Usuario', labelStyle: const TextStyle(color: Colors.white54), enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Colors.white, width: 2.0), // Ajusta el ancho si es necesario
                          ),
                            // También es buena práctica definir el borde para el estado enfocado (cuando el usuario hace clic)
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.white, width: 2.0),
                            ),
                            // Si no usas enabledBorder/focusedBorder, usa 'border' como fallback
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.white),
                            ),),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El USUARIO es requerido.';
                            }
                            /*if (value.length != 8) {
                              return 'El DNI debe tener exactamente 8 dígitos.';
                            }*/
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 20),

                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.8,
                        height: MediaQuery.sizeOf(context).height * 0.06,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(labelText: 'Contraseña', labelStyle: const TextStyle(color: Colors.white54), enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Colors.white, width: 2.0), // Ajusta el ancho si es necesario
                          ),
                            // También es buena práctica definir el borde para el estado enfocado (cuando el usuario hace clic)
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.white, width: 2.0),
                            ),
                            // Si no usas enabledBorder/focusedBorder, usa 'border' como fallback
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.white),
                            ),),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La contraseña es requerida.';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed:() async{
                          await loginSearch(_dniController.text, _passwordController.text, subdominioController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          backgroundColor: azulvline,
                        ),
                        child: Text('Ingresar', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }
}
