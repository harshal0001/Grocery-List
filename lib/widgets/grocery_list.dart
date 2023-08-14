import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummy_items.dart';
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

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'grocery-59699-default-rtdb.firebaseio.com', 'grocery-list.json');
    final response = await http.get(url);
    final Map<String, dynamic> data = json.decode(response.body);
    final List<GroceryItem> _loadedItems = [];
    for (final item in data.entries) {
      final category = categories.entries
          .firstWhere((categoryItem) =>
              categoryItem.value.title == item.value['category'])
          .value;
      _loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryitems = _loadedItems;
    });
  }

  void _addItem() async {
    await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => NewItem(),
      ),
    );
    _loadItems();
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryitems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text('No items added yet !'),
    );

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
