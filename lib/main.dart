import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://tesytnabwxbhwetnclqv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRlc3l0bmFid3hiaHdldG5jbHF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTc4MjQyMTAsImV4cCI6MjAzMzQwMDIxMH0.UUKL_XEh9-dbqbgBP2hsqzJGnIR2CaffC0N-jUM0gyA',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD dengan Supabase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient client = Supabase.instance.client;
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await client
        .from('produk')
        .select()
        .execute();

    if (response.error == null) {
      setState(() {
        _products = response.data as List<dynamic>;
      });
    } else {
      print('Error fetching products: ${response.error!.message}');
    }
  }

  Future<void> _addProduct(String name, double price, int stock) async {
    final response = await client
        .from('produk')
        .insert({
          'nama': name,
          'harga': price,
          'stok': stock,
        })
        .execute();

    if (response.error == null) {
      _fetchProducts();
    } else {
      print('Error adding product: ${response.error!.message}');
    }
  }

  Future<void> _updateProduct(String id, String name, double price, int stock) async {
    final response = await client
        .from('produk')
        .update({
          'nama': name,
          'harga': price,
          'stok': stock,
        })
        .eq('id', id)
        .execute();

    if (response.error == null) {
      _fetchProducts();
    } else {
      print('Error updating product: ${response.error!.message}');
    }
  }

  Future<void> _deleteProduct(String id) async {
    final response = await client
        .from('produk')
        .delete()
        .eq('id', id)
        .execute();

    if (response.error == null) {
      _fetchProducts();
    } else {
      print('Error deleting product: ${response.error!.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD System With Supabase'),
      ),
      body: _buildProductList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _addProduct('Produk Baru', 100.0, 10);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ListTile(
          title: Text(product['nama']),
          subtitle: Text('Harga: ${product['harga']}, Stok: ${product['stok']}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  await _updateProduct(product['id'], 'Produk Update', 200.0, 20);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await _deleteProduct(product['id']);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
