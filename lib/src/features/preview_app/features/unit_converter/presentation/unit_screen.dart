import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../logic/unit_provider.dart';
import '../../../../preview_app/logic/preview_provider.dart';

class UnitScreen extends StatelessWidget {
  const UnitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final platform = context.watch<PlatformProvider>();

    return platform.isMaterialPlatform ? _buildMaterial(context) : _buildCupertino(context);
  }

  // ================= ANDROID =================
  Widget _buildMaterial(BuildContext context) {
    final isTablet = context.watch<PlatformProvider>().isTabletPlatform;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convert-It All', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
      ),
      body: isTablet ? _buildSplit(context, true) : _buildBody(context, true),
    );
  }

  // ================= IOS =================
  Widget _buildCupertino(BuildContext context) {
    final isTablet = context.watch<PlatformProvider>().isTabletPlatform;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Convert-It All', style: TextStyle(fontWeight: FontWeight.w900)),
        leading: CupertinoButton(padding: EdgeInsets.zero, child: const Icon(CupertinoIcons.back), onPressed: () => context.go('/')),
      ),
      child: SafeArea(child: isTablet ? _buildSplit(context, false) : _buildBody(context, false)),
    );
  }

  // ================= BODY =================
  Widget _buildBody(BuildContext context, bool isAndroid) {
    return Consumer<UnitProvider>(
      builder: (_, p, _) {
        return Container(
          color: isAndroid ? null : CupertinoColors.systemGroupedBackground.resolveFrom(context),
          child: Column(
            children: [
              _categoryTabs(context, p, isAndroid),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _card(context, child: _inputSection(context, p, isAndroid), isAndroid: isAndroid),
                    const SizedBox(height: 16),
                    Center(child: _swapButton(context, p, isAndroid)),
                    const SizedBox(height: 16),
                    _card(context, child: _resultSection(context, p, isAndroid), isAndroid: isAndroid),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= SPLIT =================
  Widget _buildSplit(BuildContext context, bool isAndroid) {
    return Consumer<UnitProvider>(
      builder: (context, p, child) {
        return Row(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _categoryTabs(context, p, isAndroid),
                  const SizedBox(height: 16),
                  _card(context, child: _inputSection(context, p, isAndroid), isAndroid: isAndroid),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [_card(context, child: _resultSection(context, p, isAndroid), isAndroid: isAndroid)],
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= CATEGORY =================
  Widget _categoryTabs(BuildContext context, UnitProvider p, bool isAndroid) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: isAndroid
          ? SegmentedButton<UnitCategory>(
              segments: UnitCategory.values.map((e) => ButtonSegment(value: e, label: Text(e.name))).toList(),
              selected: {p.category},
              onSelectionChanged: (v) => p.updateCategory(v.first),
            )
          : CupertinoSlidingSegmentedControl<UnitCategory>(
              groupValue: p.category,
              children: {for (var e in UnitCategory.values) e: Text(e.name.toUpperCase())},
              onValueChanged: (v) {
                if (v != null) p.updateCategory(v);
              },
            ),
    );
  }

  // ================= INPUT =================
  Widget _inputSection(BuildContext context, UnitProvider p, bool isAndroid) {
    final textColor = isAndroid ? Theme.of(context).colorScheme.onSurface : CupertinoColors.label.resolveFrom(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("FROM", style: TextStyle(color: isAndroid ? Colors.grey : CupertinoColors.systemGrey.resolveFrom(context))),
        const SizedBox(height: 10),

        _dropdown(context, p.fromUnit, p.units, p.updateFromUnit, isAndroid),

        const SizedBox(height: 20),

        isAndroid
            ? TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                decoration: const InputDecoration(hintText: '0.00', border: InputBorder.none),
                onChanged: p.updateInput,
              )
            : CupertinoTextField(
                keyboardType: TextInputType.number,
                placeholder: '0.00',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                decoration: BoxDecoration(color: CupertinoColors.systemGrey6.resolveFrom(context), borderRadius: BorderRadius.circular(10)),
                onChanged: p.updateInput,
              ),
      ],
    );
  }

  // ================= RESULT =================
  Widget _resultSection(BuildContext context, UnitProvider p, bool isAndroid) {
    final primary = isAndroid ? Theme.of(context).colorScheme.primary : CupertinoColors.activeBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("TO", style: TextStyle(color: isAndroid ? Colors.grey : CupertinoColors.systemGrey.resolveFrom(context))),
        const SizedBox(height: 10),

        _dropdown(context, p.toUnit, p.units, p.updateToUnit, isAndroid),

        const SizedBox(height: 20),

        Text(
          p.result.toStringAsFixed(4),
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary),
        ),
      ],
    );
  }

  // ================= DROPDOWN =================
  Widget _dropdown(BuildContext context, String value, List<String> items, ValueChanged<String> onChanged, bool isAndroid) {
    if (isAndroid) {
      return DropdownButtonFormField(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => onChanged(v!),
      );
    }

    return GestureDetector(
      onTap: () => _showPicker(context, value, items, onChanged),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: CupertinoColors.systemGrey6.resolveFrom(context), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: TextStyle(color: CupertinoColors.label.resolveFrom(context))),
            const Icon(CupertinoIcons.chevron_down),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, String current, List<String> items, ValueChanged<String> onChanged) {
    showCupertinoModalPopup(
      context: context,
      useRootNavigator: false,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            itemExtent: 32,
            scrollController: FixedExtentScrollController(initialItem: items.indexOf(current)),
            onSelectedItemChanged: (i) => onChanged(items[i]),
            children: items.map((e) => Center(child: Text(e))).toList(),
          ),
        ),
      ),
    );
  }

  // ================= SWAP =================
  Widget _swapButton(BuildContext context, UnitProvider p, bool isAndroid) {
    final primary = isAndroid ? Theme.of(context).colorScheme.onPrimaryFixed : CupertinoColors.activeBlue;

    return GestureDetector(
      onTap: p.swap,
      child: CircleAvatar(
        radius: 26,
        backgroundColor: primary,
        child: const Icon(Icons.swap_vert, color: Colors.white),
      ),
    );
  }

  // ================= CARD =================
  Widget _card(BuildContext context, {required Widget child, required bool isAndroid}) {
    if (isAndroid) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context), borderRadius: BorderRadius.circular(12)),
        child: child,
      );
    }
  }
}
