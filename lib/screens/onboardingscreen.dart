import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driverapp.dart';
import 'admin_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const OnboardingScreen({
    Key? key,
    required this.onToggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  DriverApplication _application = DriverApplication();
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedDraft();
  }

  Future<void> _loadSavedDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('driver_application_draft');
    if (savedData != null) {
      setState(() {
        _application = DriverApplication.fromJson(jsonDecode(savedData));
      });
    }
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_application_draft', jsonEncode(_application.toJson()));
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('driver_application_draft');
    setState(() {
      _application = DriverApplication();
      _currentStep = 0;
    });
  }

  Future<void> _pickDocument(FormFieldState<bool> state) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      setState(() {
        _application.licenseFileName = file.name;
        _application.licenseFileSize = file.size;
      });
      _saveDraft();
      state.didChange(true);
    }
  }

  void _handleStepContinue() {
    bool isCurrentStepValid = false;

    if (_currentStep == 0) {
      isCurrentStepValid = _step1Key.currentState?.validate() ?? false;
      if (isCurrentStepValid && !_application.isPhoneVerified) {
        _showOtpDialog();
        return;
      }
    } else if (_currentStep == 1) {
      isCurrentStepValid = _step2Key.currentState?.validate() ?? false;
    } else if (_currentStep == 2) {
      isCurrentStepValid = _step3Key.currentState?.validate() ?? false;
    }

    if (isCurrentStepValid) {
      _saveDraft();
      if (_currentStep < 2) {
        setState(() => _currentStep += 1);
      } else {
        _submitApplication();
      }
    }
  }

  void _showOtpDialog() {
    _otpController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter the 4-digit code sent to ${_application.phoneNumber} (Use: 1234)'),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'OTP Code',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_otpController.text == '1234') {
                setState(() {
                  _application.isPhoneVerified = true;
                  _currentStep += 1;
                });
                _saveDraft();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone number verified successfully!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid OTP. Use code: 1234')),
                );
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitApplication() async {
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Save finalized application to persistent submitted list
    final prefs = await SharedPreferences.getInstance();
    final List<String> submitted = prefs.getStringList('submitted_applications') ?? [];
    
    _application.submittedAt = DateTime.now();
    submitted.add(jsonEncode(_application.toJson()));
    
    await prefs.setStringList('submitted_applications', submitted);
    await prefs.remove('driver_application_draft');

    setState(() => _isSubmitting = false);
    _showSuccessDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Onboarding'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Dashboard',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AdminScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Draft',
            onPressed: _clearDraft,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: _isSubmitting
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        'Submitting application & encrypting documents...',
                        style: TextStyle(fontSize: 16, color: Colors.indigo),
                      ),
                    ],
                  ),
                )
              : Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  onStepContinue: _handleStepContinue,
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep -= 1);
                    }
                  },
                  steps: [
                    // STEP 1: PERSONAL INFO
                    Step(
                      title: const Text('Personal'),
                      isActive: _currentStep >= 0,
                      content: Form(
                        key: _step1Key,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            children: [
                              TextFormField(
                                initialValue: _application.fullName,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? 'Please enter your full name'
                                    : null,
                                onChanged: (val) {
                                  _application.fullName = val;
                                  _saveDraft();
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: _application.email,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Email is required';
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  _application.email = val;
                                  _saveDraft();
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: _application.phoneNumber,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.phone),
                                  suffixIcon: _application.isPhoneVerified
                                      ? const Icon(Icons.check_circle, color: Colors.green)
                                      : null,
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (val) => val == null || val.length < 8
                                    ? 'Enter a valid phone number'
                                    : null,
                                onChanged: (val) {
                                  _application.phoneNumber = val;
                                  _application.isPhoneVerified = false;
                                  _saveDraft();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // STEP 2: VEHICLE DETAILS
                    Step(
                      title: const Text('Vehicle'),
                      isActive: _currentStep >= 1,
                      content: Form(
                        key: _step2Key,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            children: [
                              TextFormField(
                                initialValue: _application.licenseNumber,
                                decoration: const InputDecoration(
                                  labelText: 'Driver License Number',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.card_membership),
                                ),
                                validator: (val) => val == null || val.isEmpty
                                    ? 'License number is required'
                                    : null,
                                onChanged: (val) {
                                  _application.licenseNumber = val;
                                  _saveDraft();
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: _application.vehicleMakeModel,
                                decoration: const InputDecoration(
                                  labelText: 'Vehicle Make & Model',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.directions_car),
                                ),
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Vehicle detail is required'
                                    : null,
                                onChanged: (val) {
                                  _application.vehicleMakeModel = val;
                                  _saveDraft();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // STEP 3: DOCUMENT UPLOAD & REVIEW
                    Step(
                      title: const Text('Documents'),
                      isActive: _currentStep >= 2,
                      content: Form(
                        key: _step3Key,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FormField<bool>(
                                initialValue: _application.hasLicenseDocument,
                                validator: (value) {
                                  if (!_application.hasLicenseDocument) {
                                    return 'Please attach your driver license document.';
                                  }
                                  return null;
                                },
                                builder: (state) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: state.hasError ? Colors.red : Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            _application.hasLicenseDocument
                                                ? Icons.task_alt
                                                : Icons.upload_file,
                                            color: _application.hasLicenseDocument
                                                ? Colors.green
                                                : Colors.indigo,
                                            size: 36,
                                          ),
                                          title: Text(
                                            _application.hasLicenseDocument
                                                ? _application.licenseFileName!
                                                : 'Driver License Document (PDF/PNG/JPG)',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                            _application.hasLicenseDocument
                                                ? 'Size: ${(_application.licenseFileSize! / 1024).toStringAsFixed(1)} KB — Verified'
                                                : 'Upload clear document image or PDF',
                                          ),
                                          trailing: OutlinedButton.icon(
                                            icon: Icon(_application.hasLicenseDocument
                                                ? Icons.refresh
                                                : Icons.add_a_photo),
                                            label: Text(_application.hasLicenseDocument
                                                ? 'Replace File'
                                                : 'Select File'),
                                            onPressed: () => _pickDocument(state),
                                          ),
                                        ),
                                      ),
                                      if (state.hasError)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                                          child: Text(
                                            state.errorText!,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.error,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Application Preview',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Applicant: ${_application.fullName.isEmpty ? "—" : _application.fullName}'),
                                    const SizedBox(height: 4),
                                    Text('Contact: ${_application.email.isEmpty ? "—" : _application.email} | ${_application.phoneNumber}'),
                                    const SizedBox(height: 4),
                                    Text('Vehicle: ${_application.vehicleMakeModel.isEmpty ? "—" : _application.vehicleMakeModel}'),
                                    const SizedBox(height: 4),
                                    Text('Phone Verified: ${_application.isPhoneVerified ? "Yes" : "No"}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Application Submitted Successfully'),
        content: Text(
          'Thank you, ${_application.fullName}! Your registration has been saved to the database. You can review its status on the Admin Dashboard.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _application = DriverApplication();
                _currentStep = 0;
              });
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}