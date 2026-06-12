import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/platform_info.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/settings/settings_provider.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/platform/platform_scaffold.dart';
import '../../../../core/widgets/platform/platform_bottom_sheet.dart';
import '../../domain/entities/expense.dart';
import '../../../../../core/utils/icon_utils.dart';
import '../widgets/category_expenses_sheet.dart';
import '../provider/expense_provider.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  TransactionType _selectedType = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return PlatformScaffold(
          extendBodyBehindAppBar: true,
          
          appBar: !PlatformInfo.isIOS ? AppBar(
            title: Text(
              'Analytics', 
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black, 
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              )
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          ) : null,
          
          cupertinoNavigationBar: PlatformInfo.isIOS ? CupertinoNavigationBar(
             middle: Text('Analytics', style: TextStyle(fontFamily: GoogleFonts.outfit().fontFamily)),
             backgroundColor: Colors.transparent, 
             border: null,
          ) : null,

          body: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      colors: [
                        Colors.black,
                        settings.primaryColor.withValues(alpha: 0.15),
                        Colors.black,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.4, 1.0],
                    )
                  : LinearGradient(
                      colors: [
                        settings.primaryColor.withValues(alpha: 0.05),
                        Colors.white,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
            ),
            child: Consumer<ExpenseProvider>(
              builder: (context, provider, _) {
                if (provider.expenses.isEmpty) {
                   return Center(
                     child: Text(
                       'No data to analyze', 
                       style: GoogleFonts.outfit(fontSize: 18.sp, color: Colors.grey)
                      ),
                   );
                }

                final hasExpense = provider.expenses.any((e) => e.type == TransactionType.expense);
                final hasIncome = provider.expenses.any((e) => e.type == TransactionType.income);

                // Determine effective type to show
                TransactionType effectiveType = _selectedType;
                bool showToggle = true;

                if (hasExpense && hasIncome) {
                  showToggle = true;
                  // Keep selected type
                } else if (hasExpense && !hasIncome) {
                  showToggle = false;
                  effectiveType = TransactionType.expense;
                } else if (!hasExpense && hasIncome) {
                  showToggle = false;
                  effectiveType = TransactionType.income;
                } else {
                  // Should be covered by empty check, but fallback
                  showToggle = false;
                }

                // If state doesn't match single available type, we could update it, 
                // but just using effectiveType for rendering is safer/cleaner than side-effects in build.

                final totalsMap = provider.getCategoryTotals(effectiveType);
                final filteredTotals = Map<Category, double>.from(totalsMap)
                  ..removeWhere((key, value) => settings.hiddenCategories.contains(key.name));
                
                 final monthlyTotals = provider.getMonthlyTotals(effectiveType);

                return SafeArea(
                  top: true,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = constraints.maxWidth > 600 || Device.screenType == ScreenType.tablet;
                      
                      if (isTablet) {
                         return _buildSplitView(context, settings, filteredTotals, monthlyTotals, isDark, showToggle, effectiveType);
                      }
                      
                      return _buildMobileView(context, settings, filteredTotals, monthlyTotals, isDark, showToggle, effectiveType);
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileView(
    BuildContext context, 
    SettingsProvider settings, 
    Map<Category, double> categoryTotals,
    Map<DateTime, double> monthlyTotals,
    bool isDark,
    bool showToggle,
    TransactionType currentType,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(4.w, !PlatformInfo.isIOS ? 0 : 2.h, 4.w, 4.w),
      child: Column(
        children: [
          if (showToggle) ...[
            _buildToggle(settings, isDark),
            SizedBox(height: 3.h),
          ] else ...[
             // If toggle hidden, maybe show a Title to indicate what we are looking at?
             // Or just the chart/list is enough context. User asked "not disply tab show only added analitics".
             // Let's add a small header if toggle is missing so context isn't lost.
             Text(
               currentType == TransactionType.expense ? 'Expenses' : 'Income',
               style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
             ),
             SizedBox(height: 3.h),
          ],
          
          if (categoryTotals.isNotEmpty) ...[
             _buildPieChart(categoryTotals, isDark),
             SizedBox(height: 4.h),
          ],
          

          if (categoryTotals.isEmpty)
             Padding(
               padding: EdgeInsets.only(top: 10.h),
               child: Text('No visible data for ${currentType.name.toUpperCase()}', style: GoogleFonts.outfit(color: Colors.grey)),
             )
          else 
             _buildCategoryList(context, categoryTotals, settings, isDark),
             
          SizedBox(height: 5.h),
        ],
      ),
    );
  }

  Widget _buildSplitView(
    BuildContext context, 
    SettingsProvider settings, 
    Map<Category, double> categoryTotals,
    Map<DateTime, double> monthlyTotals,
    bool isDark,
    bool showToggle,
    TransactionType currentType,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Pane: Controls & Charts
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(3.w),
            child: Column(
              children: [
                if (showToggle) ...[
                  _buildToggle(settings, isDark),
                  SizedBox(height: 3.h),
                ] else ...[
                   Text(
                     currentType == TransactionType.expense ? 'Expenses' : 'Income',
                     style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                   ),
                   SizedBox(height: 3.h),
                ],

                if (categoryTotals.isNotEmpty) _buildPieChart(categoryTotals, isDark),
                SizedBox(height: 3.h),

              ],
            ),
          ),
        ),
        // Right Pane: Detailed List
        Expanded(
          flex: 5,
          child: Container(
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: categoryTotals.isEmpty 
                ? Center(child: Text('No data', style: GoogleFonts.outfit(color: Colors.grey)))
                : SingleChildScrollView(
                    padding: EdgeInsets.all(2.w),
                    child: _buildCategoryList(context, categoryTotals, settings, isDark),
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(SettingsProvider settings, bool isDark) {
    if (PlatformInfo.isIOS) {
       return SizedBox(
         width: double.infinity,
         child: CupertinoSlidingSegmentedControl<TransactionType>(
            groupValue: _selectedType,
            onValueChanged: (v) => setState(() => _selectedType = v!),
            children: {
              TransactionType.expense: Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), child: Text('Expense', style: GoogleFonts.outfit())),
              TransactionType.income: Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), child: Text('Income', style: GoogleFonts.outfit())),
            },
         ),
       );
    }
    
    return SegmentedButton<TransactionType>(
      segments: const [
         ButtonSegment(value: TransactionType.expense, label: Text('Expense'), icon: Icon(Icons.remove_circle_outline)),
         ButtonSegment(value: TransactionType.income, label: Text('Income'), icon: Icon(Icons.add_circle_outline)),
      ],
      selected: {_selectedType},
      onSelectionChanged: (v) => setState(() => _selectedType = v.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.comfortable,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return settings.primaryColor.withValues(alpha: 0.2);
          }
          return null;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
           if (states.contains(WidgetState.selected)) {
             return settings.primaryColor;
           }
           return isDark ? Colors.white : Colors.black;
        }),
      ),
    );
  }

  Widget _buildPieChart(Map<Category, double> totals, bool isDark) {
    final total = totals.values.fold(0.0, (sum, val) => sum + val);
    
    return GlassContainer(
      padding: EdgeInsets.all(4.w),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      opacity: isDark ? 0.6 : 0.5,
      child: SizedBox(
        height: 30.h,
        child: PieChart(
          PieChartData(
            sections: totals.entries.map((entry) {
              final percentage = total > 0 ? (entry.value / total) * 100 : 0;
              final color = _getColor(entry.key);
              return PieChartSectionData(
                color: color,
                value: entry.value,
                title: '${percentage.toStringAsFixed(0)}%',
                radius: 14.w,
                titleStyle: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [const Shadow(color: Colors.black45, blurRadius: 2)],
                ),
                badgeWidget: _buildBadge(entry.key),
                badgePositionPercentageOffset: 1.1,
              );
            }).toList(),
            sectionsSpace: 2,
            centerSpaceRadius: 10.w, 
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack);
  }
  


  Widget _buildCategoryList(BuildContext context, Map<Category, double> filteredCategoryTotals, SettingsProvider settings, bool isDark) {
    if (PlatformInfo.isIOS) {
       return CupertinoListSection.insetGrouped(
          header: Text('CATEGORY BREAKDOWN', style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w600)),
          backgroundColor: Colors.transparent,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          children: filteredCategoryTotals.entries.map((entry) {
             final color = _getColor(entry.key);
             return CupertinoListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: Icon(IconUtils.getIconByName(entry.key.icon), color: color, size: 16),
                ),
                title: Text(entry.key.name, style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black)),
                trailing: Text(
                   '${settings.currency}${entry.value.toStringAsFixed(2)}',
                   style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.grey : Colors.grey.shade600),
                ),
                onTap: () {
                   PlatformBottomSheet.show(
                      context: context,
                      isScrollControlled: true,
                      child: CategoryExpensesSheet(category: entry.key),
                   );
                },
             );
          }).toList(),
       );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            'Category Breakdown',
            style: GoogleFonts.outfit(
              fontSize: 18.sp, 
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        ...filteredCategoryTotals.entries.map((entry) {
          final color = _getColor(entry.key);
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 0.8.h),
             child: GlassContainer(
               color: isDark ? Colors.grey.shade900 : Colors.white,
               opacity: isDark ? 0.6 : 0.8,
               child: ListTile(
                 leading: Container(
                   padding: const EdgeInsets.all(10),
                   decoration: BoxDecoration(
                     color: color.withValues(alpha: 0.2),
                     shape: BoxShape.circle,
                   ),
                   child: Icon(
                     IconUtils.getIconByName(entry.key.icon),
                     color: color,
                     size: 18.sp,
                   ),
                 ),
                 title: Text(
                   entry.key.name,
                   style: GoogleFonts.outfit(
                     color: isDark ? Colors.white : Colors.black87,
                     fontWeight: FontWeight.w600,
                     fontSize: 16.sp,
                   ),
                 ),
                 trailing: Text(
                   '${settings.currency}${entry.value.toStringAsFixed(2)}',
                   style: GoogleFonts.outfit(
                     fontWeight: FontWeight.bold,
                     color: isDark ? Colors.white : Colors.black,
                     fontSize: 16.sp,
                   ),
                 ),
                 onTap: () {
                   PlatformBottomSheet.show(
                     context: context,
                     isScrollControlled: true,
                     child: CategoryExpensesSheet(category: entry.key),
                   );
                 },
               ),
             ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
        }),
      ],
    );
  }

  Color _getColor(Category category) {
     try {
       return Color(int.parse(category.color));
     } catch (_) {
       return Colors.grey;
     }
  }

  Widget _buildBadge(Category category) {
    final color = _getColor(category);
    return Container(
      decoration: BoxDecoration(
         color: Colors.white,
         shape: BoxShape.circle,
         boxShadow: [
           BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
         ]
      ),
      padding: const EdgeInsets.all(4),
      child: Icon(IconUtils.getIconByName(category.icon), size: 14, color: color),
    );
  }
}
