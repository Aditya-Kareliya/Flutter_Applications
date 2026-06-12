import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/settings/settings_provider.dart';
import '../../domain/entities/expense.dart';

import '../../../../../core/utils/icon_utils.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              _buildCategoryIcon(context, expense.category),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (expense.note != null && expense.note!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 0.5.h),
                        child: Text(
                          expense.note!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.outline,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    SizedBox(height: 0.5.h),
                    Text(
                      DateFormat.yMMMd().format(expense.date),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.outline,
                          ),
                    ),
                  ],
                ),
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  return Text(
                    '${expense.type == TransactionType.income ? '+' : '-'}${settings.currency}${expense.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: expense.type == TransactionType.income ? AppColors.accentGreen : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                  );
                },
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context, Category category) {
    // Parse hex color string to Color
    Color color;
    try {
      color = Color(int.parse(category.color));
    } catch (_) {
      color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        IconUtils.getIconByName(category.icon),
        color: color,
        size: 20.sp,
      ),
    );
  }
}
