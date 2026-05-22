import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

import '../../logic/preview_provider.dart';
import '../../../portfolio/logic/portfolio_provider.dart';
import '../../../../core/constants/app_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preview = context.watch<PlatformProvider>();
    return preview.useCupertinoStyle ? const CupertinoDashboardScreen() : const MaterialDashboardScreen();
  }
}

//////////////////////////////////////////////////////////////
/// ================= IOS DASHBOARD =========================
//////////////////////////////////////////////////////////////

class CupertinoDashboardScreen extends StatelessWidget {
  const CupertinoDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolioProvider = context.watch<PortfolioProvider>();
    portfolioProvider.isMobileLayout(context);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "Dashboard",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final module = DashboardModule.items[index];
                  return _AnimatedGridItem(
                    index: index,
                    child: DashboardItemCard(module: module, isCupertino: true),
                  );
                }, childCount: DashboardModule.items.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width >= 1024 ? 4 : (MediaQuery.of(context).size.width >= 600 ? 3 : 2),
                  crossAxisSpacing: 4.w,
                  mainAxisSpacing: 2.h,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 3.h),
                child: Center(child: Text("VERSION 2.0.0", style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// ================= ANDROID DASHBOARD =====================
//////////////////////////////////////////////////////////////

class MaterialDashboardScreen extends StatelessWidget {
  const MaterialDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<PortfolioProvider>();
    final width = MediaQuery.of(context).size.width;

    final crossAxisCount = width >= 1024 ? 4 : (width >= 600 ? 3 : 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: GridView.builder(
                  itemCount: DashboardModule.items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, crossAxisSpacing: 4.w, mainAxisSpacing: 2.h),
                  itemBuilder: (context, index) {
                    final module = DashboardModule.items[index];

                    return _AnimatedGridItem(
                      index: index,
                      child: DashboardItemCard(module: module, isCupertino: false),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Text("VERSION 2.0.0", style: Theme.of(context).textTheme.labelSmall),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// ================= ANIMATION WRAPPER =====================
//////////////////////////////////////////////////////////////

class _AnimatedGridItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedGridItem({required this.child, required this.index});

  @override
  State<_AnimatedGridItem> createState() => _AnimatedGridItemState();
}

class _AnimatedGridItemState extends State<_AnimatedGridItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> scale;
  late Animation<double> fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    scale = Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    fade = Tween(begin: 0.0, end: 1.0).animate(_controller);

    Future.delayed(Duration(milliseconds: 80 * widget.index), () => _controller.forward());
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(scale: scale, child: widget.child),
    );
  }
}

//////////////////////////////////////////////////////////////
/// ================= CARD ================================
//////////////////////////////////////////////////////////////

class DashboardItemCard extends StatefulWidget {
  final DashboardModule module;
  final bool isCupertino;

  const DashboardItemCard({super.key, required this.module, required this.isCupertino});

  @override
  State<DashboardItemCard> createState() => _DashboardItemCardState();
}

class _DashboardItemCardState extends State<DashboardItemCard> {
  double scale = 1;

  void _onTapDown(_) => setState(() => scale = 0.95);

  void _onTapUp(_) => setState(() => scale = 1);

  @override
  Widget build(BuildContext context) {
    final module = widget.module;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go('/${module.routeName}');
      },
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _onTapUp(null),
      child: AnimatedScale(scale: scale, duration: const Duration(milliseconds: 120), child: widget.isCupertino ? _iosCard(context, module) : _androidCard(context, module)),
    );
  }

  Widget _iosCard(BuildContext context, DashboardModule module) {
    return Container(
      decoration: BoxDecoration(color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context), borderRadius: BorderRadius.circular(18)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(module.icon, size: 28.sp, color: CupertinoColors.activeBlue.resolveFrom(context)),
          SizedBox(height: 1.h),
          Text(
            module.title,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _androidCard(BuildContext context, DashboardModule module) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [module.color.withOpacity(0.8), module.color.withOpacity(0.4)]),
        boxShadow: [BoxShadow(color: module.color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(module.icon, size: 22.sp, color: Colors.white),
          SizedBox(height: 1.h),
          Text(
            module.title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// ================= MODEL ===============================
//////////////////////////////////////////////////////////////

class DashboardModule {
  final String title;
  final IconData icon;
  final Color color;
  final String routeName;

  const DashboardModule({required this.title, required this.icon, required this.color, required this.routeName});

  static const items = [
    DashboardModule(title: 'QR Gen', icon: Icons.qr_code_2_rounded, color: Colors.blue, routeName: AppConstants.qrCodeGeneratorModule),
    DashboardModule(title: 'Colors', icon: Icons.color_lens_rounded, color: Colors.purple, routeName: AppConstants.colorPaletteModule),
    DashboardModule(title: 'Pass Gen', icon: Icons.password_rounded, color: Colors.teal, routeName: AppConstants.passwordGeneratorModule),
    DashboardModule(title: 'Units', icon: Icons.straighten_rounded, color: Colors.orange, routeName: AppConstants.unitConverterModule),
    DashboardModule(title: 'BMI Calc', icon: Icons.monitor_weight_rounded, color: Colors.red, routeName: AppConstants.bmiCalculatorModule),
    DashboardModule(title: 'Tip Calc', icon: Icons.payments_rounded, color: Colors.green, routeName: AppConstants.tipCalculatorModule),
  ];
}
