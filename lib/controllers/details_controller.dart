import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/details_model.dart';

class DetailsController {
  final String apiBaseUrl = "https://example.com/api"; // Replace with your actual API URL
  final String localFilePath = "details.json"; // Path to local storage

  /// Create a new detail
  Future<Details> create(String userId, String name, String address, String status) async {
    final newDetail = Details(
      id: DateTime.now().toString(),
      userId: userId,
      name: name,
      address: address,
      status: status,
    );

    // Save to local storage first
    final details = await Details.loadFromLocalFile(localFilePath);
    details.add(newDetail);
    await Details.saveToLocalFile(details, localFilePath);

    // Sync with API
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/details'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newDetail.toJson()),
      );

      if (response.statusCode == 201) {
        return Details.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create detail: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating detail: $e");
    }
  }

  /// Get all details for a specific user
  Future<List<Details>> getAll(String userId) async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/details?userId=$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Details.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch details: ${response.body}");
      }
    } catch (e) {
      // Fallback to local storage if API fails
      final details = await Details.loadFromLocalFile(localFilePath);
      return details.where((d) => d.userId == userId).toList();
    }
  }

  /// Update an existing detail
  Future<Details> update(String id, String name, String address, String status) async {
    // Update local storage
    final details = await Details.loadFromLocalFile(localFilePath);
    final index = details.indexWhere((d) => d.id == id);

    if (index == -1) {
      throw Exception("Detail not found locally");
    }

    details[index] = Details(
      id: id,
      userId: details[index].userId,
      name: name,
      address: address,
      status: status,
    );
    await Details.saveToLocalFile(details, localFilePath);

    // Sync with API
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/details/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(details[index].toJson()),
      );

      if (response.statusCode == 200) {
        return Details.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to update detail: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating detail: $e");
    }
  }

  /// Delete a detail
  Future<void> delete(String id) async {
    // Remove from local storage
    final details = await Details.loadFromLocalFile(localFilePath);
    final updatedDetails = details.where((detail) => detail.id != id).toList();
    await Details.saveToLocalFile(updatedDetails, localFilePath);

    // Sync with API
    try {
      final response = await http.delete(Uri.parse('$apiBaseUrl/details/$id'));

      if (response.statusCode != 200) {
        throw Exception("Failed to delete detail: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting detail: $e");
    }
  }

  /// Change status of a detail
  Future<void> changeStatus(String id, String status) async {
    // Update status locally
    final details = await Details.loadFromLocalFile(localFilePath);
    final index = details.indexWhere((d) => d.id == id);

    if (index == -1) {
      throw Exception("Detail not found locally");
    }

    details[index].status = status;
    await Details.saveToLocalFile(details, localFilePath);

    // Sync with API
    try {
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/details/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update status: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating status: $e");
    }
  }
}
