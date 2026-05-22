import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/theme/theme_provider.dart';
import '../../../../logic/preview_provider.dart';
import '../../data/models/qr_code_model.dart';
import '../../logic/qr_provider.dart';

class QRDashboardScreen extends StatelessWidget {
  const QRDashboardScreen({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    final useCupertino = context.watch<PlatformProvider>().useCupertinoStyle;
    return useCupertino ? _CupertinoDashboard(isTablet: _isTablet(context)) : _MaterialDashboard(isTablet: _isTablet(context));
  }
}

// --------------------- Cupertino Dashboard ---------------------
class _CupertinoDashboard extends StatelessWidget {
  final bool isTablet;

  const _CupertinoDashboard({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QRProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(onPressed: () => context.go('/'), color: themeProvider.seedColor),
        middle: Text(provider.isSelectionMode ? '${provider.selectedCount} Selected' : 'QR Manager'),
        trailing: provider.isSelectionMode
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: provider.deleteSelected,
                child: const Icon(CupertinoIcons.delete, color: CupertinoColors.systemRed),
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  provider.setActiveQR(null);
                  context.go('/qr/create');
                },
                child: const Icon(CupertinoIcons.add),
              ),
      ),
      child: SafeArea(
        child: _QRList(isTablet: isTablet),
      ),
    );
  }
}

// --------------------- Material Dashboard ---------------------
class _MaterialDashboard extends StatelessWidget {
  final bool isTablet;

  const _MaterialDashboard({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QRProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
        title: Text(provider.isSelectionMode ? '${provider.selectedCount} Selected' : 'QR Manager'),
        actions: provider.isSelectionMode ? [IconButton(icon: const Icon(Icons.delete), onPressed: provider.deleteSelected)] : [],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          provider.setActiveQR(null);
          context.go('/qr/create');
        },
        child: const Icon(Icons.add),
      ),
      body: _QRList(isTablet: isTablet),
    );
  }
}

// --------------------- QR List (Platform-aware) ---------------------
class _QRList extends StatefulWidget {
  final bool isTablet;
  
  const _QRList({required this.isTablet});

  @override
  State<_QRList> createState() => _QRListState();
}

class _QRListState extends State<_QRList> {
  late TextEditingController _searchController;
  late FocusNode _searchFocus;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: context.read<QRProvider>().searchQuery);
    _searchFocus = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QRProvider>();
    final qrs = provider.filteredQRCodes;
    final isApple = context.watch<PlatformProvider>().useCupertinoStyle;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: isApple
              ? CupertinoSearchTextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  placeholder: 'Search QR',
                  onChanged: provider.setSearchQuery,
                )
              : TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: const InputDecoration(hintText: 'Search QR', prefixIcon: Icon(Icons.search)),
                  onChanged: provider.setSearchQuery,
                ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: qrs.length,
            itemBuilder: (_, i) => QRCardTile(qr: qrs[i], isTablet: widget.isTablet),
          ),
        ),
      ],
    );
  }
}

// --------------------- QR Card Tile (Platform-aware) ---------------------
class QRCardTile extends StatelessWidget {
  final QRCodeModel qr;
  final bool isTablet;

  const QRCardTile({required this.qr, required this.isTablet, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QRProvider>();
    final selected = provider.isSelected(qr.id);
    final isApple = context.watch<PlatformProvider>().useCupertinoStyle;

    void handleTap() {
      if (provider.isSelectionMode) {
        provider.toggleSelection(qr.id);
      } else {
        provider.setActiveQR(qr);
        context.push('/qr/edit/${qr.id}');
      }
    }

    return isApple
        ? CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: handleTap,
            onLongPress: () => provider.toggleSelection(qr.id),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
              decoration: BoxDecoration(
                color: isApple ? CupertinoColors.systemBackground : Colors.transparent, 
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (provider.isSelectionMode) ...[ // Changed condition here
                    Icon(selected ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle, color: selected ? CupertinoColors.activeBlue : null),
                    const SizedBox(width: 12),
                  ],
                  Expanded(child: Text(qr.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                  const Icon(CupertinoIcons.forward, color: CupertinoColors.systemGrey3),
                ],
              ),
            ),
          )
        : ListTile(
            onTap: handleTap,
            onLongPress: () => provider.toggleSelection(qr.id),
            leading: provider.isSelectionMode ? Icon(selected ? Icons.check_circle : Icons.circle_outlined) : null,
            title: Text(qr.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right),
            selected: selected,
          );
  }
}

