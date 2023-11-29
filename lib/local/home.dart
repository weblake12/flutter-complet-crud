import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:logger/logger.dart';
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

  Future<dynamic> showbottommodal(BuildContext context, String label, ElevatedButton button) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (BuildContext context) => AnimatedPadding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  left: 20.0,
                ),
                child: Text(label),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 10.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 10.0,
                      ),
                      child: SizedBox(
                        height: 40.0,
                        child: TextField(
                          controller: title,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Titre',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 10.0,
                      ),
                      child: SizedBox(
                        height: 100.0,
                        child: TextField(
                          controller: description,
                          maxLines: 3, //or null
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Description',
                            hintText: "Contenu du message",
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 10.0,
                      ),
                      child: button,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void deleteDialog(
    BuildContext context,
    int id,
    String title,
  ) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: Text('Voulez-vous vraiment supprimer $title'),
            actions: [
              TextButton(
                onPressed: () {
                  deleteData(id);
                  Navigator.of(context).pop();
                },
                child: const Text('Confirmez'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annulez'),
              )
            ],
          );
        });
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

  Card itemCard(
    BuildContext context,
    Item item,
  ) {
    return Card(
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(
        horizontal: 5.0,
        vertical: 3.0,
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 5.0,
          ),
          title: Text(
            item.title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              item.description,
              style: const TextStyle(
                color: Colors.black38,
              ),
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 5.0,
              vertical: 5.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: SizedBox(
                    height: 25.0,
                    width: 50.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        setState(() {
                          title.text = item.title;
                          description.text = item.description;
                        });
                        showbottommodal(
                          context,
                          'Modification',
                          ElevatedButton(
                            onPressed: () => updateData(item.id!),
                            child: const Text('Enregistrer'),
                          ),
                        );
                      },
                      child: const Icon(
                        FeatherIcons.edit,
                        size: 15.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: SizedBox(
                    height: 25.0,
                    width: 50.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => deleteDialog(context, item.id!, item.title),
                      child: const Icon(
                        FeatherIcons.trash2,
                        size: 15.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
