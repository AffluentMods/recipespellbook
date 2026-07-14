import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Where a recipe link came from. Used to show friendly, brand-accurate
/// visuals on the import screen ("Instagram link detected") and the import
/// preview ("Imported from Instagram").
enum RecipePlatform { instagram, tiktok, youtube, pinterest, facebook, website }

/// Detect the platform from a pasted URL. Returns null when the text isn't a
/// link yet (so callers can hide the badge until there's something to show).
RecipePlatform? detectPlatform(String? raw) {
  if (raw == null) return null;
  final s = raw.trim().toLowerCase();
  if (s.isEmpty) return null;
  bool has(String frag) => s.contains(frag);
  if (has('instagram.com') || has('instagr.am')) return RecipePlatform.instagram;
  if (has('tiktok.com') || has('vm.tiktok')) return RecipePlatform.tiktok;
  if (has('youtube.com') || has('youtu.be')) return RecipePlatform.youtube;
  if (has('pinterest.') || has('pin.it')) return RecipePlatform.pinterest;
  if (has('facebook.com') || has('fb.watch') || has('fb.com')) return RecipePlatform.facebook;
  // Anything else that looks like a link → a generic website.
  if (has('http://') || has('https://') || has('www.') || RegExp(r'[a-z0-9-]+\.[a-z]{2,}').hasMatch(s)) {
    return RecipePlatform.website;
  }
  return null;
}

class PlatformInfo {
  final String name;          // "Instagram"
  final List<Color> gradient; // brand gradient (badge tint + strip)
  const PlatformInfo(this.name, this.gradient);
}

const _instaGradient = [
  Color(0xFFFEDA77), Color(0xFFF58529), Color(0xFFDD2A7B),
  Color(0xFF8134AF), Color(0xFF515BD4),
];

PlatformInfo platformInfo(RecipePlatform p) {
  switch (p) {
    case RecipePlatform.instagram:
      return const PlatformInfo('Instagram', _instaGradient);
    case RecipePlatform.tiktok:
      return const PlatformInfo('TikTok', [Color(0xFF25F4EE), Color(0xFF000000), Color(0xFFFE2C55)]);
    case RecipePlatform.youtube:
      return const PlatformInfo('YouTube', [Color(0xFFFF4E45), Color(0xFFFF0000)]);
    case RecipePlatform.pinterest:
      return const PlatformInfo('Pinterest', [Color(0xFFE60023), Color(0xFFAD081B)]);
    case RecipePlatform.facebook:
      return const PlatformInfo('Facebook', [Color(0xFF1877F2), Color(0xFF0A5DC2)]);
    case RecipePlatform.website:
      return const PlatformInfo('the web', [Color(0xFF57A773), Color(0xFF3E7D57)]);
  }
}

/// A brand-accurate square logo drawn in pure Flutter (no SVG dependency).
class PlatformLogo extends StatelessWidget {
  final RecipePlatform platform;
  final double size;
  const PlatformLogo(this.platform, {super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.28;
    switch (platform) {
      case RecipePlatform.instagram:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: _instaGradient,
            ),
          ),
          child: CustomPaint(painter: _InstaGlyph(color: Colors.white, size: size)),
        );
      case RecipePlatform.tiktok:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(radius)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(-size * 0.045, size * 0.02),
                child: Icon(Icons.music_note_rounded, size: size * 0.52, color: const Color(0xFF25F4EE)),
              ),
              Transform.translate(
                offset: Offset(size * 0.045, -size * 0.02),
                child: Icon(Icons.music_note_rounded, size: size * 0.52, color: const Color(0xFFFE2C55)),
              ),
              Icon(Icons.music_note_rounded, size: size * 0.52, color: Colors.white),
            ],
          ),
        );
      case RecipePlatform.youtube:
        return Container(
          width: size,
          height: size * 0.72,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFFFF0000), borderRadius: BorderRadius.circular(radius * 0.9)),
          child: CustomPaint(size: Size(size * 0.34, size * 0.34), painter: _PlayTriangle(Colors.white)),
        );
      case RecipePlatform.pinterest:
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Color(0xFFE60023), shape: BoxShape.circle),
          child: Text('P',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.6,
                  height: 1)),
        );
      case RecipePlatform.facebook:
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFF1877F2), borderRadius: BorderRadius.circular(radius)),
          child: Text('f',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.62,
                  height: 1.1)),
        );
      case RecipePlatform.website:
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF57A773), Color(0xFF3E7D57)],
            ),
          ),
          child: Icon(Icons.language_rounded, color: Colors.white, size: size * 0.62),
        );
    }
  }
}

/// The Instagram camera glyph: rounded-square body, lens circle, flash dot.
class _InstaGlyph extends CustomPainter {
  final Color color;
  final double size;
  _InstaGlyph({required this.color, required this.size});

  @override
  void paint(Canvas canvas, Size s) {
    final stroke = size * 0.075;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final inset = size * 0.24;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(inset, inset, size - inset, size - inset),
      Radius.circular(size * 0.16),
    );
    canvas.drawRRect(body, p);
    canvas.drawCircle(Offset(size / 2, size / 2), size * 0.14, p);
    canvas.drawCircle(
      Offset(size - inset - size * 0.075, inset + size * 0.075),
      stroke * 0.62,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _InstaGlyph old) => old.color != color || old.size != size;
}

class _PlayTriangle extends CustomPainter {
  final Color color;
  _PlayTriangle(this.color);
  @override
  void paint(Canvas canvas, Size s) {
    final path = Path()
      ..moveTo(s.width * 0.12, 0)
      ..lineTo(s.width * 0.12, s.height)
      ..lineTo(s.width, s.height / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PlayTriangle old) => old.color != color;
}

/// A pill that reads "Imported from Instagram" (or "Instagram link") with the
/// brand logo and a soft brand-tinted background.
class PlatformBadge extends StatelessWidget {
  final RecipePlatform platform;
  final String? labelOverride;
  final bool compact;
  const PlatformBadge(this.platform, {super.key, this.labelOverride, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = platformInfo(platform);
    final tint = info.gradient.first;
    final label = labelOverride ?? 'Imported from ${info.name}';
    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: compact ? 7 : 10),
        decoration: BoxDecoration(
          color: Color.alphaBlend(tint.withValues(alpha: 0.12), theme.colorScheme.surface),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: tint.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlatformLogo(platform, size: compact ? 20 : 26),
            SizedBox(width: compact ? 8 : 10),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: (compact ? theme.textTheme.labelMedium : theme.textTheme.titleSmall)
                    ?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Decorative row of supported-platform logos for the import screen header.
class PlatformLogoStrip extends StatelessWidget {
  final double logoSize;
  const PlatformLogoStrip({super.key, this.logoSize = 38});

  static const _order = [
    RecipePlatform.instagram,
    RecipePlatform.tiktok,
    RecipePlatform.youtube,
    RecipePlatform.pinterest,
    RecipePlatform.website,
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Works with Instagram, TikTok, YouTube, Pinterest and any recipe website',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _order.length; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: logoSize * 0.14),
              child: Transform.rotate(
                angle: (i.isEven ? -1 : 1) * 0.04 * math.pi,
                child: PlatformLogo(_order[i], size: logoSize),
              ),
            ),
        ],
      ),
    );
  }
}
