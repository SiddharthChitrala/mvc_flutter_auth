import 'package:flutter/material.dart';
import '../controllers/details_controller.dart';
import '../models/details_model.dart';

class DetailsPage extends StatefulWidget {
  final String userId; // Pass the logged-in user's ID
  const DetailsPage({super.key, required this.userId});

  @override
  DetailsPageState createState() => DetailsPageState();
}

class DetailsPageState extends State<DetailsPage> {
  final DetailsController _controller = DetailsController();
  List<Details> _details = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      _details = await _controller.getAll(widget.userId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load details: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addOrEditDetail({Details? detail}) async {
    final nameController = TextEditingController(text: detail?.name ?? '');
    final addressController = TextEditingController(text: detail?.address ?? '');
    String status = detail?.status ?? 'pending';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(detail == null ? "Add Detail" : "Edit Detail"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address"),
              ),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: "Status"),
                items: const [
                  DropdownMenuItem(value: "pending", child: Text("Pending")),
                  DropdownMenuItem(value: "completed", child: Text("Completed")),
                  DropdownMenuItem(value: "approved", child: Text("Approved")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    status = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final address = addressController.text.trim();

                if (name.isEmpty || address.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fields cannot be empty")),
                  );
                  return;
                }

                try {
                  if (detail == null) {
                    // Add new detail
                    final newDetail = await _controller.create(
                      widget.userId,
                      name,
                      address,
                      status,
                    );
                    setState(() => _details.add(newDetail));
                  } else {
                    // Edit existing detail
                    final updatedDetail = await _controller.update(
                      detail.id,
                      name,
                      address,
                      status,
                    );
                    setState(() {
                      final index = _details.indexWhere((d) => d.id == detail.id);
                      if (index != -1) {
                        _details[index] = updatedDetail;
                      }
                    });
                  }

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Operation failed: $e")),
                  );
                }
              },
              child: Text(detail == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }

  void _deleteDetail(String id) async {
    try {
      await _controller.delete(id);
      setState(() {
        _details.removeWhere((detail) => detail.id == id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete detail: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _details.isEmpty
              ? const Center(child: Text("No details found"))
              : ListView.builder(
                  itemCount: _details.length,
                  itemBuilder: (context, index) {
                    final detail = _details[index];
                    return ListTile(
                      title: Text(detail.name),
                      subtitle: Text("${detail.address} - ${detail.status}"),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == "Edit") {
                            _addOrEditDetail(detail: detail);
                          } else if (value == "Delete") {
                            _deleteDetail(detail.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: "Edit", child: Text("Edit")),
                          const PopupMenuItem(value: "Delete", child: Text("Delete")),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditDetail(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
