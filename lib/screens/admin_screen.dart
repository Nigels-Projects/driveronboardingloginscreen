import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driverapp.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<DriverApplication> _applications = [];

  @override
  void initState() {
    super.initState();
    _loadSubmittedApplications();
  }

  Future<void> _loadSubmittedApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList('submitted_applications') ?? [];
    setState(() {
      _applications = rawList
          .map((item) => DriverApplication.fromJson(jsonDecode(item)))
          .toList();
    });
  }

  Future<void> _updateStatus(DriverApplication app, ApplicationStatus newStatus) async {
    setState(() {
      app.status = newStatus;
    });

    final prefs = await SharedPreferences.getInstance();
    final updatedList = _applications.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList('submitted_applications', updatedList);
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.approved:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.pending:
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Approval Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _applications.isEmpty
          ? const Center(child: Text('No submitted profiles found.'))
          : ListView.builder(
              itemCount: _applications.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final app = _applications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('${app.fullName} (${app.vehicleMakeModel})'),
                    subtitle: Text(
                      'Email: ${app.email}\nDocument: ${app.licenseFileName ?? "None"} | Verified OTP: ${app.isPhoneVerified}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(
                            app.status.name.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: _getStatusColor(app.status),
                        ),
                        PopupMenuButton<ApplicationStatus>(
                          onSelected: (status) => _updateStatus(app, status),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: ApplicationStatus.approved,
                              child: Text('Approve'),
                            ),
                            const PopupMenuItem(
                              value: ApplicationStatus.rejected,
                              child: Text('Reject'),
                            ),
                            const PopupMenuItem(
                              value: ApplicationStatus.pending,
                              child: Text('Set Pending'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}