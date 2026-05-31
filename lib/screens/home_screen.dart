import 'package:flutter/material.dart';

import '../widgets/primary_button.dart';
import 'create_pass_screen.dart';
import 'scan_pass_screen.dart';
import 'view_pass_screen.dart';

/// The landing screen with the app title, a short description and the three
/// main actions: create/renew, view and scan.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App logo (BP lettermark)
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'BP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bus Pass',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Create, renew and carry your bus pass digitally. '
                'No paper, no queues — just scan and go.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Create / Renew Bus Pass',
                icon: Icons.add_card_rounded,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CreatePassScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'View My Bus Pass',
                icon: Icons.badge_rounded,
                filled: false,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ViewPassScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Scan / Validate Pass',
                icon: Icons.qr_code_scanner_rounded,
                filled: false,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ScanPassScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Passengers manage their pass; operators scan it to '
                          'validate. Everything works fully offline.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
