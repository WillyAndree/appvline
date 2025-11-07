import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:appvline/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class CobrosListScreen extends StatefulWidget {
  @override
  _CobrosListScreenState createState() => _CobrosListScreenState();
}

class _CobrosListScreenState extends State<CobrosListScreen> {


  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> sales_detail = [];
  String selectedTipo = "POR COBRAR";
  double importe =0.00;

  String searchQuery = "";
  DateTime? selectedDate;

  Future<void> fetchCxc(String fecha, String nombres) async {
    importe = 0.00;
    try {


      final response = await http.post(Uri.parse("$url_base/cobros.listar.php"), body: {
        "tipo":"2","fecha":fecha,"nombres":nombres
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
                "codigo_cobro": sellJson[i]["codigo_cobro"],
                "codigo_venta": sellJson[i]["codigo_venta"],
                "total": double.parse(sellJson[i]["total"]),
                "pendiente": double.parse(sellJson[i]["pendiente"]),
                "cliente": sellJson[i]["cliente"],
                "codigo_cliente": sellJson[i]["codigo_cliente"],
                "estado": sellJson[i]["estado"],
                "fecha": sellJson[i]["fecha"],
                "documento": sellJson[i]["documento"],
                "fecha_vencimiento": sellJson[i]["fecha_vencimiento"]
              });
                  importe = importe + double.parse(sellJson[i]["pendiente"]);
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

  Future<void> fetchCobradas(String fecha, String nombres) async {
    try {
      importe = 0.00;

      final response = await http.post(Uri.parse("$url_base/cobros.cobrados.listar.php"), body: {
        "tipo":"2","fecha":fecha,"nombres":nombres
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
          print("DATa: "+sellJson.toString());

          for(int i = 0; i <sellJson.length; i++){

            setState(() {
              sales.add( {
                //"codigo_cobro": sellJson[i]["codigo_cobro"],
                "codigo_venta": sellJson[i]["codigo_venta"] ?? "",
                "total": double.parse(sellJson[i]["total"] ?? "0") ,
                "pendiente": double.parse(sellJson[i]["pendiente"] ?? "0") ,
                "cliente": sellJson[i]["cliente"] ?? "",
                "codigo_cliente": sellJson[i]["codigo_cliente"] ?? "0",
               // "estado": sellJson[i]["estado"],
                "fecha": sellJson[i]["fecha"] ?? "",
                "documento": sellJson[i]["documento"] ?? "",
                "fecha_vencimiento": sellJson[i]["fecha_vencimiento"] ?? ""
              });

              importe = importe + double.parse(sellJson[i]["total"] ?? "0.00") ;
            });
          }
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


  Future<void> fetchImpresionPDF(String cliente) async {
    try {
      String url = "$url_base/estado.cuenta.php";

      final response = await http.post(Uri.parse(url), body: {
        "cliente":cliente
      });

      if (response.statusCode == 200) {
        _launchURL(cliente);
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


  Future<void> _launchURL(String codigo) async {
    final Uri url = Uri.parse("$url_base/EE.CC-${codigo}.pdf");

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
      fetchCxc("${actual.year}-${actual.month}-${actual.day}", "");

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
          title: Text("Cuentas por cobrar")),
      body: Column(
        children: [
          Row(children: [
            Container(
              width: MediaQuery.sizeOf(context).width *0.6,
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: selectedTipo,
                onChanged: (value) {
                  selectedTipo = value!;
                  if(selectedTipo == "COBRADAS"){
                    DateTime actual = DateTime.now();
                    fetchCobradas("${actual.year}-${actual.month}-${actual.day}", "");
                  }else{
                    DateTime actual = DateTime.now();
                    fetchCxc("${actual.year}-${actual.month}-${actual.day}", "");
                  }
                },
                items: ["POR COBRAR", "COBRADAS"].map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: "TIPO CUENTAS"),
              ),
            ),
            SizedBox(width: 10,),
            Container(
              width: MediaQuery.sizeOf(context).width*0.33,
              child:
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  backgroundColor: Colors.green,
                ),
                child: Text("S/."+importe.toStringAsFixed(2), style: TextStyle(fontSize: 16, color: Colors.black)),
              ),
            )

          ],),

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
                    title: Text("Total: S/ ${sale["total"].toStringAsFixed(2) ?? "0"} - Pendiente: S/ ${sale["pendiente"].toStringAsFixed(2) ?? "0"}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                    subtitle: Text("Cliente: ${sale["cliente"] ?? "-"}\n Fecha: ${sale["fecha"] ?? "-"}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.print, color: Colors.blue),
                          onPressed: () async{
                            await fetchImpresionPDF(sale["codigo_cliente"] ?? "0");
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      /*showDialog(
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
                      );*/
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
