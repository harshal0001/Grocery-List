import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_items.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryitems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'grocery-59699-default-rtdb.firebaseio.com', 'grocery-list.json');

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch data. Please try again later";
        });
      }
      // TODO For Firebase, response.body where body is String so we have to return a String i.e. instead of
      //      response.body == null, we have to write response.body == 'null'. This thing is backend specific
      //      it differs from backend to backend
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in data.entries) {
        final category = categories.entries
            .firstWhere((categoryItem) =>
                categoryItem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryitems = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Something went wrong!. Please try again later.";
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryitems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryitems.indexOf(item);
    setState(() {
      _groceryitems.remove(item);
    });

    final url = Uri.https('grocery-59699-default-rtdb.firebaseio.com',
        'grocery-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Oops! You can't delete the item"),
        ),
      );
      setState(() {
        _groceryitems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text('No items added yet !'),
    );

    if (_isLoading) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryitems.isNotEmpty) {
      content = ListView.builder(
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(_groceryitems[index].id),
            onDismissed: (direction) {
              _removeItem(_groceryitems[index]);
            },
            child: ListTile(
              title: Text(_groceryitems[index].name),
              leading: Container(
                width: 24,
                height: 24,
                color: _groceryitems[index].category.color,
              ),
              trailing: Text(
                _groceryitems[index].quantity.toString(),
              ),
            ),
          );
        },
        itemCount: _groceryitems.length,
      );
    }
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
