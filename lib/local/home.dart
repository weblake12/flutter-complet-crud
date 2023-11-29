import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sqflite_crud/local/components.dart';
import 'package:sqflite_crud/local/models.dart';
import 'package:sqflite_crud/local/sql_local_heper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  // All journals
  List<Item> journals = [];
  // This function is used to fetch all data from the database
  void refreshJournals() async {
    final items = await SQLLocalHelper.getItems();
    Logger().i('!! items');
    Logger().i(items);

    setState(() {
      journals = items;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    SQLLocalHelper.initializeDB().whenComplete(() async {
      refreshJournals();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Films aux Oscars'),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                    bottom: 50.0,
                    right: 5.0,
                    left: 5.0,
                  ),
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: journals.length,
                        itemBuilder: (context, index) => itemCard(
                          context,
                          journals[index],
                          () {
                            setState(() {
                              title.text = journals[index].title;
                              description.text = journals[index].description;
                            });
                            showbottommodal(
                              context,
                              'Modification',
                              ElevatedButton(
                                onPressed: () => updateData(journals[index].id!),
                                child: const Text('Enregistrer'),
                              ),
                              title,
                              description,
                            );
                          },
                          () => deleteDialog(
                            context,
                            journals[index].id!,
                            journals[index].title,
                            () {
                              deleteData(journals[index].id!);
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              title.text = '';
              description.text = '';
            });
            showbottommodal(
              context,
              'Nouvel enregistrement',
              ElevatedButton(
                onPressed: () => createData(),
                child: const Text('Enregistrer'),
              ),
              title,
              description,
            );
          },
          label: const Text(
            'Nouvel enregistrement',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  bool isInteger(num value) => value is int || value == value.roundToDouble();

  Future<void> deleteData(int id) async {
    setState(() {
      isLoading = true;
    });
    await SQLLocalHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Suppression éffectée'),
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
      (route) => false,
    );
    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateData(int id) async {
    setState(() {
      isLoading = true;
    });
    int result = await SQLLocalHelper.updateItem(
      Item(
        id: id,
        title: title.text,
        description: description.text,
      ),
    );
    MaterialColor color = Colors.red;
    Text text = const Text('Opération ratée');
    if (isInteger(result)) {
      color = Colors.green;
      text = const Text('Opération éffectée');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: text,
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
      (route) => false,
    );
    setState(() {
      isLoading = false;
    });
  }

  Future<void> createData() async {
    setState(() {
      isLoading = true;
    });
    int id = await SQLLocalHelper.createItem(
      Item(
        title: title.text,
        description: description.text,
      ),
    );
    MaterialColor color = Colors.red;
    Text text = const Text('Opération ratée');
    if (isInteger(id)) {
      color = Colors.green;
      text = const Text('Opération éffectée');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: text,
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
      (route) => false,
    );
    setState(() {
      isLoading = false;
    });
  }
}
