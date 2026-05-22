import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../logic/bmi_provider.dart';
import '../../../../preview_app/logic/preview_provider.dart';

class BmiScreen extends StatelessWidget {
  const BmiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final platform = context.watch<PlatformProvider>();

    return platform.isMaterialPlatform ? _buildMaterialUI(context) : _buildCupertinoUI(context);
  }

  // ================= ANDROID =================
  Widget _buildMaterialUI(BuildContext context) {
    final isTablet = context.watch<PlatformProvider>().isTabletPlatform;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Metrics', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
      ),
      body: isTablet ? _buildSplitBody(context, true) : _buildBody(context, true),
    );
  }

  // ================= IOS =================
  Widget _buildCupertinoUI(BuildContext context) {
    final isTablet = context.watch<PlatformProvider>().isTabletPlatform;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Body Metrics', style: TextStyle(fontWeight: FontWeight.w900)),
        leading: CupertinoButton(padding: EdgeInsets.zero, child: const Icon(CupertinoIcons.back), onPressed: () => context.go('/')),
      ),
      child: SafeArea(bottom: false,child: isTablet ? _buildSplitBody(context, false) : _buildBody(context, false)),
    );
  }

  // ================= BODY =================
  Widget _buildBody(BuildContext context, bool isAndroid) {
    return Consumer<BmiProvider>(
      builder: (context, provider, _) {
        return Container(
          color: isAndroid ? null : CupertinoColors.systemGroupedBackground.resolveFrom(context),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildGenderToggle(provider, isAndroid),
              const SizedBox(height: 16),
              _buildGaugeCard(context,provider, isAndroid),
              const SizedBox(height: 16),
              _buildMetrics(context,provider, isAndroid),
              const SizedBox(height: 16),
              _buildHealthTip(context,isAndroid),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSplitBody(BuildContext context, bool isAndroid) {
    return Consumer<BmiProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            Expanded(
              child: ListView(padding: const EdgeInsets.all(16), children: [_buildGenderToggle(provider, isAndroid), const SizedBox(height: 16), _buildMetrics(context,provider, isAndroid)]),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.all(16), children: [_buildGaugeCard(context,provider, isAndroid), const SizedBox(height: 16), _buildHealthTip(context,isAndroid)]),
            ),
          ],
        );
      },
    );
  }

  // ================= GENDER =================
  Widget _buildGenderToggle(BmiProvider provider, bool isAndroid) {
    if (isAndroid) {
      return SegmentedButton<Gender>(
        segments: const [
          ButtonSegment(value: Gender.male, label: Text('Male')),
          ButtonSegment(value: Gender.female, label: Text('Female')),
        ],
        selected: {provider.gender},
        onSelectionChanged: (val) => provider.updateGender(val.first),
      );
    } else {
      return CupertinoSlidingSegmentedControl<Gender>(
        groupValue: provider.gender,
        children: const {Gender.male: Text('Male'), Gender.female: Text('Female')},
        onValueChanged: (val) {
          if (val != null) provider.updateGender(val);
        },
      );
    }
  }

  // ================= GAUGE =================
  Widget _buildGaugeCard(BuildContext context,BmiProvider provider, bool isAndroid) {
    return _platformCard(
      context,
      isAndroid: isAndroid,
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: provider.bmi / 40),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, _) {
              return CustomPaint(
                size: const Size(180, 180),
                painter: _RingPainter(progress: value, color: provider.categoryColor, isAndroid: isAndroid),
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.bmi.toStringAsFixed(1),
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: provider.categoryColor),
                        ),
                        Text(provider.category, style: TextStyle(color: isAndroid ? Colors.grey : CupertinoColors.systemGrey)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text('Ideal: ${provider.idealWeight.toStringAsFixed(1)} kg'),
        ],
      ),
    );
  }

  // ================= METRICS =================
  Widget _buildMetrics(BuildContext context,BmiProvider provider, bool isAndroid) {
    return Column(
      children: [
        _slider(context,'Age', provider.age.toDouble(), 10, 100, (v) => provider.updateAge(v), isAndroid),
        _slider(context,'Height', provider.height, 100, 250, (v) => provider.updateHeight(v), isAndroid),
        _slider(context,'Weight', provider.weight, 30, 200, (v) => provider.updateWeight(v), isAndroid),
      ],
    );
  }

  Widget _slider(BuildContext context,String label, double value, double min, double max, ValueChanged<double> onChanged, bool isAndroid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: _platformCard(
        context,
        isAndroid: isAndroid,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value.toInt().toString())]),
            const SizedBox(height: 8),
            isAndroid ? Slider(value: value, min: min, max: max, onChanged: onChanged) : SizedBox(width:double.infinity,child: CupertinoSlider(value: value, min: min, max: max, onChanged: onChanged)),
          ],
        ),
      ),
    );
  }

  // ================= TIP =================
  Widget _buildHealthTip(BuildContext context,bool isAndroid) {
    return _platformCard(
      context,
      isAndroid: isAndroid,
      child: Row(
        children: [
          Icon(isAndroid ? Icons.lightbulb : CupertinoIcons.lightbulb, color: Colors.amber),
          const SizedBox(width: 10),
          const Expanded(child: Text('Healthy BMI: 18.5 - 24.9. Maintain diet & exercise.')),
        ],
      ),
    );
  }

  // ================= PLATFORM CARD =================
  Widget _platformCard(BuildContext context,{required Widget child, required bool isAndroid}) {
    if (isAndroid) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      );
    } else {
      return Container(
        decoration: BoxDecoration(color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context), borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(16),
        child: child,
      );
    }
  }
}

// ================= RING PAINTER =================
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isAndroid;

  _RingPainter({required this.progress, required this.color, required this.isAndroid});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 12.0;
    final rect = Offset.zero & size;

    final bg = Paint()
      ..color = isAndroid ? Colors.grey.withOpacity(0.2) : CupertinoColors.systemGrey4
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    canvas.drawArc(rect, 0, 2 * pi, false, bg);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => true;
}
