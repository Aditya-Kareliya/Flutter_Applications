import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../qr_module/presentation/widgets/adaptive_widgets.dart';
import '../../../../preview_app/logic/preview_provider.dart';
import '../logic/password_provider.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  bool isTablet(BuildContext context) => MediaQuery.of(context).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final useCupertino = context.watch<PlatformProvider>().useCupertinoStyle;
    final tablet = isTablet(context);

    if (useCupertino) {
      return const _CupertinoLayout();
    }

    if (tablet) {
      return const _TabletLayout();
    }

    return const _MaterialLayout();
  }
}

/// MATERIAL LAYOUT
class _MaterialLayout extends StatelessWidget {
  const _MaterialLayout();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PasswordProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.go('/')),
        title: const Text("Secure-Tech Pass", style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.1)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Expanded(child: _Body()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
                onPressed: provider.generate,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text("Generate password", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CUPERTINO LAYOUT
class _CupertinoLayout extends StatelessWidget {
  const _CupertinoLayout();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PasswordProvider>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(onPressed: () => context.go('/')),
        middle: const Text("Secure-Tech Pass", style: TextStyle(fontWeight: FontWeight.w600)),
        border: const Border(bottom: BorderSide(color: CupertinoColors.separator)),
      ),
      child: SafeArea(
        bottom: false,
        child: isTablet
            ? Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            children: const [
                              Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _PreviewPanel()),
                              SizedBox(height: 20),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _StrengthMeter()),
                              SizedBox(height: 20),
                              _HistoryPanel(),
                            ],
                          ),
                        ),
                        Container(width: 1, color: CupertinoColors.separator.resolveFrom(context)),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            children: const [_SettingsPanel()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        onPressed: provider.generate,
                        child: const Text("Generate password", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  const Expanded(child: _Body()),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        onPressed: provider.generate,
                        child: const Text("Generate password", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// TABLET MATERIAL
class _TabletLayout extends StatelessWidget {
  const _TabletLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure-Tech Pass')),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                _PreviewPanel(),
                SizedBox(height: 20),
                _StrengthMeter(),
                SizedBox(height: 20),
                _HistoryPanel(),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: const [_SettingsPanel()],
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final useCupertino = context.watch<PlatformProvider>().useCupertinoStyle;

    if (useCupertino) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: const [
          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _PreviewPanel()),
          SizedBox(height: 20),
          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _StrengthMeter()),
          SizedBox(height: 20),
          _SettingsPanel(),
          SizedBox(height: 20),
          _HistoryPanel(),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: const [_PreviewPanel(), SizedBox(height: 20), _StrengthMeter(), SizedBox(height: 20), _SettingsPanel(), SizedBox(height: 20), _HistoryPanel()]),
    );
  }
}

/// PASSWORD PREVIEW PANEL
class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PasswordProvider>();
    final useCupertino = context.watch<PlatformProvider>().useCupertinoStyle;

    final brightness = useCupertino ? CupertinoTheme.brightnessOf(context) : Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // Platform-aware colors so iOS light mode stays visible
    late Color bg1;
    late Color bg2;
    late Color borderColor;
    late Color textColor;

    if (useCupertino) {
      bg1 = CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
      bg2 = bg1;
      borderColor = Colors.transparent;
      textColor = CupertinoColors.label.resolveFrom(context);
    } else {
      // Material (Android) – keep existing glassy look
      bg1 = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);
      bg2 = isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02);
      borderColor = isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.1);
      textColor = isDark ? Colors.white : Colors.black87;
    }

    final double radius = useCupertino ? 12.0 : 28.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        decoration: BoxDecoration(
          color: useCupertino ? bg1 : null,
          gradient: useCupertino ? null : LinearGradient(colors: [bg1, bg2], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(radius),
          border: useCupertino ? null : Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Your secure key", style: TextStyle(color: textColor.withOpacity(0.8))),
                Text(
                  provider.strengthText,
                  style: TextStyle(color: provider.strengthColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: provider.password));

                showAdaptiveFeedback(context, "Password copied", isError: false);
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  provider.showPassword ? provider.password : "•" * provider.password.length,
                  key: ValueKey(provider.password + provider.showPassword.toString()),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontFamily: "monospace", fontWeight: FontWeight.bold, letterSpacing: 1.2, color: textColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AdaptiveIconButton(
                  icon: Icons.copy,
                  cupertinoIcon: CupertinoIcons.doc_on_doc,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: provider.password));
                    showAdaptiveFeedback(context, "Password copied", isError: false);
                  },
                ),
                const SizedBox(width: 12),
                _AdaptiveIconButton(
                  icon: provider.showPassword ? Icons.visibility : Icons.visibility_off,
                  cupertinoIcon: provider.showPassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  onTap: provider.toggleShowPassword,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// STRENGTH METER
class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PasswordProvider>();
    final useCupertino = context.watch<PlatformProvider>().useCupertinoStyle;

    if (useCupertino) {
      final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
      final textColor = isDark ? CupertinoColors.white : CupertinoColors.label;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Strength", style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontWeight: FontWeight.w600)),
              Text(
                provider.strengthText,
                style: TextStyle(fontWeight: FontWeight.bold, color: provider.strengthColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 8,
              color: CupertinoColors.systemFill.resolveFrom(context),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: provider.strength.clamp(0, 1),
                child: Container(color: provider.strengthColor),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text("Entropy: ${provider.entropy.toStringAsFixed(1)} bits", style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 12, color: textColor.withOpacity(0.7))),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Strength", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: provider.strength, color: provider.strengthColor),
        const SizedBox(height: 6),
        Text("Entropy: ${provider.entropy.toStringAsFixed(1)} bits", style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// HISTORY PANEL
class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PasswordProvider>();
    final useCupertino = context.watch<PlatformProvider>().useCupertinoStyle;

    if (provider.history.isEmpty) return const SizedBox();

    if (useCupertino) {
      return CupertinoListSection.insetGrouped(
        backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
        header: Text(
          "RECENT PASSWORDS",
          style: TextStyle(fontSize: 12, letterSpacing: 1.3, color: CupertinoColors.secondaryLabel.resolveFrom(context)),
        ),
        children: provider.history.map((item) {
          return CupertinoListTile(
            title: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: item.password));
                showAdaptiveFeedback(context, "Password copied", isError: false);
              },
              child: Text(item.password, style: TextStyle(fontFamily: "monospace", color: CupertinoColors.label.resolveFrom(context))),
            ),
            subtitle: Text(item.createdAt.toString(), style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context))),
            trailing: CupertinoButton(padding: EdgeInsets.zero, child: const Icon(CupertinoIcons.delete), onPressed: () => provider.removeHistory(item)),
          );
        }).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Passwords", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        ...provider.history.map((item) {
          return Card(
            child: ListTile(
              title: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: item.password));
                  showAdaptiveFeedback(context, "Password copied", isError: false);
                },
                child: Text(item.password, style: const TextStyle(fontFamily: "monospace")),
              ),
              subtitle: Text(item.createdAt.toString()),
              trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => provider.removeHistory(item)),
            ),
          );
        }),
      ],
    );
  }
}

/// ADAPTIVE ICON BUTTON
class _AdaptiveIconButton extends StatelessWidget {
  final IconData icon;
  final IconData cupertinoIcon;
  final VoidCallback onTap;

  const _AdaptiveIconButton({required this.icon, required this.cupertinoIcon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final useCupertino = context.watch<PlatformProvider>().useCupertinoStyle;

    if (useCupertino) {
      return CupertinoButton(onPressed: onTap, padding: EdgeInsets.zero, child: Icon(cupertinoIcon));
    }

    return IconButton(icon: Icon(icon), onPressed: onTap);
  }
}

/// SETTINGS PANEL
class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PasswordProvider>();
    final useCupertino = context.watch<PlatformProvider>().useCupertinoStyle;

    /// CUPERTINO SETTINGS
    if (useCupertino) {
      final labelStyle = TextStyle(color: CupertinoColors.label.resolveFrom(context));
      final subLabelStyle = TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel.resolveFrom(context));
      final headerStyle = TextStyle(fontSize: 12, letterSpacing: 1.3, color: CupertinoColors.secondaryLabel.resolveFrom(context));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CupertinoListSection.insetGrouped(
            header: Text("LENGTH", style: headerStyle),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("Password length", style: labelStyle), 
                      Text("${p.length.toInt()}", style: labelStyle),
                    ]),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoSlider(min: 4, max: 25, value: p.length, onChanged: p.updateLength,divisions: 10,),
                    ),
                  ],
                ),
              ),
            ],
          ),

          CupertinoListSection.insetGrouped(
            header: Text("CHARACTER SETS", style: headerStyle),
            children: [
              CupertinoListTile(
                title: Text("Uppercase A–Z", style: labelStyle),
                trailing: CupertinoSwitch(value: p.uppercase, onChanged: p.toggleUppercase),
              ),
              CupertinoListTile(
                title: Text("Numbers 0–9", style: labelStyle),
                trailing: CupertinoSwitch(value: p.numbers, onChanged: p.toggleNumbers),
              ),
              CupertinoListTile(
                title: Text("Symbols", style: labelStyle),
                trailing: CupertinoSwitch(value: p.symbols, onChanged: p.toggleSymbols),
              ),
            ],
          ),

          CupertinoListSection.insetGrouped(
            header: Text("ADVANCED RULES", style: headerStyle),
            children: [
              CupertinoListTile(
                title: Text("Exclude similar characters", style: labelStyle),
                subtitle: Text("Avoid 0/O, 1/l, I.", style: subLabelStyle),
                trailing: CupertinoSwitch(value: p.excludeSimilar, onChanged: p.toggleExcludeSimilar),
              ),
              CupertinoListTile(
                title: Text("Require all selected sets", style: labelStyle),
                subtitle: Text("Each enabled set must appear at least once.", style: subLabelStyle),
                trailing: CupertinoSwitch(value: p.requireAllSets, onChanged: p.toggleRequireAllSets),
              ),
              CupertinoListTile(
                title: Text("Avoid sequences & repeats", style: labelStyle),
                trailing: CupertinoSwitch(value: p.avoidPatterns, onChanged: p.toggleAvoidPatterns),
              ),
            ],
          ),

          CupertinoListSection.insetGrouped(
            header: Text("CUSTOM", style: headerStyle),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: CupertinoTextField(
                  placeholder: "Custom characters",
                  onChanged: p.updateCustomChars,
                  style: labelStyle,
                ),
              ),
            ],
          ),
        ],
      );
    }

    /// MATERIAL SETTINGS
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Generator controls", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Length: ${p.length.toInt()}", style: theme.textTheme.titleMedium),
            ),

            Slider(value: p.length, min: 4, max: 25, divisions: 6, label: "${p.length.toInt()}", onChanged: p.updateLength),

            const SizedBox(height: 8),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilterChip(label: const Text("Uppercase A–Z"), selected: p.uppercase, onSelected: (v) => p.toggleUppercase(v)),
                FilterChip(label: const Text("Numbers 0–9"), selected: p.numbers, onSelected: (v) => p.toggleNumbers(v)),
                FilterChip(label: const Text("Symbols"), selected: p.symbols, onSelected: (v) => p.toggleSymbols(v)),
              ],
            ),

            const SizedBox(height: 12),

            SwitchListTile(title: const Text("Exclude similar characters"), subtitle: const Text("Avoid 0/O, 1/l, I to reduce confusion."), value: p.excludeSimilar, onChanged: p.toggleExcludeSimilar),

            SwitchListTile(
              title: const Text("Require all selected character sets"),
              subtitle: const Text("Ensure every generated password uses each enabled set."),
              value: p.requireAllSets,
              onChanged: p.toggleRequireAllSets,
            ),

            SwitchListTile(
              title: const Text("Avoid sequences & repeats"),
              subtitle: const Text("No easy 123, abc or obvious repeated patterns."),
              value: p.avoidPatterns,
              onChanged: p.toggleAvoidPatterns,
            ),

            const SizedBox(height: 10),

            TextField(
              decoration: const InputDecoration(labelText: "Custom characters (advanced)", border: OutlineInputBorder()),
              onChanged: p.updateCustomChars,
            ),
          ],
        ),
      ),
    );
  }
}
