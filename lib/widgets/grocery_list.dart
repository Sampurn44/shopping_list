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
  List<GroceryItem> _groceryItem = [];
  var isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadata();
  }

  void _loadata() async {
    final url = Uri.https(
      'shoppinglist-392cf-default-rtdb.firebaseio.com',
      'shopping_list.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Error! Failed to fetch data. Please try again later';
        });
      }
      if (response.body == 'null') {
        setState(() {
          isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> listitems = [];
      for (final items in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catite) => catite.value.title == items.value['category'])
            .value;
        listitems.add(GroceryItem(
          id: items.key,
          name: items.value['name'],
          category: category,
          quantity: items.value['quantity'],
        ));
        setState(() {
          _groceryItem = listitems;
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _error = 'Something went wrong. Please try again later';
      });
    }
  }
  // throw Exception('An Error Occured');

  void _additem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItem.add(newItem);
    });
  }

  void _removeditem(GroceryItem item) async {
    final indexof = _groceryItem.indexOf(item);
    setState(() {
      _groceryItem.remove(item);
    });
    final url = Uri.https(
      'shoppinglist-392cf-default-rtdb.firebaseio.com',
      'shopping_list/${item.id}.json',
    );
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _groceryItem.insert(indexof, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No item Added!'),
    );
    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItem.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeditem(_groceryItem[index]);
          },
          key: ValueKey(_groceryItem[index].id),
          child: ListTile(
            title: Text(_groceryItem[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItem[index].category.color,
            ),
            trailing: Text(
              _groceryItem[index].quantity.toString(),
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: _additem, icon: const Icon(Icons.add))],
        title: const Text('Your Groceries'),
      ),
      body: content,
    );
  }
}
