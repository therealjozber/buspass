import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/bus_pass.dart';

/// Result of validating a scanned QR code.
enum _ScanResult { valid, expired, invalid }

/// Uses the camera to scan a bus pass QR code and reports whether the pass is
/// valid, expired or not recognised by this app.
class ScanPassScreen extends StatefulWidget {
  const ScanPassScreen({super.key});

  @override
  State<ScanPassScreen> createState() => _ScanPassScreenState();
}

class _ScanPassScreenState extends State<ScanPassScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final _dateFormat = DateFormat('dd MMM yyyy');

  // Guards against the dialog opening multiple times for one scan.
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    // Stop scanning immediately so the camera does not keep firing.
    _handled = true;
    await _controller.stop();

    BusPass? pass;
    try {
      pass = BusPass.fromJsonString(raw);
    } catch (_) {
      pass = null;
    }

    final _ScanResult result;
    if (pass == null) {
      result = _ScanResult.invalid;
    } else if (pass.isExpired) {
      result = _ScanResult.expired;
    } else {
      result = _ScanResult.valid;
    }

    if (!mounted) return;
    await _showResultDialog(result, pass);
  }

  Future<void> _showResultDialog(_ScanResult result, BusPass? pass) async {
    final (IconData icon, Color color, String title) = switch (result) {
      _ScanResult.valid => (Icons.check_circle, Colors.green, 'Valid Pass'),
      _ScanResult.expired => (
          Icons.cancel,
          Colors.orange,
          'Expired Pass',
        ),
      _ScanResult.invalid => (
          Icons.error,
          Colors.red,
          'Invalid Pass',
        ),
    };

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: Icon(icon, color: color, size: 48),
          title: Text(title, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pass != null) ...[
                _dialogLine('Name', pass.fullName),
                _dialogLine('Route', pass.route),
                _dialogLine('Type', pass.passType),
                _dialogLine('Expiry', _dateFormat.format(pass.expiryDate)),
              ] else
                const Text(
                  'This QR code is not a valid Smart Bus Pass.',
                  textAlign: TextAlign.center,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resumeScanning();
              },
              child: const Text('Scan Again'),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _resumeScanning() async {
    await _controller.start();
    if (mounted) setState(() => _handled = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Scan / Validate Pass')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) {
                    return _CameraError(error: error);
                  },
                ),
                // Simple viewfinder overlay.
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: theme.colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(16),
            child: Text(
              'Point the camera at a bus pass QR code to validate it.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the camera cannot be started (e.g. permission denied).
class _CameraError extends StatelessWidget {
  final MobileScannerException error;

  const _CameraError({required this.error});

  @override
  Widget build(BuildContext context) {
    final message = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied =>
        'Camera permission denied. Please allow camera access in settings.',
      MobileScannerErrorCode.unsupported =>
        'Scanning is not supported on this device.',
      _ => 'Could not start the camera. Please try again.',
    };

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: Colors.white70,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
