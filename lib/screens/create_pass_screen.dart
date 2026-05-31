import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/bus_pass.dart';
import '../services/pass_storage_service.dart';
import '../widgets/primary_button.dart';
import 'view_pass_screen.dart';

/// Form screen used to create a brand new pass or renew an existing one.
class CreatePassScreen extends StatefulWidget {
  const CreatePassScreen({super.key});

  @override
  State<CreatePassScreen> createState() => _CreatePassScreenState();
}

class _CreatePassScreenState extends State<CreatePassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = PassStorageService();
  final _dateFormat = DateFormat('dd MMM yyyy');

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _routeController = TextEditingController();

  String _passType = 'Daily';
  DateTime _startDate = DateTime.now();
  bool _saving = false;

  static const _passTypes = ['Daily', 'Weekly', 'Monthly'];

  /// Number of days each pass type is valid for.
  int get _durationDays {
    switch (_passType) {
      case 'Weekly':
        return 7;
      case 'Monthly':
        return 30;
      case 'Daily':
      default:
        return 1;
    }
  }

  /// Expiry is always derived from the start date + the pass duration.
  DateTime get _expiryDate => _startDate.add(Duration(days: _durationDays));

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _savePass() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final pass = BusPass(
      passId: 'BUS-${DateTime.now().millisecondsSinceEpoch}',
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      route: _routeController.text.trim(),
      passType: _passType,
      startDate: _startDate,
      expiryDate: _expiryDate,
    );

    await _storage.savePass(pass);

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bus pass saved successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Replace this screen with the view screen so "back" returns home.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ViewPassScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create / Renew Pass')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                    LengthLimitingTextInputFormatter(15),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    // Simple, assignment-friendly check: 10-15 digits.
                    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
                    if (digits.length < 10 || digits.length > 15) {
                      return 'Enter a valid phone number (10-15 digits)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _routeController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Route / destination',
                    prefixIcon: Icon(Icons.route_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a route or destination';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _passType,
                  decoration: const InputDecoration(
                    labelText: 'Pass type',
                    prefixIcon: Icon(Icons.confirmation_number_outlined),
                  ),
                  items: _passTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _passType = value);
                  },
                ),
                const SizedBox(height: 16),
                // Start date picker styled like a form field.
                InkWell(
                  onTap: _pickStartDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start date',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(_dateFormat.format(_startDate)),
                  ),
                ),
                const SizedBox(height: 16),
                // Auto-calculated expiry date (read only display).
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expiry date (auto-calculated)',
                    prefixIcon: Icon(Icons.event_busy_outlined),
                  ),
                  child: Text(_dateFormat.format(_expiryDate)),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: _saving ? 'Saving...' : 'Save Pass',
                  icon: Icons.save_outlined,
                  onPressed: _saving ? null : _savePass,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
