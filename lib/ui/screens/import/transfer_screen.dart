import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/transfer_service.dart';
import '../../widgets/app_snackbar.dart';

/// One-time device transfer screen for free users.
///
/// Two modes:
///   - SEND: Generates a transfer code + QR, packages all local data
///   - RECEIVE: Scan QR or enter code, downloads data bundle
///
/// Route: context.push('/transfer')
class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  // 0 = pick mode, 1 = sending, 2 = receiving
  int _step = 0;

  static bool get _isDesktop {
    if (kIsWeb) return false;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  static String get _targetDevice => _isDesktop ? 'mobile app' : 'desktop';
  static String get _currentDevice => _isDesktop ? 'desktop' : 'this device';

  // SEND state
  String? _transferCode;
  bool _isSending = false;
  bool _sendReady = false;
  String? _sendError;
  int _recipesCount = 0;
  int _cookbooksCount = 0;

  // RECEIVE state
  final _codeController = TextEditingController();
  bool _isReceiving = false;
  String? _receiveError;
  bool _receiveSuccess = false;
  int _importedCount = 0;
  bool _didRestoreAuth = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step == 0) {
              Navigator.pop(context);
            } else {
              setState(() => _step = 0);
            }
          },
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _step == 0
              ? _buildModePicker(theme)
              : _step == 1
              ? _buildSendMode(theme)
              : _buildReceiveMode(theme),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  MODE PICKER
  // ════════════════════════════════════════════════════════════════

  Widget _buildModePicker(ThemeData theme) {
    return Padding(
      key: const ValueKey('picker'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Icon(Icons.swap_horiz_rounded, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 20),
          Text(
            'Transfer your recipes',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Move all your recipes, cookbooks, and meal plans '
                'from $_currentDevice to your $_targetDevice. '
                'This is a one-time copy, not a sync.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _ModeCard(
            icon: Icons.upload_rounded,
            title: 'Send from $_currentDevice',
            subtitle: 'Generate a code for your $_targetDevice to receive',
            color: theme.colorScheme.primary,
            theme: theme,
            onTap: () {
              setState(() => _step = 1);
              _prepareSend();
            },
          ),
          const SizedBox(height: 16),
          _ModeCard(
            icon: Icons.download_rounded,
            title: 'Receive on $_currentDevice',
            subtitle: 'Enter a code or scan QR from the sending device',
            color: theme.colorScheme.tertiary,
            theme: theme,
            onTap: () => setState(() => _step = 2),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_sync, size: 20, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Want automatic sync? Upgrade to Premium for cloud sync across all your devices.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  SEND MODE
  // ════════════════════════════════════════════════════════════════

  Future<void> _prepareSend() async {
    setState(() { _isSending = true; _sendError = null; });
    try {
      final result = await TransferService.instance.createTransfer();
      if (mounted) {
        setState(() {
          _transferCode = result.code;
          _isSending = false;
          _sendReady = true;
          _recipesCount = result.recipesCount;
          _cookbooksCount = result.cookbooksCount;
        });
      }
    } catch (e) {
      debugPrint('[Transfer] Send failed: $e');
      if (mounted) {
        setState(() {
          _isSending = false;
          _sendError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Widget _buildSendMode(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return SingleChildScrollView(
      key: const ValueKey('send'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (_isSending) ...[
            const SizedBox(height: 60),
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text('Preparing your data...', style: theme.textTheme.titleMedium),
          ] else if (_sendError != null) ...[
            const SizedBox(height: 40),
            Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Transfer failed', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_sendError!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(onPressed: _prepareSend, icon: const Icon(Icons.refresh), label: const Text('Try Again')),
          ] else if (_sendReady) ...[
            // ── Real QR Code ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: QrImageView(
                data: _transferCode ?? '',
                version: QrVersions.auto,
                size: 180,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text('Scan this QR on your other device,\nor enter the code below.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_transferCode ?? '',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 6, fontFamily: 'monospace')),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _transferCode ?? ''));
                      AppSnackbar.success(context, 'Code copied!');
                    },
                    icon: const Icon(Icons.copy, size: 20),
                    tooltip: 'Copy code',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text('Ready to transfer', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _dataStat(Icons.restaurant, '$_recipesCount', 'Recipes', theme),
                      _dataStat(Icons.menu_book, '$_cookbooksCount', 'Cookbooks', theme),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 16, color: theme.colorScheme.outline),
                const SizedBox(width: 6),
                Text('This code expires in 15 minutes',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _dataStat(IconData icon, String count, String label, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(count, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  RECEIVE MODE
  // ════════════════════════════════════════════════════════════════

  Widget _buildReceiveMode(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    if (_receiveSuccess) {
      return Center(
        key: const ValueKey('receive-success'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 48, color: Colors.green),
              ),
              const SizedBox(height: 24),
              Text('Transfer complete!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('$_importedCount items imported successfully.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              if (_didRestoreAuth) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_circle, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text('Account signed in from sender',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      key: const ValueKey('receive'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 160,
            child: Material(
              color: isDark ? theme.colorScheme.surfaceContainerHigh : theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _scanQR,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner, size: 56, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('Scan QR Code', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Point your camera at the QR on the other device',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, letterSpacing: 1.5)),
              ),
              Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Enter transfer code', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: theme.textTheme.headlineSmall?.copyWith(letterSpacing: 6, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: '------', counterText: '',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              errorText: _receiveError,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
              UpperCaseTextFormatter(),
            ],
            onChanged: (_) {
              if (_receiveError != null) setState(() => _receiveError = null);
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isReceiving ? null : _submitCode,
              child: _isReceiving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Import Data'),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What gets transferred:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _transferItem(Icons.restaurant, 'All recipes', theme),
                _transferItem(Icons.menu_book, 'Cookbooks & categories', theme),
                _transferItem(Icons.calendar_month, 'Meal plans', theme),
                _transferItem(Icons.shopping_cart, 'Shopping lists', theme),
                _transferItem(Icons.settings, 'App settings', theme),
                _transferItem(Icons.account_circle, 'Account sign-in (if sender is logged in)', theme),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: theme.colorScheme.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Existing data on this device will be merged. Duplicates are skipped.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _transferItem(IconData icon, String label, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  QR SCANNER
  // ════════════════════════════════════════════════════════════════

  void _scanQR() {
    if (_isDesktop) {
      AppSnackbar.info(context, AppLocalizations.of(context)!.qrScanningMobileOnly);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _QRScannerPage(
          onCodeScanned: (code) {
            Navigator.pop(context);
            _codeController.text = code.toUpperCase();
            _receiveData(code.toUpperCase());
          },
        ),
      ),
    );
  }

  Future<void> _submitCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _receiveError = 'Code must be 6 characters');
      return;
    }
    await _receiveData(code);
  }

  Future<void> _receiveData(String code) async {
    setState(() { _isReceiving = true; _receiveError = null; });
    try {
      final result = await TransferService.instance.claimTransfer(code);

      bool didAuth = false;
      if (result.authToken != null &&
          result.userId != null &&
          !AuthService.instance.isSignedIn) {
        didAuth = await ref.read(authProvider.notifier).restoreFromTransfer(
          token: result.authToken!,
          userId: result.userId!,
          displayName: result.displayName,
          email: result.email,
          avatarUrl: result.avatarUrl,
        );
      }

      if (mounted) {
        setState(() {
          _isReceiving = false;
          _receiveSuccess = true;
          _importedCount = result.importedCount;
          _didRestoreAuth = didAuth;
        });
      }
    } catch (e) {
      debugPrint('[Transfer] Receive failed: $e');
      if (mounted) {
        setState(() {
          _isReceiving = false;
          _receiveError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  QR SCANNER PAGE (full-screen camera with overlay)
// ═══════════════════════════════════════════════════════════════════

class _QRScannerPage extends StatefulWidget {
  final ValueChanged<String> onCodeScanned;
  const _QRScannerPage({required this.onCodeScanned});

  @override
  State<_QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<_QRScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _hasScanned = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          _ScannerOverlay(theme: theme),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      await _controller.toggleTorch();
                      if (mounted) setState(() => _torchOn = !_torchOn);
                    },
                    icon: Icon(
                      _torchOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom label
          Positioned(
            bottom: 80, left: 0, right: 0,
            child: Text('Point at the QR code on the sending device',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.isEmpty) continue;
      final code = value.trim().toUpperCase();
      if (RegExp(r'^[A-Z0-9]{6}$').hasMatch(code)) {
        _hasScanned = true;
        HapticFeedback.mediumImpact();
        widget.onCodeScanned(code);
        return;
      }
    }
  }
}

/// Dark overlay with a transparent cutout for the scan area.
class _ScannerOverlay extends StatelessWidget {
  final ThemeData theme;
  const _ScannerOverlay({required this.theme});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final scanSize = constraints.maxWidth * 0.65;
      final left = (constraints.maxWidth - scanSize) / 2;
      final top = (constraints.maxHeight - scanSize) / 2 - 40;

      return Stack(
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
            child: Stack(
              children: [
                Container(decoration: const BoxDecoration(color: Colors.black, backgroundBlendMode: BlendMode.dstOut)),
                Positioned(
                  left: left, top: top,
                  child: Container(
                    width: scanSize, height: scanSize,
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
          ..._buildCorners(left, top, scanSize, constraints.maxHeight),
        ],
      );
    });
  }

  List<Widget> _buildCorners(double left, double top, double size, double totalH) {
    final bottom = totalH - top - size;
    return [
      Positioned(left: left, top: top, child: _corner(true, true)),
      Positioned(right: left, top: top, child: _corner(true, false)),
      Positioned(left: left, bottom: bottom, child: _corner(false, true)),
      Positioned(right: left, bottom: bottom, child: _corner(false, false)),
    ];
  }

  Widget _corner(bool isTop, bool isLeft) {
    return SizedBox(
      width: 32, height: 32,
      child: CustomPaint(painter: _CornerPainter(color: theme.colorScheme.primary, isTop: isTop, isLeft: isLeft)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final bool isTop;
  final bool isLeft;
  _CornerPainter({required this.color, required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 3..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final path = Path();
    const len = 24.0;
    if (isTop && isLeft) {
      path.moveTo(0, len); path.lineTo(0, 4); path.quadraticBezierTo(0, 0, 4, 0); path.lineTo(len, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(size.width - len, 0); path.lineTo(size.width - 4, 0); path.quadraticBezierTo(size.width, 0, size.width, 4); path.lineTo(size.width, len);
    } else if (!isTop && isLeft) {
      path.moveTo(0, size.height - len); path.lineTo(0, size.height - 4); path.quadraticBezierTo(0, size.height, 4, size.height); path.lineTo(len, size.height);
    } else {
      path.moveTo(size.width, size.height - len); path.lineTo(size.width, size.height - 4); path.quadraticBezierTo(size.width, size.height, size.width - 4, size.height); path.lineTo(size.width - len, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════
//  MODE CARD
// ═══════════════════════════════════════════════════════════════════

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ModeCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: isDark ? theme.colorScheme.surfaceContainerHigh : theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TEXT FORMATTER (uppercase)
// ═══════════════════════════════════════════════════════════════════

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}