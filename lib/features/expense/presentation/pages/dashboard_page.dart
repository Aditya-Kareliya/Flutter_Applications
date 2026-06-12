import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/settings/settings_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/platform/platform_scaffold.dart';
import '../../../../core/widgets/platform/platform_bottom_sheet.dart';

import '../../domain/entities/transaction_type.dart';
import '../provider/expense_provider.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/expense_card.dart';
import 'search_page.dart';
import '../../../../features/settings/presentation/pages/settings_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void _showAddExpenseSheet(BuildContext context) {
    if (Platform.isIOS) {
      PlatformBottomSheet.show(
        context: context,
        child: const AddExpenseSheet(),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).cardTheme.color,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        builder: (context) => const AddExpenseSheet(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initial load check can be done here or in provider constructor.
    final provider = context.read<ExpenseProvider>();
    if (provider.expenses.isEmpty && !provider.isLoading && provider.error == null) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         provider.loadExpenses();
       });
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return PlatformScaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: isDark ? Colors.black : Colors.grey[50], // Keep basic bg, but body has gradient/custom scroll
          // Android Floating Action Button
          floatingActionButton: Platform.isAndroid ? FloatingActionButton.extended(
            onPressed: () => _showAddExpenseSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: Text('Transaction', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            backgroundColor: settings.primaryColor, 
            foregroundColor: Colors.white,
            elevation: 4,
          ).animate().scale(delay: 500.ms, duration: 300.ms) : null,
          
          body: CustomScrollView(
            slivers: [
              if (Platform.isIOS)
                CupertinoSliverNavigationBar(
                  largeTitle: Text('Dashboard', style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily)),
                  backgroundColor: isDark ? Colors.black : Colors.white,
                  border: null, // Clean look
                  stretch: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                       CupertinoButton(
                        padding: EdgeInsets.zero,
                        child:  Icon(
                          theme.brightness == Brightness.dark ? CupertinoIcons.sun_max : CupertinoIcons.moon,
                          color: isDark ? Colors.white : Colors.black,
                        ), 
                        onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                       ),
                       CupertinoButton(
                         padding: EdgeInsets.zero,
                         child: const Icon(CupertinoIcons.search),
                         onPressed: () {
                            Navigator.push(
                             context,
                             CupertinoPageRoute(builder: (context) => const SearchPage()),
                           );
                         },
                       ),
                       CupertinoButton(
                        padding: EdgeInsets.zero,
                       // Using gear_alt_fill or just gear for settings
                        child: const Icon(CupertinoIcons.settings),
                        onPressed: () {
                           Navigator.push(
                             context,
                              // Use CupertinoPageRoute for native iOS transition
                             CupertinoPageRoute(builder: (context) => const SettingsPage()),
                           );
                        },
                       ),
                       CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(CupertinoIcons.add, color: settings.primaryColor),
                        onPressed: () => _showAddExpenseSheet(context),
                       ),
                    ],
                  ),
                )
              else 
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 28.h,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [

                    IconButton(
                      onPressed: () {
                        context.read<ThemeProvider>().toggleTheme();
                      },
                      icon: Consumer<ThemeProvider>(
                        builder: (context, theme, _) {
                          return Icon(
                            theme.themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                             color: Colors.white,
                          );
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                           MaterialPageRoute(builder: (context) => const SearchPage()),
                        );
                      },
                      icon: const Icon(Icons.search_rounded, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                           MaterialPageRoute(builder: (context) => const SettingsPage()),
                        );
                      },
                      icon: const Icon(Icons.settings_rounded, color: Colors.white),
                      tooltip: 'Settings',
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            settings.primaryColor,
                            settings.primaryColor.withValues(alpha: 0.8),
                            HSLColor.fromColor(settings.primaryColor).withLightness(0.4).toColor(),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        boxShadow: [
                           BoxShadow(
                             color: settings.primaryColor.withValues(alpha: 0.3),
                             blurRadius: 20,
                             offset: const Offset(0, 10),
                           )
                        ],
                      ),
                      child: Stack(
                        children: [
                           Positioned(
                             top: -50,
                             right: -50,
                             child: Container(
                               width: 200,
                               height: 200,
                               decoration: BoxDecoration(
                                 color: Colors.white.withValues(alpha: 0.1),
                                 shape: BoxShape.circle,
                               ),
                             ),
                           ),
                           Positioned(
                             bottom: -30,
                             left: 20,
                             child: Container(
                               width: 100,
                               height: 100,
                               decoration: BoxDecoration(
                                 color: Colors.white.withValues(alpha: 0.1),
                                 shape: BoxShape.circle,
                               ),
                             ),
                           ),
                          _buildTotalBalance(context, isIOS: false),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // On iOS, we need to show the Balance Card explicitly in the body since it's not in the AppBar
              if (Platform.isIOS)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            settings.primaryColor,
                            settings.primaryColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: settings.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: _buildTotalBalance(context, isIOS: true),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        'Recent Transactions',
                         style: GoogleFonts.outfit(
                           fontSize: 18.sp,
                           fontWeight: FontWeight.bold,
                           color: isDark ? Colors.white : Colors.black87,
                         ),
                      ),
                      TextButton(
                        onPressed: () {
                           Navigator.push(
                             context,
                              Platform.isIOS 
                              ? CupertinoPageRoute(builder: (context) => const SearchPage()) 
                              : MaterialPageRoute(builder: (context) => const SearchPage()),
                           );
                        }, 
                        child: Text(
                          'See All',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            color: settings.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Consumer2<ExpenseProvider, SettingsProvider>(
                builder: (context, provider, settings, child) {
                  if (provider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator.adaptive()),
                    );
                  }
                  
                  // Filter out hidden categories
                  final visibleExpenses = provider.expenses.where((e) {
                    return !settings.hiddenCategories.contains(e.category.name);
                  }).toList();
  
                  if (visibleExpenses.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 8.h, color: Colors.grey.shade400),
                            SizedBox(height: 2.h),
                            Text(
                              'No transactions yet',
                              style: GoogleFonts.outfit(
                                fontSize: 16.sp,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
  
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expense = visibleExpenses[index];
                        return Dismissible(
                          key: Key(expense.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 6.w),
                            child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
                          ),
                          onDismissed: (_) {
                            context.read<ExpenseProvider>().deleteExpense(expense.id);
                            CustomSnackbar.showSuccess(context, 'Transaction deleted');
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
                            child: ExpenseCard(expense: expense),
                          ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.1, end: 0),
                        );
                      },
                      childCount: visibleExpenses.length,
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            ],
          ),
        );
      },
    );
  }



  Widget _buildTotalBalance(BuildContext context, {required bool isIOS}) {
    // If iOS content is inside a card, minimal padding needed.
    // If Android content is inside SliverAppBar, needs SafeArea and more padding.
    return Padding(
        padding: isIOS 
            ? EdgeInsets.zero 
            : EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: SafeArea(
          top: !isIOS, 
          bottom: false,
          child: Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   if (!isIOS) SizedBox(height: 2.h), // Spacer for Android status bar area visual
                  Text(
                    'Total Balance',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Consumer2<ExpenseProvider, SettingsProvider>(
                    builder: (context, provider, settings, _) {
                      final visibleExpenses = provider.expenses.where((e) => !settings.hiddenCategories.contains(e.category.name));
                      final visibleBalance = visibleExpenses.fold(0.0, (sum, item) {
                        return item.type == TransactionType.income ? sum + item.amount : sum - item.amount;
                      });
                      
                      return Text(
                        '${settings.currency}${visibleBalance.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 3.h),
                  Consumer2<ExpenseProvider, SettingsProvider>(
                    builder: (context, provider, settings, _) {
                      final visibleExpenses = provider.expenses.where((e) => !settings.hiddenCategories.contains(e.category.name));
                      final income = visibleExpenses.where((e) => e.type == TransactionType.income).fold(0.0, (sum, e) => sum + e.amount);
                      final expense = visibleExpenses.where((e) => e.type == TransactionType.expense).fold(0.0, (sum, e) => sum + e.amount);
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildIncomeExpenseItem(
                            context,
                            'Income',
                            '${settings.currency}${income.toStringAsFixed(2)}',
                            Platform.isIOS ? CupertinoIcons.arrow_up_circle_fill : Icons.arrow_circle_up_rounded,
                            Colors.greenAccent,
                          ),
                          Container(height: 4.h, width: 1, color: Colors.white24, margin: EdgeInsets.symmetric(horizontal: 6.w)),
                          _buildIncomeExpenseItem(
                            context,
                            'Expense',
                            '${settings.currency}${expense.toStringAsFixed(2)}',
                            Platform.isIOS ? CupertinoIcons.arrow_down_circle_fill : Icons.arrow_circle_down_rounded,
                            const Color(0xFFFF8A80), // Softer red
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
    );
  }

  Widget _buildIncomeExpenseItem(
    BuildContext context,
    String label,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18.sp),
        ),
        SizedBox(width: 3.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13.sp,
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
