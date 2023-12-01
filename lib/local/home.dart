import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:sqflite_crud/local/components.dart';
import 'package:sqflite_crud/local/models.dart';
import 'package:sqflite_crud/local/sql_heper.dart';
import 'package:sqflite_crud/local/sql_local_heper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool isConnected = false;
  late bool apiConnection;
  String connectionType = 'none';
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  // All journals
  List<Item> internetJournals = [];
  List<Item> localJournals = [];
  List<Item> journals = [];
  // This function is used to fetch all data from the database
  void refreshJournals() async {
    final items = await SQLHelper.getItems();
    final localItems = await SQLLocalHelper.getItems();
    setState(() {
      internetJournals = items;
      localJournals = localItems;
    });
  }

  void checkConnectivity() async {
    // bool conectivityStatus = await InternetConnection().hasInternetAccess;
    final connectivityResult = await (Connectivity().checkConnectivity());
    InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          setState(() {
            isConnected = true;
          });
          break;
        case InternetStatus.disconnected:
          setState(() {
            isConnected = false;
          });
          break;
      }
    });
    /*
    connection = InternetConnection.createInstance(
      customCheckOptions: [
        InternetCheckOption(uri: Uri.parse('https://localhost:3000')),
      ],
    );
    */
    setState(() {
      // apiConnection = connection;
      connectionType =
          (connectivityResult == ConnectivityResult.mobile) ? 'mobile' : ((connectivityResult == ConnectivityResult.wifi) ? 'wifi' : 'none');
    });
  }

  @override
  void initState() {
    super.initState();
    SQLLocalHelper.initializeDB().whenComplete(() async {
      checkConnectivity();
      refreshJournals();
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    journals = isConnected ? internetJournals : localJournals;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Oscars winners'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: isLoading
                  ? Container()
                  : Icon(
                      isConnected ? FeatherIcons.checkCircle : FeatherIcons.xCircle,
                      color: Colors.white,
                      size: 25.0,
                    ),
            )
          ],
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
    (isConnected) ? await SQLHelper.deleteItem(id) : await SQLLocalHelper.deleteItem(id);
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
    int result = (isConnected)
        ? await SQLHelper.updateItem(
            Item(
              id: id,
              title: title.text,
              description: description.text,
            ),
          )
        : await SQLLocalHelper.updateItem(
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
    int id = (isConnected)
        ? await SQLHelper.createItem(
            Item(
              title: title.text,
              description: description.text,
            ),
          )
        : await SQLLocalHelper.createItem(
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
