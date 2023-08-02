import 'package:flutter/material.dart';

import 'package:my_list/models/grocery_item.dart';
import 'package:my_list/widgets/add_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItmes = [];
  final url = Uri.https(
      'shopping-list-c5127-default-rtdb.firebaseio.com', 'shopping-list.json');

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

  @override
  Widget build(BuildContext context) {
    Widget content = ListView.builder(
      itemCount: _groceryItmes.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(_groceryItmes[index].name),
        leading: Container(
          height: 20,
          width: 20,
          color: _groceryItmes[index].category.color,
        ),
        trailing: Text(_groceryItmes[index].quantity.toString()),
      ),
    );

    if (_groceryItmes.isEmpty) {
      content = Center(
        child: Text(
          'No items. Add new items!',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
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
