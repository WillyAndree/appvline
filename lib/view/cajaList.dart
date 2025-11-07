import 'dart:convert';

import 'package:appvline/view/ventasList.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:appvline/constants.dart';

class CashboxScreen extends StatefulWidget {
  @override
  _CashboxScreenState createState() => _CashboxScreenState();
}

class _CashboxScreenState extends State<CashboxScreen> {
   Map<String, double> payments = {};

  Future<void> fetchCaja(String fecha, String sucursal) async {
    try {
      String codigo_sucur = "";
      if(sucursal == "14"){
        codigo_sucur = "2";
      }else{
        codigo_sucur = sucursal;
      }
      final response = await http.post(Uri.parse("$url_base/caja.montos.listar.php"), body: {
        "fecha":fecha, "sucursal":codigo_sucur
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var paymentJson = rptaJson["datos"] ?? [];
        if ( paymentJson.isEmpty) {
          setState((){
            payments.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron productos.')),
          );
          return;
        }else{
          setState((){
            payments.clear();
          });


          for(int i = 0; i <paymentJson.length; i++){
            setState(() {
              payments = {
                "Caja inicial": double.parse(paymentJson[i]["monto_inicial"]),
                "Efectivo": double.parse(paymentJson[i]["ventas_efectivo"]),
                "Tarjeta": double.parse(paymentJson[i]["ventas_tarjeta"]),
                "Credito": double.parse(paymentJson[i]["credito"]),
                "Anuladas": double.parse(paymentJson[i]["ventas_anuladas"]),
               // "Plin": 0.00,
               // "Transferencia": 0.00,

                "Ingresos": double.parse(paymentJson[i]["ingresos"]),
                "Egresos": double.parse(paymentJson[i]["egresos"]),
                "Efectivo en caja": double.parse(paymentJson[i]["efectivo_caja"]),
              };
            });
          }
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener productos.')),
        );
        // return [];
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      // return [];
    }
  }

  final List<Color> colors = [
    Colors.blueGrey,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.red,
    Colors.blueAccent,
  //  Colors.red
  ];

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      DateTime actual = DateTime.now();

      fetchCaja("${actual.year}-${actual.month}-${actual.day}",idsucursal! );
    });
  }

   Future<void> mostrarDialogoConfirmacionArqueo(BuildContext context, String monto_inicial,String monto) async {
     return showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('Confirmación'),
         content: Text('¿Desea arquear la caja con S/. $monto?'),
         actions: [
           TextButton(
             onPressed: () {
               Navigator.of(context).pop(); // Cierra el diálogo
             },
             child: Text('Cancelar'),
           ),
           ElevatedButton(
             onPressed: () async{
               await arquearCaja(monto_inicial, monto, idusuario!,idsucursal!);
               Navigator.of(context).pop(); // Cierra el diálogo
                // Ejecuta la acción de arqueo
             },
             child: Text('Arquear'),
           ),
         ],
       ),
     );
   }
   Future<void> arquearCaja(String montoinicial,String montofinal,String usuario, String sucursal) async {
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
               Text('Arqueando caja...'),
             ],
           ),
         );
       },
     );
     try {
       final response = await http.post(Uri.parse("$url_base/caja.arquear.php"), body: {
         "monto_inicial":montoinicial,"monto_final":montofinal, "usuario":usuario,"sucursal":sucursal, "fecha":"${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"
       });

       if (response.statusCode == 200) {
         final Map<String, dynamic> rptaJson = json.decode(response.body);
         var rptJson = rptaJson["datos"] ?? [];

         await fetchCaja("${selectedDate.year}-${selectedDate.month}-${selectedDate.day}", sucursal);
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Carja arqueada correctamente.')),
         );
       } else {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Error al arquear caja.')),
         );
       }
     } catch (e) {

       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error: $e')),
       );
       // return [];
     }
     Navigator.pop(context);
   }

   Future<void> registerIngresos(String monto,String detalle, String sucursal) async {
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
               Text('Registrando ingreso...'),
             ],
           ),
         );
       },
     );
     try {
       final response = await http.post(Uri.parse("$url_base/ingreso.agregar.php"), body: {
         "monto":monto,"detalle":detalle, "sucursal":sucursal, "fecha":"${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"
       });

       if (response.statusCode == 200) {
         final Map<String, dynamic> rptaJson = json.decode(response.body);
         var rptJson = rptaJson["datos"] ?? [];
          await fetchCaja("${selectedDate.year}-${selectedDate.month}-${selectedDate.day}", sucursal);
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Ingreso creado correctamente.')),
         );
       } else {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Error al crear ingreso.')),
         );
       }
     } catch (e) {

       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error: $e')),
       );
       // return [];
     }
     Navigator.pop(context);
   }

   Future<void> registerEgresos(String monto,String detalle, String sucursal) async {
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
               Text('Registrando egreso...'),
             ],
           ),
         );
       },
     );
     try {
       final response = await http.post(Uri.parse("$url_base/egreso.agregar.php"), body: {
         "monto":monto,"detalle":detalle, "sucursal":sucursal, "fecha":"${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"
       });

       if (response.statusCode == 200) {
         final Map<String, dynamic> rptaJson = json.decode(response.body);
         var rptJson = rptaJson["datos"] ?? [];
         await fetchCaja("${selectedDate.year}-${selectedDate.month}-${selectedDate.day}", sucursal);
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Egreso creado correctamente.')),
         );
       } else {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Error al crear egreso.')),
         );
       }
     } catch (e) {

       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error: $e')),
       );
       // return [];
     }
     Navigator.pop(context);
   }
   void mostrarDialogoMotivoMonto(BuildContext context, String method) {
     final TextEditingController motivoController = TextEditingController();
     final TextEditingController montoController = TextEditingController();

     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('Ingrese datos'),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             TextField(
               controller: motivoController,
               decoration: InputDecoration(labelText: 'Motivo'),
             ),
             TextField(
               controller: montoController,
               keyboardType: TextInputType.number,
               decoration: InputDecoration(labelText: 'Monto'),
             ),
           ],
         ),
         actions: [
           TextButton(
             onPressed: () {
               Navigator.pop(context); // Cierra el diálogo
             },
             child: Text('Cancelar'),
           ),
           ElevatedButton(
             onPressed: () {
               String motivo = motivoController.text.trim();
               String monto = montoController.text.trim();

               if(method == "Ingresos"){
                 registerIngresos(monto, motivo, idsucursal!);
               }else{
                 registerEgresos(monto, motivo, idsucursal!);
               }

               // Aquí puedes hacer lo que necesites con los valores
               print('Motivo: $motivo');
               print('Monto: $monto');

               Navigator.pop(context); // Cierra el diálogo
             },
             child: Text('Aceptar'),
           ),
         ],
       ),
     );
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(onPressed: (){
              double? cajaInicial = payments["Caja inicial"];
              double? cajafinal = payments["Efectivo en caja"];
              mostrarDialogoConfirmacionArqueo(context,cajaInicial.toString(),cajafinal.toString());
            }, icon: Icon(Icons.card_membership_sharp))
          ],
          title: Text("Caja")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: azulvline,
        onPressed: () {
           Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SalesListScreen()),
          );
        },
        child: Icon(Icons.list, color: Colors.white,),
      ),
      body: SingleChildScrollView( child:
      Container(
        width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height *0.9,
          child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: ListTile(
              title: Text("Seleccionar Fecha: ${DateFormat('dd/MM/yyyy').format(selectedDate)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                  await fetchCaja("${selectedDate.year}-${selectedDate.month}-${selectedDate.day}", idsucursal! );
                }
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top:10, left: 10, right: 10),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  String method = payments.keys.elementAt(index);
                  double amount = payments.values.elementAt(index);
                  return Card(
                    color: colors[index % colors.length],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: GestureDetector(
                        onTap: (){
                          if(method == "Ingresos" || method == "Egresos"){
                            mostrarDialogoMotivoMonto(context, method);
                          }
                        },
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            method,
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "S/ ${amount.toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      )),
                    ),
                  );
                },
              ),
            ),
          ),
          /*ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[300]),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Arquear Caja", style: TextStyle(color: Colors.white),),
          ),*/
        ],
      ))),
    );
  }
}
