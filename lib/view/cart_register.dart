
import 'dart:convert';

import 'package:appvline/model/util/numeroLetras.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:appvline/constants.dart';
import 'package:appvline/view/productList.dart';

class CartRegister extends StatefulWidget{
  List? productos;

   CartRegister({super.key, this.productos});
  @override
  _CartRegisterScreenState createState() => _CartRegisterScreenState();

}
class _CartRegisterScreenState extends State<CartRegister>{

  String codigo_cliente ="0";
  String dni_seleccionado ="";
  String cliente_seleccionado ="";
  Future<String> fetchClientes(String dni) async {
    try {
      final response = await http.post(Uri.parse("$url_base/cliente.listar.datos.dni.app.php"), body: {
        "dni":dni
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var clientesJson = rptaJson["datos"] ?? [];
        if ( clientesJson.isEmpty) {
          setState((){
            codigo_cliente = "0";
          });

            String rpta = "";

            if(dni.length == 8){
              await fetchClienteReniec(dni);
            }else{
              await fetchClienteSunat(dni);
            }

            return rpta;

        }else{
          setState((){
            codigo_cliente = clientesJson[0]["codigo"];
            dni_seleccionado = clientesJson[0]["nro_documento_identidad"];
            cliente_seleccionado = clientesJson[0]["nombres"];
          });
            return clientesJson[0]["nombres"];
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener cliente.')),
        );
        return "";
        // return [];
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return "";
      // return [];
    }
  }

  Future<String> fetchClienteReniec(String dni) async {
    try {
      final response = await http.post(Uri.parse("$url_base/consulta_reniecc.php"), body: {
        "dni":dni
      });

      if (response.statusCode == 200) {
        var rptaJson = json.decode(response.body);
        //var clientesJson = rptaJson["datos"] ?? [];
        if ( rptaJson.isEmpty || rptaJson[1] == null) {
          setState((){
            codigo_cliente = "0";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró cliente. Revise el DNI')),
          );
          return "";
        }else{
          setState((){
            codigo_cliente = "0";
            dni_seleccionado = dni;
            cliente_seleccionado = rptaJson[1]+rptaJson[2]+rptaJson[3];
          });
            return rptaJson[1]+rptaJson[2]+rptaJson[3];
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener cliente.')),
        );
        return "";
        // return [];
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
       return "";
    }
  }


  Future<String> fetchClienteSunat(String dni) async {
    try {
      final response = await http.post(Uri.parse("$url_base/consulta_sunat.php"), body: {
        "dni":dni
      });

      if (response.statusCode == 200) {
        var rptaJson = json.decode(response.body);
        //var clientesJson = rptaJson["datos"] ?? [];
        if ( rptaJson.isEmpty || rptaJson[1] == null) {
          setState((){
            codigo_cliente = "0";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró cliente. Revise el RUC')),
          );
          return "";
        }else{
          setState((){
            codigo_cliente = "0";
            dni_seleccionado = dni;
            cliente_seleccionado = rptaJson[1]+rptaJson[2]+rptaJson[3];
          });
          return rptaJson[1]+rptaJson[2]+rptaJson[3];
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener cliente.')),
        );
        return "";
        // return [];
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return "";
    }
  }

  double calcularTotal(List lista) {
    return lista.fold(
        0,
            (suma, item) =>
        suma + (int.parse(item['cantidad']) * (double.parse(item['precio']))));
  }

  Future<void> registerCotizacion(String codtipopago, String total, String codtipodoc) async {
    DateTime now = DateTime.now();
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
              Text('Registrando cotización...'),
            ],
          ),
        );
      },
    );
    try {

      double total_venta = 0;
      for(int i = 0; i< widget.productos!.length; i++ ){
        total_venta = total_venta + double.parse(widget.productos![i]["subtotal"]);
      }
      NumeroALetras.convertir(total_venta);
      //print("DATO: "+NumeroALetras.convertir(total_venta));

      final response = await http.post(Uri.parse("$url_base/venta.agregar.app.php"), body: {
        "txtfecha":DateFormat('yyyy-MM-dd').format(now), "txtserie":"001","txtdocumento":"1", "txtsucursal":idsucursal! , "txtusuario":idusuario,
        "cbotipodoc":codtipodoc, "cbotipoventa":"Contado", "txtcodigocliente":codigo_cliente, "txtdni":dni_seleccionado, "txtnombres":cliente_seleccionado, "txtdireccion":"-", "txtletras":NumeroALetras.convertir(total_venta).toString().toUpperCase(),
        "cbotventa": "E","codtipopago":codtipopago,"product": widget.productos!.map((e) => e["idproducto"]).join(","),
        "medida": widget.productos!.map((e) => e["medida"]).join(","),
        "sucursal": widget.productos!.map((e) => e["sucursal"]).join(","),
        "cantidad": widget.productos!.map((e) => e["cantidad"]).join(","),
        "precio": widget.productos!.map((e) => e["precio"]).join(","),
        "subtotal": widget.productos!.map((e) => e["subtotal"]).join(","),
        "ganancia": widget.productos!.map((e) => e["ganancia"]).join(","),
        "detalle": widget.productos!.map((e) => e["detalle"]).join(",")
      });

      if (response.statusCode == 200) {
        var rptaJson = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cotización registrada correctamente.')),
        );
        Navigator.pop(context,"true");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar cotización.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),

      );
      // return [];
    }
    Navigator.pop(context);
  }

  Future<void> registerVentas(String codtipopago, String total, String codtipodoc) async {
    DateTime now = DateTime.now();
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
              Text('Registrando venta...'),
            ],
          ),
        );
      },
    );
    try {

      double total_venta = 0;
      for(int i = 0; i< widget.productos!.length; i++ ){
        total_venta = total_venta + double.parse(widget.productos![i]["subtotal"]);
      }
      NumeroALetras.convertir(total_venta);

      String codigo_sucur = "";
      if(idsucursal == "14"){
        codigo_sucur = "2";
      }else{
        codigo_sucur = idsucursal!;
      }
      //print("DATO: "+NumeroALetras.convertir(total_venta));
      final response = await http.post(Uri.parse("$url_base/venta.agregar.app.php"), body: {
        "txtfecha":DateFormat('yyyy-MM-dd').format(now), "txtserie":"001","txtdocumento":"1", "txtsucursal": codigo_sucur, "txtusuario":idusuario,
        "cbotipodoc":codtipodoc, "cbotipoventa":"Contado", "txtcodigocliente":codigo_cliente, "txtdni":dni_seleccionado, "txtnombres":cliente_seleccionado, "txtdireccion":"-", "txtletras":NumeroALetras.convertir(total_venta).toString().toUpperCase(),
        "cbotventa": "E","codtipopago":codtipopago,"product": widget.productos!.map((e) => e["idproducto"]).join(","),
        "medida": widget.productos!.map((e) => e["medida"]).join(","),
        "sucursal": widget.productos!.map((e) => e["sucursal"]).join(","),
        "cantidad": widget.productos!.map((e) => e["cantidad"]).join(","),
        "precio": widget.productos!.map((e) => e["precio"]).join(","),
        "subtotal": widget.productos!.map((e) => e["subtotal"]).join(","),
        "ganancia": widget.productos!.map((e) => e["ganancia"]).join(","),
        "detalle": widget.productos!.map((e) => e["detalle"]).join(",")
      });

      if (response.statusCode == 200) {
        var rptaJson = json.decode(response.body);
        await atenderVentas(rptaJson["datos"], codtipodoc,idsucursal!,codigo_cliente,cliente_seleccionado, "-",dni_seleccionado, codtipopago, DateFormat('yyyy-MM-dd').format(now), total);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta registrada correctamente.')),
        );
        Navigator.pop(context,"true");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar venta.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),

      );
      // return [];
    }
    Navigator.pop(context);
  }

  Future<void> atenderVentas(String nro_venta,String tipo,String sucursal,String codigo_cliente, String nombres, String direccion,String dni, String cod_tipopago, String fecha, String total) async {

    try {

      final response = await http.post(Uri.parse("$url_base/venta.atender.app.php"), body: {
        "nro_venta":nro_venta, "tipo":tipo, "sucursal":sucursal, "codigo":codigo_cliente, "nombres":nombres, "direccion":direccion, "dni":dni, "cod_tipopago":cod_tipopago, "fecha":fecha, "total":total
      });

      if (response.statusCode == 200) {
        // var rptaJson = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago registrada correctamente.')),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar pago.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),

      );
      // return [];
    }

  }

  Future<Map<String, String>?> _mostrarDialogoAgregarProducto(BuildContext context, String precio, String cantidad, String comentario) {
    TextEditingController cantidadController = TextEditingController();
    TextEditingController precioController = TextEditingController();
    TextEditingController comentarioController = TextEditingController();

    precioController.text = precio;
    cantidadController.text = cantidad;
    comentarioController.text = comentario;

    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar datos de venta"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: cantidadController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Cantidad"),
                ),
                TextField(
                  controller: precioController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Precio"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: comentarioController,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: "Comentario"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancelar, retorna null
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  "cantidad": cantidadController.text,
                  "comentario": comentarioController.text,
                  "precio": precioController.text,
                }); // Retorna un Map<String, String>
              },
              child: Text("Editar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> mostrarTipoPago(BuildContext context, String total_venta){
    return showDialog(
      context: context,
      builder: (context) {
        String selectedPaymentMethod = "Efectivo";
        String selectedDocMethod = "Boleta Simple";
        TextEditingController amountController = TextEditingController();
        TextEditingController clientController = TextEditingController();
        String cod_tipodoc = "5";
        String cod_tipopago = "1";
        TextEditingController dniController = TextEditingController();
        amountController.text =  total_venta;
        return AlertDialog(
          title: Text("Registrar Venta"),
          content: SingleChildScrollView(
              child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedPaymentMethod,
                        onChanged: (value) {
                          selectedPaymentMethod = value!;
                          if(value == "Efectivo"){
                            cod_tipopago = "1";
                          }else if(value == "Tarjeta"){
                            cod_tipopago = "2";
                          }else if(value == "Deposito"){
                            cod_tipopago = "3";
                          }else if(value == "Nota de Credito"){
                            cod_tipopago = "4";
                         /* }else if(value == "PLIM"){
                            cod_tipopago = "5";*/
                          }
                        },
                        items: ["Efectivo", "Tarjeta", "Deposito", "Nota de Credito"].map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        decoration: InputDecoration(labelText: "Método de Pago"),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width*0.8,
                        child:
                        Row(children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width*0.3,
                            child: TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: "Total"),
                              onChanged: (val){

                              },
                            ),),

                        ],),),


                      DropdownButtonFormField<String>(
                        value: selectedDocMethod,
                        onChanged: (value) {
                          selectedDocMethod = value!;
                          if(value == "Boleta Simple"){
                            cod_tipodoc = "5";
                          }else if(value == "Boleta"){
                            cod_tipodoc = "2";
                          }else if(value == "Cotización"){
                            cod_tipodoc = "4";
                          }else{
                            cod_tipodoc = "1";
                          }
                        },
                        items: ["Boleta Simple", "Boleta", "Factura", "Cotización"].map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        decoration: InputDecoration(labelText: "Tipo de Documento"),
                      ),
                      TextField(
                        controller: dniController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "DNI/RUC"),
                        onChanged: (val) async{
                          if(cod_tipodoc != "1" && cod_tipodoc != "4"){
                            if(val.length == 8 ){
                              dni_seleccionado = val;
                              String rpta = await fetchClientes(val);
                              clientController.text = rpta;
                            }
                          }else if( cod_tipodoc == "4"){
                            if(val.length == 11 ){
                              dni_seleccionado = val;
                              String rpta = await fetchClientes(val);
                              clientController.text = rpta;
                            }
                          }else{
                            if(val.length == 11){
                              dni_seleccionado = val;
                              String rpta = await fetchClientes(val);
                              clientController.text = rpta;
                            }
                          }


                        },
                      ),
                      TextField(
                        controller: clientController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(labelText: "Cliente"),
                        onChanged: (val){
                          setState(() {
                            cliente_seleccionado = val;
                          });
                        },
                      ),
                    ],
                  ))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () async{
                if(cod_tipodoc == "4"){
                  await registerCotizacion(cod_tipopago, total_venta, cod_tipodoc);
                }else{
                  await registerVentas(cod_tipopago, total_venta, cod_tipodoc);
                }

                Navigator.pop(context,"true");
              },
              child: Text("Confirmar", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulvline,
        foregroundColor: Colors.white,
        title: Text("Carrito de compras"),
      actions: [
        IconButton(onPressed: (){
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductListScreen(products_cart: widget.productos!,)),
          );
        }, icon: Icon(Icons.add_box))
      ],),
        body: Container(
          width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height*0.88,
      child: widget.productos!.isEmpty
          ? const Center(child: Text("No hay productos seleccionados."))
          : Column( children: [
            Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height*0.75,
                child: ListView.builder(
        itemCount: widget.productos!.length,
        itemBuilder: (context, index) {
          final producto = widget.productos![index];
          return GestureDetector(
            onTap: () async{
              //_mostrarDialogoAgregarProducto(context,producto["precio"],producto["cantidad"],producto["detalle"]);
              final resultado = await _mostrarDialogoAgregarProducto(
                  context,
                  producto["precio"],
                  producto["cantidad"],
                  producto["detalle"]
              );

              if (resultado != null) {
                setState(() {
                  double subtotal = double.parse(resultado["precio"].toString()) * double.parse(resultado["cantidad"].toString());
                  // Actualiza solo el item seleccionado (por índice)
                  widget.productos![index]["precio"] = resultado["precio"];
                  widget.productos![index]["cantidad"] = resultado["cantidad"];
                  widget.productos![index]["detalle"] = resultado["comentario"]; // si "detalle" es igual a "comentario"
                  widget.productos![index]["subtotal"] = subtotal.toString();
                });
              }
            },
              child: ListTile(
            title: Text(producto["nombres"]),
            subtitle: Text(
                "Cantidad: ${producto["cantidad"]}  -  Precio: S/. ${producto["precio"]}"),
          ));
        },
      )),
      Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
          ElevatedButton(
            onPressed: () {
              mostrarTipoPago(context,calcularTotal(widget.productos!).toString());
              //Navigator.pop(context); // Retorna la lista
            },
            child: const Text("Realizar venta"),
          ),
        ],),
      )
    ]),
    ));
  }

}



