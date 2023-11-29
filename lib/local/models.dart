class Item {
  int? id;
  String title;
  String description;

  Item({
    this.id,
    required this.title,
    required this.description,
  });

  Item.fromMap(Map<String, dynamic> item)
      : id = item["id"],
        title = item["title"],
        description = item["description"];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}
