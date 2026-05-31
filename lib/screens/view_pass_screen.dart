import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/bus_pass.dart';
import '../services/pass_storage_service.dart';
import '../widgets/pass_info_row.dart';
import '../widgets/primary_button.dart';
import 'create_pass_screen.dart';

/// Shows the saved digital pass as a card with a scannable QR code, or a
/// friendly empty state when no pass exists yet.
class ViewPassScreen extends StatefulWidget {
  const ViewPassScreen({super.key});

  @override
  State<ViewPassScreen> createState() => _ViewPassScreenState();
}

class _ViewPassScreenState extends State<ViewPassScreen> {
  final _storage = PassStorageService();
  final _dateFormat = DateFormat('dd MMM yyyy');

  bool _loading = true;
  BusPass? _pass;

  @override
  void initState() {
    super.initState();
    _loadPass();
  }

  Future<void> _loadPass() async {
    setState(() => _loading = true);
    final pass = await _storage.loadPass();
    if (!mounted) return;
    setState(() {
      _pass = pass;
      _loading = false;
    });
  }

  void _goToCreate() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => const CreatePassScreen()),
        )
        // Reload when returning, in case the pass changed.
        .then((_) => _loadPass());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bus Pass')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _pass == null
                ? _buildEmptyState(context)
                : _buildPassCard(context, _pass!),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.badge_outlined,
              size: 72,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 20),
            Text(
              'No bus pass yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You have not created a bus pass. Create one to get your '
              'digital pass and QR code.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Create Bus Pass',
              icon: Icons.add_card_rounded,
              onPressed: _goToCreate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassCard(BuildContext context, BusPass pass) {
    final theme = Theme.of(context);
    final isActive = !pass.isExpired;
    final statusColor = isActive ? Colors.green : theme.colorScheme.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Header band with pass type and status.
                Container(
                  width: double.infinity,
                  color: theme.colorScheme.primary,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BUS PASS',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              letterSpacing: 2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              pass.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pass.fullName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${pass.passType} pass',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // QR code section.
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.outline),
                        ),
                        child: QrImageView(
                          data: pass.toJsonString(),
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Show this QR code to the bus operator',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Details section.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    children: [
                      PassInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone number',
                        value: pass.phone,
                      ),
                      PassInfoRow(
                        icon: Icons.route_outlined,
                        label: 'Route / destination',
                        value: pass.route,
                      ),
                      PassInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Start date',
                        value: _dateFormat.format(pass.startDate),
                      ),
                      PassInfoRow(
                        icon: Icons.event_busy_outlined,
                        label: 'Expiry date',
                        value: _dateFormat.format(pass.expiryDate),
                      ),
                      PassInfoRow(
                        icon: Icons.tag,
                        label: 'Pass ID',
                        value: pass.passId,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Renew / Update Pass',
            icon: Icons.autorenew_rounded,
            filled: false,
            onPressed: _goToCreate,
          ),
        ],
      ),
    );
  }
}
