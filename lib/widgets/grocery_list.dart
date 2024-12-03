import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop_app/data/categories_data.dart';
import 'package:shop_app/models/category_model.dart';
import 'package:shop_app/models/grocery_item_model.dart';
import 'package:shop_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  String? _error;

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final Uri url = Uri.https(
        "flutter-shop-app-37649-default-rtdb.firebaseio.com",
        "shopping-list.json");
    try {
      final http.Response res = await http.get(url);
      if (res.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch data. Please try again later.";
        });
        return;
      } else if (res.statusCode < 300) {
        setState(() {
          _error = null;
        });
      }

      if (json.decode(res.body) == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> loadedData = jsonDecode(res.body);

      final List<GroceryItem> loadedItems = [];

      for (var item in loadedData.entries) {
        final Category category = categories.entries
            .firstWhere(
                (element) => element.value.title == item.value['category'])
            .value;

        loadedItems.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));

        setState(() {
          _groceryItems = loadedItems;
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _error = "Something went wrong. Please try again later.";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("No Items added yet."),
          TextButton(onPressed: _addItem, child: const Text("Add Items")),
        ],
      ),
    );

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (_) {
            _removeItem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(
              _groceryItems[index].name,
              style: const TextStyle(color: Colors.white),
            ),
            leading: Container(
              height: 24,
              width: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            TextButton(onPressed: _loadData, child: const Text("Try Again"))
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Grocery",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh))
        ],
      ),
      body: content,
    );
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final Uri url = Uri.https(
        "flutter-shop-app-37649-default-rtdb.firebaseio.com",
        "shopping-list/${item.id}.json");

    final res = await http.delete(url);

    if (res.statusCode >= 400 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete item.")));
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) return;
    setState(() {
      _groceryItems.add(newItem);
    });
  }
}
