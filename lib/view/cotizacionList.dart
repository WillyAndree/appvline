import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:appvline/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class CotizacionListScreen extends StatefulWidget {
  @override
  _CotizacionListScreenState createState() => _CotizacionListScreenState();
}

class _CotizacionListScreenState extends State<CotizacionListScreen> {


  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> sales_detail = [];

  String searchQuery = "";
  DateTime? selectedDate;

  Future<void> fetchCotizacion(String nombres,String fecha, String sucursal) async {
    try {


      final response = await http.post(Uri.parse("$url_base/cotizacion.listar.php"), body: {
        "nombres":nombres,"fecha":fecha, "sucursal":sucursal
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
                "documento": sellJson[i]["documento"],
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




  Future<void> fetchImpresionPDF(String nro_venta) async {
    try {
      String url = "$url_base/venta.impresion.cotizacion.php";

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


  Future<void> _launchURL(String nroVenta) async {
    final Uri url = Uri.parse("$url_base/coti${nroVenta}.pdf");

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
      fetchCotizacion("","${actual.year}-${actual.month}-${actual.day}",idsucursal!);
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
          title: Text("Cotizaciones")),
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
                    subtitle: Text("Cliente: ${sale["cliente"]}\n Cotización: ${sale["documento"]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.print, color: Colors.blue),
                          onPressed: () async{
                            await fetchImpresionPDF(sale["nro_venta"]);
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
