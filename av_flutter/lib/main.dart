import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App CRUD Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const ProductListPage(),
    );
  }
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  ProductListPageState createState() => ProductListPageState();
}

class ProductListPageState extends State<ProductListPage> {
  final String apiUrl = "http://localhost:3000/produtos";
  List products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
    }
  }

  void navigateToForm(Map? product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormPage(product: product),
      ),
    );
    if (result == true) {
      fetchProducts();
    }
  }

  Future<void> deleteProduct(int id) async {
    final url = '$apiUrl/produto/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Lista de Produtos', textAlign: TextAlign.center),
        ),
      ),
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          product['nome'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('R\$ ${product['precoVenda']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => deleteProduct(product['id']),
                          color: Colors.red,
                        ),
                        onTap: () => navigateToForm(product),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToForm(null),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class ProductFormPage extends StatefulWidget {
  final Map? product;

  const ProductFormPage({super.key, this.product});

  @override
  ProductFormPageState createState() => ProductFormPageState();
}

class ProductFormPageState extends State<ProductFormPage> {
  final String apiUrl = "http://localhost:3000";
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController costPriceController;
  late TextEditingController salePriceController;
  late TextEditingController categoryController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
        text: widget.product != null ? widget.product!['nome'] : '');
    costPriceController = TextEditingController(
        text: widget.product != null
            ? widget.product!['precoCusto'].toString()
            : '');
    salePriceController = TextEditingController(
        text: widget.product != null
            ? widget.product!['precoVenda'].toString()
            : '');
    categoryController = TextEditingController(
        text: widget.product != null ? widget.product!['categoria'] : '');
  }

  Future<void> saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = {
        "nome": nameController.text,
        "precoCusto": double.parse(costPriceController.text),
        "precoVenda": double.parse(salePriceController.text),
        "categoria": categoryController.text,
      };

      final url = widget.product == null
          ? '$apiUrl/produto'
          : '$apiUrl/produto/${widget.product!['id']}';
      final method = widget.product == null ? http.post : http.put;

      final response = await method(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> deleteProduct() async {
    if (widget.product != null) {
      final url = '$apiUrl/produto/${widget.product!['id']}';
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.product != null ? 'Editar Produto' : 'Novo Produto',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) =>
                      value!.isEmpty ? 'Nome não pode ser vazio' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: costPriceController,
                  decoration:
                      const InputDecoration(labelText: 'Preço de Custo'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Informe o preço de custo' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: salePriceController,
                  decoration:
                      const InputDecoration(labelText: 'Preço de Venda'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Informe o preço de venda' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  validator: (value) =>
                      value!.isEmpty ? 'Informe a categoria' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Icon(Icons.save, color: Colors.white),
                    ),
                    if (widget.product != null)
                      ElevatedButton(
                        onPressed: deleteProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
