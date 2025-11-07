import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:appvline/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SalesListScreen extends StatefulWidget {
  @override
  _SalesListScreenState createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {


  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> sales_detail = [];

  String searchQuery = "";
  DateTime? selectedDate;

  Future<void> fetchVentas(String nombres,String fecha, String sucursal) async {
    try {
      String codigo_sucur = "";
      if(sucursal == "14"){
        codigo_sucur = "2";
      }else{
        codigo_sucur = sucursal;
      }

      final response = await http.post(Uri.parse("$url_base/venta.listar.php"), body: {
        "nombres":nombres,"fecha":fecha, "sucursal":codigo_sucur
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var sellJson = rptaJson["datos"] ?? [];
        if ( sellJson.isEmpty) {
          setState((){
            sales.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron ventas.')),
          );
          return;
        }else{
          setState((){
            sales.clear();
          });


          for(int i = 0; i <sellJson.length; i++){
            List<Map<String, dynamic>> productos = [];
            print("Detalle crudo: ${sellJson[i]["detalle"]}");

            if (sellJson[i]["detalle"] != null && sellJson[i]["detalle"] is List) {
              try {
                productos = (sellJson[i]["detalle"] as List)
                    .where((item) => item is Map)
                    .map((item) => Map<String, dynamic>.from(item))
                    .toList();
              } catch (e) {
                print("Error al convertir detalle: $e");
              }
            }
            setState(() {
              sales.add( {
                "nro_venta": sellJson[i]["nro_venta"],
                "total": double.parse(sellJson[i]["total"]),
                "cliente": sellJson[i]["cliente"],
                "estado": sellJson[i]["estado"],
                "tipoDocumento": sellJson[i]["tipo"],
                "numero": sellJson[i]["nro_documento"],
                "productos": productos,
                "metodoPago": sellJson[i]["metodoPago"]
              });

            });
          }
          print(sales[0]["productos"].toString());
        }


      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener ventas.')),
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


  Future<void> setNotaCreditoVentas(String nro_venta) async {

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
              Text('Creando nota de credito...'),
            ],
          ),
        );
      },
    );


    try {

      final response = await http.post(Uri.parse("$url_base/nota.credito.agregar.php"), body: {
        "nro_venta":nro_venta
      });

      if (response.statusCode == 200) {
        // var rptaJson = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('nota de credito creada correctamente.')),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear nota de credito.')),
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

  Future<void> anularVentas(String nro_venta, String tipo, String documento) async {

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
                Text('Anulando venta...'),
              ],
            ),
          );
        },
      );


    try {

      final response = await http.post(Uri.parse("$url_base/anular.venta.php"), body: {
        "codigo":nro_venta, "tipo":tipo
      });

      if (response.statusCode == 200) {
        // var rptaJson = json.decode(response.body);
        if(documento != "NP"){
          await setNotaCreditoVentas(nro_venta);
        }

        DateTime actual = DateTime.now();
        await fetchVentas("","${actual.year}-${actual.month}-${actual.day}",idsucursal!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta anulada correctamente.')),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al anular venta.')),
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

  Future<void> fetchImpresionPDF(String nro_venta, String tipodoc) async {
    try {
      String url = "";
      if(tipodoc == "Nota Pedido"){
        url = "$url_base/venta.impresion.nota.pedido.php";
      }else{
        url = "$url_base/venta.listar.impresion.php";
      }

      final response = await http.post(Uri.parse(url), body: {
        "nro_venta":nro_venta
      });

      if (response.statusCode == 200) {
        _launchURL(nro_venta);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Correcto')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener ventas.')),
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

  Future<void> fetchImpresionNotaPDF(String nro_venta) async {
    try {
      final response = await http.post(Uri.parse("$url_base/nota.credito.listar.impresion.php"), body: {
        "nro_venta":nro_venta
      });

      if (response.statusCode == 200) {
        _launchURLNota(nro_venta);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Correcto')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener ventas.')),
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

  Future<void> _launchURL(String nroVenta) async {
    final Uri url = Uri.parse("$url_base/${nroVenta}.pdf");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir la URL: $url');
    }
  }

  Future<void> _launchURLNota(String nroVenta) async {
    final Uri url = Uri.parse("$url_base/${nroVenta}-nc.pdf");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir la URL: $url');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      DateTime actual = DateTime.now();
      fetchVentas("","${actual.year}-${actual.month}-${actual.day}",idsucursal!);
    });
  }
  @override
  Widget build(BuildContext context) {
    final filteredSales = sales.where((sale) {
      return sale["cliente"].toString().toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulvline,
          foregroundColor: Colors.white,
          title: Text("Ventas del Día")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Buscar cliente",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                      String fecha_seleccionada = DateTime.parse(
                          "${selectedDate!.year.toString().padLeft(4, '0')}-"
                              "${selectedDate!.month.toString().padLeft(2, '0')}-"
                              "${selectedDate!.day.toString().padLeft(2, '0')}"
                      ).toString();
                      print(fecha_seleccionada.substring(0,10));
                      fetchVentas("",fecha_seleccionada.substring(0,10),idsucursal!);

                    }
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSales.length,
              itemBuilder: (context, index) {
                var sale = filteredSales[index];
                return Card(
                  color: sale["estado"] == "A" ? Colors.red[200] :  Colors.blueGrey[100],
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("Total: S/ ${sale["total"].toStringAsFixed(2)}"),
                    subtitle: Text("Cliente: ${sale["cliente"]}\n${sale["tipoDocumento"]}: ${sale["numero"]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(sale["estado"] == "A" ? Icons.minimize: Icons.cancel, color: Colors.red),
                          onPressed: () async{
                            if(sale["estado"] == "A"){
                              await fetchImpresionNotaPDF(sale["nro_venta"]);
                            }else{
                              await anularVentas(sale["nro_venta"], "A", sale["tipoDocumento"]);
                            }

                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.print, color: Colors.blue),
                          onPressed: () async{
                            await fetchImpresionPDF(sale["nro_venta"],sale["tipoDocumento"]);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Detalle de Venta"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Método de Pago: ${sale["metodoPago"]}"),
                              SizedBox(height: 10),
                              Text("Productos:"),
                              ...sale["productos"].map<Widget>((p) => Text("- ${p["producto"]} - cant.:${p["cantidad"]} - prec.:${p["precio"]}"))
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cerrar", style: TextStyle(color: Colors.blue)),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          )

        ],
      ),
    );
  }
}
