import 'dart:convert';
import 'dart:io';

class Details {
  final String id;
  final String userId; // Link to user
  final String name;
  final String address;
  String status;

  Details({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    this.status = 'pending',
  });

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      address: json['address'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'address': address,
      'status': status,
    };
  }

  static Future<List<Details>> loadFromLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => Details.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveToLocalFile(List<Details> details, String filePath) async {
    final file = File(filePath);
    final jsonString = jsonEncode(details.map((d) => d.toJson()).toList());
    await file.writeAsString(jsonString);
  }
}
