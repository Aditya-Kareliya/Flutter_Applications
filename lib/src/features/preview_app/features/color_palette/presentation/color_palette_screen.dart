import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme_provider.dart';
import '../logic/color_palette_provider.dart';
import '../../../../preview_app/logic/preview_provider.dart';
import '../../qr_module/presentation/widgets/adaptive_widgets.dart'; // For showAdaptiveFeedback

class ColorPaletteScreen extends StatelessWidget {
  const ColorPaletteScreen({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final useCupertino = context.watch<PlatformProvider>().useCupertinoStyle;

    if (useCupertino) {
      return _CupertinoColorPalette(isTablet: _isTablet(context));
    } else {
      return _MaterialColorPalette(isTablet: _isTablet(context));
    }
  }
}

// --------------------- Shared Components ---------------------

class _ColorPreviewArea extends StatelessWidget {
  final ColorPaletteProvider provider;
  final bool isMaterial;

  const _ColorPreviewArea({required this.provider, required this.isMaterial});

  @override
  Widget build(BuildContext context) {
    final isDark = isMaterial
        ? Theme.of(context).brightness == Brightness.dark
        : CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: provider.hex));
                  showAdaptiveFeedback(
                    context,
                    'Color copied!',
                    isError: false,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: provider.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: provider.color.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Icon(
                      isMaterial
                          ? Icons.copy_rounded
                          : CupertinoIcons.doc_on_doc,
                      color: provider.color.computeLuminance() > 0.5
                          ? Colors.black54
                          : Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                provider.hex,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildColorCodeRow(
                'RGB',
                '${provider.color.red}, ${provider.color.green}, ${provider.color.blue}',
                isDark,
              ),
              const SizedBox(height: 4),
              _buildColorCodeRow('HSL', provider.hslString, isDark),
              const SizedBox(height: 4),
              _buildColorCodeRow('CMYK', provider.cmykString, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorCodeRow(String label, String value, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 140,
          child: Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccessibilityCard extends StatelessWidget {
  final ColorPaletteProvider provider;
  final bool isMaterial;

  const _AccessibilityCard({required this.provider, required this.isMaterial});

  bool _isDark(BuildContext context) {
    return isMaterial
        ? Theme.of(context).brightness == Brightness.dark
        : CupertinoTheme.brightnessOf(context) == Brightness.dark;
  }

  double _contrast(Color color) {
    try {
      return provider.contrastWith(color);
    } catch (_) {
      return 0;
    }
  }

  ContrastRating _rating(double contrast) {
    if (contrast >= 7) return ContrastRating.aaa;
    if (contrast >= 4.5) return ContrastRating.aa;
    return ContrastRating.fail;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);

    final onWhite = _contrast(Colors.white);
    final onBlack = _contrast(Colors.black);

    final titleColor = isDark ? Colors.white70 : Colors.black54;

    final title = Text(
      'ACCESSIBILITY (WCAG 2.0)',
      style: isMaterial
          ? Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 2,
              fontWeight: FontWeight.w800,
              color: titleColor,
            )
          : CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        title,
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _contrastBlock(
                context,
                label: "On White",
                bg: Colors.white,
                text: Colors.black87,
                contrast: onWhite,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _contrastBlock(
                context,
                label: "On Black",
                bg: Colors.black,
                text: Colors.white,
                contrast: onBlack,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _contrastBlock(
    BuildContext context, {
    required String label,
    required Color bg,
    required Color text,
    required double contrast,
  }) {
    final rating = _rating(contrast);

    final block = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(isMaterial ? 16 : 12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: provider.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Sample",
              style: TextStyle(
                color: provider.bestTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${contrast.toStringAsFixed(1)}:1",
                style: TextStyle(
                  color: text,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              _ratingBadge(rating),
            ],
          ),
        ],
      ),
    );

    /// Material vs Cupertino surface
    if (isMaterial) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: block,
      );
    } else {
      return CupertinoPopupSurface(isSurfacePainted: true, child: block);
    }
  }

  Widget _ratingBadge(ContrastRating rating) {
    final color = rating.color;

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        rating.label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (isMaterial) return badge;

    return DefaultTextStyle(
      style: const CupertinoThemeData().textTheme.textStyle,
      child: badge,
    );
  }
}

enum ContrastRating { aaa, aa, fail }

extension ContrastRatingExt on ContrastRating {
  String get label {
    switch (this) {
      case ContrastRating.aaa:
        return "AAA";
      case ContrastRating.aa:
        return "AA";
      case ContrastRating.fail:
        return "Fail";
    }
  }

  Color get color {
    switch (this) {
      case ContrastRating.aaa:
        return Colors.green;
      case ContrastRating.aa:
        return Colors.lightGreen;
      case ContrastRating.fail:
        return Colors.redAccent;
    }
  }
}

class _HarmoniesList extends StatelessWidget {
  final ColorPaletteProvider provider;
  final bool isMaterial;

  const _HarmoniesList({required this.provider, required this.isMaterial});

  @override
  Widget build(BuildContext context) {
    final isDark = isMaterial
        ? Theme.of(context).brightness == Brightness.dark
        : CupertinoTheme.brightnessOf(context) == Brightness.dark;

    final textColor = isDark ? Colors.white70 : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COLOR HARMONIES',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildHarmonyRow(
          context,
          'Complementary',
          provider.getComplementary(),
          provider,
          isDark,
        ),
        const SizedBox(height: 12),
        _buildHarmonyRow(
          context,
          'Split Complementary',
          provider.getSplitComplementary(),
          provider,
          isDark,
        ),
        const SizedBox(height: 12),
        _buildHarmonyRow(
          context,
          'Analogous',
          provider.getAnalogous(),
          provider,
          isDark,
        ),
        const SizedBox(height: 12),
        _buildHarmonyRow(
          context,
          'Triadic',
          provider.getTriadic(),
          provider,
          isDark,
        ),
        const SizedBox(height: 12),
        _buildHarmonyRow(
          context,
          'Tetradic',
          provider.getTetradic(),
          provider,
          isDark,
        ),
        const SizedBox(height: 12),
        _buildHarmonyRow(
          context,
          'Monochromatic',
          provider.getMonochromatic(),
          provider,
          isDark,
        ),
      ],
    );
  }

  Widget _buildHarmonyRow(
    BuildContext context,
    String title,
    List<Color> colors,
    ColorPaletteProvider provider,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        ...colors.map(
          (c) => Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: GestureDetector(
              onTap: () => _handleColorTap(context, c, provider),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleColorTap(
    BuildContext context,
    Color color,
    ColorPaletteProvider provider,
  ) {
    final hexStr =
        '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}';

    if (isMaterial) {
      showModalBottomSheet(
        context: context,
        useRootNavigator: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      hexStr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Set as Main Color'),
                onTap: () {
                  provider.updateColor(color);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Hex Code'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: hexStr));
                  showAdaptiveFeedback(context, 'Copied $hexStr');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    } else {
      showCupertinoModalPopup(
        context: context,
        useRootNavigator: false,
        builder: (context) => CupertinoActionSheet(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: CupertinoColors.systemGrey4),
                ),
              ),
              const SizedBox(width: 8),
              Text(hexStr),
            ],
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                provider.updateColor(color);
                Navigator.pop(context);
              },
              child: const Text('Set as Main Color'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: hexStr));
                showAdaptiveFeedback(context, 'Copied $hexStr');
                Navigator.pop(context);
              },
              child: const Text('Copy Hex Code'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
      );
    }
  }
}

class _HistorySection extends StatelessWidget {
  final ColorPaletteProvider provider;
  final bool isMaterial;

  const _HistorySection({required this.provider, required this.isMaterial});

  @override
  Widget build(BuildContext context) {
    if (provider.history.isEmpty) return const SizedBox.shrink();

    final isDark = isMaterial
        ? Theme.of(context).brightness == Brightness.dark
        : CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT COLORS',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: provider.history.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final c = provider.history[index];
              return GestureDetector(
                onTap: () {
                  // Reuse the identical logic from Harmonies
                  _HarmoniesList(
                    provider: provider,
                    isMaterial: isMaterial,
                  )._handleColorTap(context, c, provider);
                },
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black12,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --------------------- Material Implementation ---------------------

class _MaterialColorPalette extends StatelessWidget {
  final bool isTablet;

  const _MaterialColorPalette({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    return Consumer<ColorPaletteProvider>(
      builder: (context, provider, child) {
        final themeProvider = context.watch<ThemeProvider>();

        return Scaffold(
          extendBodyBehindAppBar: !isAndroid,
          appBar: AppBar(
            elevation: isAndroid ? null : 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/'),
            ),
            title: const Text(
              'Color Genius',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Apply as app Theme color',
                icon: const Icon(Icons.bolt_rounded),
                onPressed: () {
                  themeProvider.setSeedColor(provider.color);
                  themeProvider.registerGeneratedThemeColor(provider.color);
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: isTablet
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 11,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Palette insights',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Explore harmonies, relationships and your recent picks.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color
                                                ?.withOpacity(0.7),
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: ListView(
                                        children: [
                                          Card(
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: _HarmoniesList(
                                                provider: provider,
                                                isMaterial: true,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Card(
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: _HistorySection(
                                                provider: provider,
                                                isMaterial: true,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 10,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              'Live preview',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(height: 12),
                                            _ColorPreviewArea(
                                              provider: provider,
                                              isMaterial: true,
                                            ),
                                            const SizedBox(height: 24),
                                            Card(
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  20,
                                                ),
                                                child: _AccessibilityCard(
                                                  provider: provider,
                                                  isMaterial: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal: 24,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              isAndroid ? 14 : 30,
                                            ),
                                          ),
                                          backgroundColor: provider.color,
                                          foregroundColor:
                                              provider.color
                                                          .computeLuminance() >
                                                      0.5
                                                  ? Colors.black87
                                                  : Colors.white,
                                        ),
                                        icon: const Icon(
                                          Icons.auto_awesome_rounded,
                                        ),
                                        label: const Text(
                                          'Generate next palette',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: () {
                                          provider.generate();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Live preview',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      _ColorPreviewArea(
                                        provider: provider,
                                        isMaterial: true,
                                      ),
                                      const SizedBox(height: 24),
                                      Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: _AccessibilityCard(
                                            provider: provider,
                                            isMaterial: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: _HarmoniesList(
                                            provider: provider,
                                            isMaterial: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: _HistorySection(
                                            provider: provider,
                                            isMaterial: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 24,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        isAndroid ? 14 : 30,
                                      ),
                                    ),
                                    backgroundColor: provider.color,
                                    foregroundColor:
                                        provider.color.computeLuminance() > 0.5
                                            ? Colors.black87
                                            : Colors.white,
                                  ),
                                  icon: const Icon(Icons.auto_awesome_rounded),
                                  label: const Text(
                                    'Generate next palette',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    provider.generate();
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
      },
    );
  }
}

// --------------------- Cupertino Implementation ---------------------

class _CupertinoColorPalette extends StatelessWidget {
  final bool isTablet;

  const _CupertinoColorPalette({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorPaletteProvider>(
      builder: (context, provider, child) {
        final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
        final themeProvider = context.watch<ThemeProvider>();

        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          navigationBar: CupertinoNavigationBar(
            leading: CupertinoNavigationBarBackButton(
              onPressed: () => context.go('/'),
              color: themeProvider.seedColor,
            ),
            middle: const Text(
              'Color Genius',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
            trailing: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minSize: 32,
              onPressed: () {
                themeProvider.setSeedColor(provider.color);
                themeProvider.registerGeneratedThemeColor(provider.color);
              },
              child: Icon(
                CupertinoIcons.bolt_fill,
                size: 20,
                color: themeProvider.seedColor,
              ),
            ),
            backgroundColor: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGroupedBackground,
              context,
            ),
            border: const Border(
              bottom: BorderSide(color: CupertinoColors.transparent),
            ),
          ),
          child: SafeArea(
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: isTablet
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 11,
                          child: ListView(
                            children: [
                              Text(
                                'Designer harmonies',
                                style: CupertinoTheme.of(context)
                                    .textTheme
                                    .navTitleTextStyle
                                    .copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              CupertinoListSection.insetGrouped(
                                backgroundColor: CupertinoColors
                                    .systemBackground
                                    .resolveFrom(context)
                                    .withOpacity(0.8),
                                header: Text(
                                  'HARMONIES',
                                  style: TextStyle(
                                    color: isDark
                                        ? CupertinoColors.white
                                        : CupertinoColors.black,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: _HarmoniesList(
                                      provider: provider,
                                      isMaterial: false,
                                    ),
                                  ),
                                ],
                              ),
                              CupertinoListSection.insetGrouped(
                                backgroundColor: CupertinoColors
                                    .systemBackground
                                    .resolveFrom(context)
                                    .withOpacity(0.8),
                                header: Text(
                                  'HISTORY',
                                  style: TextStyle(
                                    color: isDark
                                        ? CupertinoColors.white
                                        : CupertinoColors.black,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: _HistorySection(
                                      provider: provider,
                                      isMaterial: false,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: CupertinoColors.separator.resolveFrom(context),
                        ),
                        Expanded(
                          flex: 10,
                          child: Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _ColorPreviewArea(
                                        provider: provider,
                                        isMaterial: false,
                                      ),
                                      const SizedBox(height: 24),
                                      CupertinoListSection.insetGrouped(
                                        backgroundColor: CupertinoColors
                                            .systemBackground
                                            .resolveFrom(context)
                                            .withOpacity(0.85),
                                        header: Text(
                                          'ACCESSIBILITY',
                                          style: TextStyle(
                                            color: isDark
                                                ? CupertinoColors.white
                                                : CupertinoColors.black,
                                          ),
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: _AccessibilityCard(
                                              provider: provider,
                                              isMaterial: false,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                color: provider.color,
                                borderRadius: BorderRadius.circular(30),
                                onPressed: () {
                                  provider.generate();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.sparkles,
                                      color:
                                          provider.color.computeLuminance() >
                                              0.5
                                          ? CupertinoColors.black
                                          : CupertinoColors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Generate next palette',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            provider.color.computeLuminance() >
                                                0.5
                                            ? CupertinoColors.black
                                            : CupertinoColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: _ColorPreviewArea(
                                  provider: provider,
                                  isMaterial: false,
                                ),
                              ),
                              const SizedBox(height: 16),
                              CupertinoListSection.insetGrouped(
                                backgroundColor: CupertinoColors
                                    .systemBackground
                                    .resolveFrom(context)
                                    .withOpacity(0.85),
                                header: Text(
                                  'ACCESSIBILITY',
                                  style: TextStyle(
                                    color: isDark
                                        ? CupertinoColors.white
                                        : CupertinoColors.black,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: _AccessibilityCard(
                                      provider: provider,
                                      isMaterial: false,
                                    ),
                                  ),
                                ],
                              ),
                              CupertinoListSection.insetGrouped(
                                backgroundColor: CupertinoColors
                                    .systemBackground
                                    .resolveFrom(context)
                                    .withOpacity(0.85),
                                header: Text(
                                  'HARMONIES',
                                  style: TextStyle(
                                    color: isDark
                                        ? CupertinoColors.white
                                        : CupertinoColors.black,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: _HarmoniesList(
                                      provider: provider,
                                      isMaterial: false,
                                    ),
                                  ),
                                ],
                              ),
                              CupertinoListSection.insetGrouped(
                                backgroundColor: CupertinoColors
                                    .systemBackground
                                    .resolveFrom(context)
                                    .withOpacity(0.85),
                                header: Text(
                                  'HISTORY',
                                  style: TextStyle(
                                    color: isDark
                                        ? CupertinoColors.white
                                        : CupertinoColors.black,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: _HistorySection(
                                      provider: provider,
                                      isMaterial: false,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        CupertinoButton.filled(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          color: provider.color,
                          borderRadius: BorderRadius.circular(30),
                          onPressed: () {
                            provider.generate();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.sparkles,
                                color: provider.color.computeLuminance() > 0.5
                                    ? CupertinoColors.black
                                    : CupertinoColors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Generate next palette',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: provider.color.computeLuminance() > 0.5
                                      ? CupertinoColors.black
                                      : CupertinoColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
