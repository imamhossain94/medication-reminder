import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/bootstrap_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

/// Shown while the app prepares the local database, and the place the user lands
/// on when the download fails.
class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BootstrapController controller = Get.find<BootstrapController>();

    return Scaffold(
      backgroundColor: brandPrimaryDark,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _AnimatedBackdrop()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const _Logo(),
                      const SizedBox(height: 30),
                      Text(
                        appName,
                        textAlign: TextAlign.center,
                        style: displayStyle(
                          30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        appTagline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: kBodyFont,
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 44),
                      Obx(() {
                        // Read the observables here so GetX tracks them.
                        return _ProgressPanel(
                          progress: controller.progress.value,
                          status: controller.statusText.value,
                          detail: controller.detailText.value,
                          stage: controller.stage.value,
                          error: controller.error.value,
                          onRetry: controller.retry,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackdrop extends StatefulWidget {
  const _AnimatedBackdrop();

  @override
  State<_AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<_AnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          painter: _BubblePainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    const List<List<double>> seeds = <List<double>>[
      <double>[0.12, 0.18, 0.20],
      <double>[0.78, 0.12, 0.13],
      <double>[0.62, 0.72, 0.24],
      <double>[0.22, 0.82, 0.16],
      <double>[0.88, 0.55, 0.10],
    ];

    for (int i = 0; i < seeds.length; i++) {
      final List<double> s = seeds[i];
      final double dx = s[0] * size.width;
      final double dy = s[1] * size.height;
      final double r = s[2] * size.shortestSide;
      final double phase = (t + i * 0.2) % 1.0;
      final double drift = math.sin(phase * math.pi * 2) * 18;

      paint.color = Colors.white.withValues(alpha: 0.045 + 0.02 * (i % 3));
      canvas.drawCircle(Offset(dx + drift, dy - drift * 0.5), r, paint);
    }
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) => oldDelegate.t != t;
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 108,
        width: 108,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Colors.white, Color(0xFFEDE7FF)],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.favorite_rounded, size: 54, color: brandPrimary),
        ),
      ),
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({
    required this.progress,
    required this.status,
    required this.detail,
    required this.stage,
    required this.error,
    required this.onRetry,
  });

  final double progress;
  final String status;
  final String detail;
  final BootstrapStage stage;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(brandSecondary),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: kBodyFont,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            if (detail.isNotEmpty) ...<Widget>[
              const SizedBox(width: 8),
              Text(
                detail,
                style: const TextStyle(
                  fontFamily: kBodyFont,
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ],
          ],
        ),
        if (stage == BootstrapStage.failed) ...<Widget>[
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'The medicine library could not be downloaded.',
                  style: TextStyle(
                    fontFamily: kBodyFont,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  error ?? '',
                  style: const TextStyle(
                    fontFamily: kBodyFont,
                    fontSize: 11.5,
                    height: 1.4,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse(medicineDbRepoUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.open_in_new, size: 16, color: Colors.white),
                  label: const Text(
                    'Open $medicineDbRepo',
                    style: TextStyle(
                      fontFamily: kBodyFont,
                      color: Colors.white,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: brandPrimaryDark,
            ),
          ),
        ],
      ],
    );
  }
}
