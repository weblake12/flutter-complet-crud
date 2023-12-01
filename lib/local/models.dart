class Item {
  int? id;
  String title;
  String description;

  Item({
    this.id,
    required this.title,
    required this.description,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }

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
