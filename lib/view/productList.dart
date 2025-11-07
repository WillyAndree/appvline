import 'dart:convert';

import 'package:appvline/view/cart_register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:appvline/constants.dart';
//import 'package:prycitas/view/cart_register.dart';

class ProductListScreen extends StatefulWidget {

  List products_cart = [];
  ProductListScreen({super.key,  required this.products_cart});
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Map<String, dynamic>> products = [];

  String searchQuery = "";
  //List products_cart = [];

  Future<void> fetchProducts(String producto, String sucursal) async {
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
              Text('Cargando productos...'),
            ],
          ),
        );
      },
    );
    try {
      final response = await http.post(Uri.parse("$url_base/producto.listar.all.php"), body: {
        "nombres":producto,
        "sucursal":sucursal
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
         var productsJson = rptaJson["datos"] ?? [];
        if ( productsJson.isEmpty) {
          setState((){
            products.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron productos.')),
          );
          return;
        }else{
          setState((){
            products.clear();
          });


          for(int i = 0; i <productsJson.length; i++){
            setState(() {
              products.add({
                "codigo":productsJson[i]["codigo"],
                "nombres":productsJson[i]["nombre"],
                "stock":productsJson[i]["stock"],
                "precio":productsJson[i]["precio"],
                "tipo":productsJson[i]["tipo"],
                "estado":productsJson[i]["estado"],
                "sucursal":productsJson[i]["codigo_producto"]
              });
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
    Navigator.pop(context);
  }

  Future<void> registerProductos(String codigo, descripcion, precio, tipo, operacion) async {
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
              Text('Registrando operación...'),
            ],
          ),
        );
      },
    );
    try {
      final response = await http.post(Uri.parse("$url_base/agregar.productos.php"), body: {
        "descripcion":descripcion, "precio":precio,  "tipo": tipo, "operacion": operacion, "codigo": codigo
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> rptaJson = json.decode(response.body);
        var rptJson = rptaJson["datos"] ?? [];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operación registrado correctamente.')),
        );
        await fetchProducts("",idsucursal!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar producto.')),
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

  void _mostrarDialog(String codigo,String tipo,String descripcion, String precio, String tipo_producto) async {
    TextEditingController nombreController = TextEditingController();
    TextEditingController precioController = TextEditingController();
    nombreController.text = descripcion;
    precioController.text = precio;
    String tipoSeleccionado =  tipo_producto == "P" ? "Producto" : "Servicio";

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${tipo} Producto o Servicio'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: 'Nombre o Descripción'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: precioController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Precio'),
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: tipoSeleccionado,
                  items: ['Producto', 'Servicio'].map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      tipoSeleccionado = valor!;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await registerProductos(
                codigo,
                nombreController.text,
                precioController.text,
                tipoSeleccionado == "Servicio" ? "S" : "P",
                tipo,
              );
              Navigator.of(context).pop();
            },
            child: Text('$tipo'),
          ),
        ],
      ),
    );


    if (resultado != null) {
      print("Datos recibidos: $resultado");
      // Puedes usar los datos aquí
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      fetchProducts("",idsucursal!);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulvline,
          foregroundColor: Colors.white,
          actions: [
            IconButton(onPressed: () async{
              final rpta = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartRegister(productos: widget.products_cart,)),
              );
              if(rpta != null){
                setState(() {
                  widget.products_cart!.clear();
                });

              }
              //mostrarDialogoProductos(context,products_cart);
            }, icon: Icon(widget.products_cart.isNotEmpty ? Icons.shopping_cart_checkout : Icons.shopping_cart, color: widget.products_cart.isNotEmpty ? Colors.red: Colors.white,))
          ],
          title: Text("Productos")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: azulvline,
        onPressed: () {
          _mostrarDialog("","Agregar", "", "", "");
        },
        child: Icon(Icons.add, color: Colors.white,),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar producto...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                if (!product["nombres"].toLowerCase().contains(searchQuery)) {
                  return Container();
                }
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(children: [
                    ListTile(
                      title: Text(product["nombres"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text("Stock: ${product["stock"]}",style: TextStyle(fontSize: 16),),
                      trailing: Text("S/ ${product["precio"]}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      Container(
                          alignment: Alignment.centerRight,
                          child:IconButton(
                              onPressed: () async{
                                final respuesta = await _mostrarDialogoAgregarProducto(context, product["precio"]);
                                if (respuesta != null) {
                                  setState(() {
                                    widget.products_cart!.add({
                                      "idproducto":product["codigo"],
                                      "nombres":product["nombres"],
                                      "cantidad":respuesta["cantidad"],
                                      "precio":respuesta["precio"],
                                      "detalle":respuesta["comentario"],
                                      "medida":"UND",
                                      "sucursal":product["sucursal"],
                                      "subtotal": (int.parse(respuesta["cantidad"].toString()) * double.parse(respuesta["precio"].toString())).toString(),
                                      "ganancia": "0",
                                    });
                                  });

                                } else {
                                  print("El usuario canceló.");
                                }

                                print(widget.products_cart!.toString());
                                /*showDialog(
                            context: context,
                            builder: (context) {
                              String selectedPaymentMethod = "Efectivo";
                              String selectedDocMethod = "Boleta Simple";
                              String total = "${product["precio"]}";
                              TextEditingController amountController = TextEditingController();
                              TextEditingController cantController = TextEditingController();
                              TextEditingController clientController = TextEditingController();
                              TextEditingController dniController = TextEditingController();
                              amountController.text = "${product["precio"]}";
                              cantController.text = "1.0";
                              return AlertDialog(
                                title: Text("Registrar Venta"),
                                content: SingleChildScrollView(
                                    child: Container(
                                        child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(total, style: TextStyle(fontSize: 16),),
                                    ),
                                    DropdownButtonFormField<String>(
                                      value: selectedPaymentMethod,
                                      onChanged: (value) {
                                        selectedPaymentMethod = value!;
                                      },
                                      items: ["Efectivo", "Tarjeta", "Yape", "Plin", "Transferencia"].map((method) {
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
                                          decoration: InputDecoration(labelText: "Precio"),
                                          onChanged: (val){

                                              if(val.isNotEmpty){
                                                String cantidad = cantController.text;
                                                setState(() {
                                                total = (double.parse(cantidad) * double.parse(val)).toStringAsFixed(2);
                                                });
                                              }


                                          },
                                        ),),
                                      SizedBox(width: 10,),
                                      Container(
                                        width: MediaQuery.sizeOf(context).width*0.3,
                                        child:TextField(
                                        controller: cantController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(labelText: "Cantidad"),
                                          onChanged: (val){

                                            if(val.isNotEmpty){
                                              String precio = amountController.text;
                                              setState(() {
                                              total = (double.parse(precio) * double.parse(val)).toStringAsFixed(2);
                                              });
                                            }
                                          },
                                      ),),

                                    ],),),


                                    DropdownButtonFormField<String>(
                                      value: selectedDocMethod,
                                      onChanged: (value) {
                                        selectedDocMethod = value!;
                                      },
                                      items: ["Boleta Simple", "Boleta"].map((method) {
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
                                      decoration: InputDecoration(labelText: "DNI"),
                                    ),
                                    TextField(
                                      controller: clientController,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(labelText: "Cliente"),
                                    ),
                                  ],
                                ))),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancelar", style: TextStyle(color: Colors.blue)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Lógica para guardar el pago
                                      Navigator.pop(context);
                                    },
                                    child: Text("Confirmar", style: TextStyle(color: Colors.blue)),
                                  ),
                                ],
                              );
                            },
                          );*/
                              }, icon: Icon(Icons.sell, color: Colors.blue,)) ),
                      Container(
                          alignment: Alignment.centerRight,
                          child:IconButton(
                              onPressed: () async{
                                _mostrarDialog(product["codigo"],"Editar",product["nombres"],product["precio"],product["tipo"]);
                              }, icon: Icon(Icons.edit, color: Colors.blue,)) ),
                        Container(
                            alignment: Alignment.centerRight,
                            child:IconButton(
                                onPressed: () async{
                                  registerProductos(product["codigo"], "Eliminar", "", "", "");
                                }, icon: Icon(Icons.restore_from_trash, color: Colors.red,)) )
                    ],)


                  ],)
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



Future<Map<String, String>?> _mostrarDialogoAgregarProducto(BuildContext context, String precio) {
  TextEditingController cantidadController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController comentarioController = TextEditingController();

  cantidadController.text = "0";
  precioController.text = precio;

  return showDialog<Map<String, String>>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Agregar Producto"),
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
            child: Text("Agregar"),
          ),
        ],
      );
    },
  );
}

