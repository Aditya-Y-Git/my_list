import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_list/data/categories.dart';
import 'package:my_list/models/grocery_item.dart';
import 'package:my_list/widgets/add_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItmes = [];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https('shopping-list-c5127-default-rtdb.firebaseio.com',
        'shopping-list.json');

    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (element) => element.value.title == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category),
      );
    }

    setState(() {
      _groceryItmes = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    final newItem =
        await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
      builder: (context) => const AddItem(),
    ));

    if (newItem == null) return;

    setState(() {
      _groceryItmes.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) {
// final url = Uri.https('shopping-list-c5127-default-rtdb.firebaseio.com',
//         'shopping-list.json');
//     http.delete(url, )
    setState(() {
      _groceryItmes.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        'No items. Add new items!',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
      ),
    );

    if (_isLoading) {
      const Center(child: CircularProgressIndicator());
    }

    if (_groceryItmes.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItmes.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryItmes[index].id),
          onDismissed: (direction) {
            _removeItem(_groceryItmes[index]);
          },
          child: ListTile(
            title: Text(_groceryItmes[index].name),
            leading: Container(
              height: 20,
              width: 20,
              color: _groceryItmes[index].category.color,
            ),
            trailing: Text(_groceryItmes[index].quantity.toString()),
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Shopping List'),
          actions: [
            IconButton(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: content);
  }
}
