import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';

/// What a camera scanner shows when the camera or the barcode reader could
/// not start: a plain message instead of the raw Java error, and Try again.
/// Without camera access it says where to allow it.
class ScannerErrorView extends StatelessWidget {
  final MobileScannerException error;
  final VoidCallback onRetry;

  const ScannerErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Space.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  denied ? Icons.no_photography_outlined : Icons.videocam_off_outlined,
                  size: 40,
                  color: Colors.white70,
                ),
                const SizedBox(height: Space.md),
                Text(
                  denied ? l10n.scannerCameraDenied : l10n.scannerCameraError,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.35),
                ),
                if (!denied) ...[
                  const SizedBox(height: Space.lg),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(l10n.tryAgain),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// [child] (the scan window and hints drawn over the camera) while the
/// scanner works; nothing while it shows [ScannerErrorView], so the message
/// and Try again are not covered.
class HideOnScannerError extends StatelessWidget {
  final MobileScannerController controller;
  final Widget child;

  const HideOnScannerError({super.key, required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controller,
      builder: (context, state, child) => state.error != null ? const SizedBox.shrink() : child!,
      child: child,
    );
  }
}

/// Stops and starts [controller] again, for [ScannerErrorView]'s Try again.
Future<void> restartScanner(MobileScannerController controller) async {
  try {
    await controller.stop();
  } catch (_) {}
  try {
    await controller.start();
  } catch (_) {
    // The scanner shows its error again through errorBuilder.
  }
}
