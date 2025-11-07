import 'package:appvline/constants.dart';
import 'package:appvline/view/loginpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  List menu  = [{
    "ICONO":"truck.png",
    "DESCRIPCION":"GENERAR VIAJE",
    "VIEW":"tracking"
  },
    {
      "ICONO":"mapa.png",
      "DESCRIPCION":"SEGUIMIENTO TRANSPORTE",
      "VIEW":"mapa-cliente"
    },
    {
      "ICONO":"bienes.png",
      "DESCRIPCION":"VENTAS",
      "VIEW":"productList"
    },
    {
      "ICONO":"cajero-automatico.png",
      "DESCRIPCION":"CAJA",
      "VIEW":"caja"
    },
    {
      "ICONO":"solicitud-de-cotizacion.png",
      "DESCRIPCION":"COTIZACIÓN",
      "VIEW":"cotizacion"
    },
    {
      "ICONO":"cuentas-por-pagar.png",
      "DESCRIPCION":"CUENTAS POR COBRAR",
      "VIEW":"cobros"
    },
    {
      "ICONO":"diario.png",
      "DESCRIPCION":"RECORDATORIO",
      "VIEW":"recordatorio"
    },
    {
      "ICONO":"24-horas.png",
      "DESCRIPCION":"MARCACIÓN ASISTENCIA",
      "VIEW":"asistencia"
    }];


  String idusuarioActual ="";
  String idempresaActual = "";
  String nombresActual = "";
  String tipoUsuarioActual = "";
  String dniUsuarioActual = "";


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      child: Scaffold(

        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.perm_contact_cal,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => const CustomDialogsLogout(
                    title: "Sesión",
                    description: "¿Deseas Cerrar Sesión?",
                    imagen: "assets/images/cerrar-sesion.png",
                  ));
            },
          ),

          backgroundColor: azulvline,
          title:  const Text("CASA DEL VIDRIERO",style: TextStyle(color: Colors.white),),

        ),
        body: SingleChildScrollView(
            child: SizedBox(

                width: size.width,
                height: size.height*0.85,
                //margin: const EdgeInsets.only(top: 25),
                child: Column(children: [

                  Expanded(child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    itemCount: menu.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () async {
                            Navigator.pushNamed(context,  menu[index]["VIEW"]);
                           // _handleOnTap(context,  menu[index]["DESCRIPCION"], size,  menu[index]["VIEW"]);

                          },
                          child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  //border: Border.all(color: kPrimaryColor, width: 4),
                                  borderRadius:  BorderRadius.all(Radius.circular(15)),
                                  boxShadow:  [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5.0,
                                      offset: Offset(0.0, 5.0),
                                    )
                                  ]),
                              height: size.height * 0.2,
                              margin: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: size.height * 0.10,
                                    child: Image.asset("assets/images/${menu[index]["ICONO"]}"),
                                  ),
                                  const SizedBox(height: 5,),
                                  Container(
                                    alignment: Alignment.center,
                                    width: size.width * 0.35,
                                    child: Text(
                                      menu[index]["DESCRIPCION"],
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              )));
                    },
                  ),)
                ],)
            )),
        bottomNavigationBar: Container(
          color: Colors.blueGrey,
          alignment: Alignment.center,
          width: size.width,
          height: size.height*0.06,
          child:   Text(nombresActual, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),),
      ),
      onWillPop: () async => false,
    );
  }
}

class CustomDialogsLogout extends StatelessWidget {
  final String? title, description, buttontext, imagen, nombre;
  final Image? image;

  const CustomDialogsLogout({Key? key, this.title, this.description, this.buttontext, this.image, this.imagen, this.nombre})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      backgroundColor: Colors.white,
      child: dialogContents(context),
    );
  }

  dialogContents(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(bottom: 20, left: 20),
          margin: const EdgeInsets.only(top: 20),
          decoration:
          BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(15), boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            )
          ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                imagen!,
                width: 64,
                height: 64,
              ),
              const SizedBox(height: 20.0),
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Divider(),
              const SizedBox(height: 10.0),
              Text(
                description!,
                style: const TextStyle(fontSize: 16.0),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24.0),
              Row(
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              offset: Offset(0.0, 10.0),
                            )
                          ]),
                      child: MaterialButton(
                        //color: kArandano,
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop('dialog');
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  LoginPage()));
                          },
                          child: const Text(
                            "Cerrar Sesión",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      decoration: BoxDecoration(
                          color: kAccentColor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              offset: Offset(0.0, 10.0),
                            )
                          ]),
                      child: MaterialButton(
                        //color: kArandano,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}