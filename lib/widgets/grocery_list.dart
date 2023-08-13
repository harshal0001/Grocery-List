import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_items.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryitems = [];

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
