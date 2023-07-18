import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/categories.dart';
import 'package:shopping_list/models/grocery_items.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var _enteredname = '';
  var _initalcategory = categories[Categories.vegetables]!;
  var _isSending = false;
  var _enteredvalue = 1;

  void _saveditem() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      _isSending = true;
      final url = Uri.https(
        'shoppinglist-392cf-default-rtdb.firebaseio.com',
        'shopping_list.json',
      );
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _enteredname,
            'quantity': _enteredvalue,
            'category': _initalcategory.title,
          },
        ),
      );
      final Map<String, dynamic> resData = json.decode(response.body);
      //response.statusCode
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(GroceryItem(
          id: resData['name'],
          name: _enteredname,
          quantity: _enteredvalue,
          category: _initalcategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new item'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Name Should be between 1 to 50 Characters';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredname = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Error! Enter a valid & positive number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredvalue = int.parse(value!);
                        },
                        decoration: const InputDecoration(
                          label: Text('Quantity'),
                        ),
                        initialValue: _enteredvalue.toString(),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                          value: _initalcategory,
                          items: [
                            for (final category in categories.entries)
                              DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(category.value.title),
                                  ],
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _initalcategory = value!;
                            });
                          }),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: _isSending
                            ? null
                            : () {
                                _formkey.currentState!.reset();
                              },
                        child: const Text('Reset')),
                    ElevatedButton(
                        onPressed: _isSending ? null : _saveditem,
                        child: _isSending
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Save'))
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
