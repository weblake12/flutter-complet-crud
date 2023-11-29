import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:sqflite_crud/local/models.dart';

Card itemCard(
  BuildContext context,
  Item item,
  onEditPressed,
  onDeletePressed,
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
                    onPressed: onEditPressed,
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
                    onPressed: onDeletePressed,
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

void deleteDialog(BuildContext context, int id, String title, onPressed) {
  showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text('Voulez-vous vraiment supprimer $title'),
          actions: [
            TextButton(
              onPressed: onPressed,
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

Future<dynamic> showbottommodal(
  BuildContext context,
  String label,
  ElevatedButton button,
  TextEditingController title,
  TextEditingController description,
) {
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
