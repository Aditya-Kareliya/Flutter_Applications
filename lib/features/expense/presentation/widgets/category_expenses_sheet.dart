import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/platform_info.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/platform/platform_bottom_sheet.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/category.dart';
import '../provider/expense_provider.dart';
import 'add_expense_sheet.dart';
import 'expense_card.dart';

class CategoryExpensesSheet extends StatelessWidget {
  final Category category;

  const CategoryExpensesSheet({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      width: 100.w,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          SizedBox(height: 2.h),
          // Drag Handle
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 3.h),
          
          Padding(
             padding: EdgeInsets.symmetric(horizontal: 5.w),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                   '${category.name} Expenses',
                   style: GoogleFonts.outfit(
                     fontSize: 18.sp,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 PlatformInfo.isIOS 
                 ? CupertinoButton(
                     padding: EdgeInsets.zero,
                     child: const Icon(CupertinoIcons.clear_circled_solid),
                     onPressed: () => Navigator.pop(context),
                   )
                 : IconButton(
                     icon: const Icon(Icons.close),
                     onPressed: () => Navigator.pop(context),
                   ),
               ],
             ),
          ),
          Divider(color: Colors.grey.withValues(alpha: 0.1)),
          
          Expanded(
            child: Consumer<ExpenseProvider>(
              builder: (context, provider, _) {
                final categoryExpenses = provider.expenses
                    .where((e) => e.category == category)
                    .toList();

                if (categoryExpenses.isEmpty) {
                  return Center(
                    child: Text(
                      'No expenses found', 
                      style: GoogleFonts.outfit(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  itemCount: categoryExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = categoryExpenses[index];
                    return Dismissible(
                      key: Key(expense.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: EdgeInsets.symmetric(vertical: 0.8.h),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 6.w),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                      ),
                      confirmDismiss: (direction) async {
                         return await _showConfirmDeleteDialog(context);
                      },
                      onDismissed: (_) {
                        context.read<ExpenseProvider>().deleteExpense(expense.id);
                        CustomSnackbar.showSuccess(context, 'Transaction deleted');
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.8.h),
                        child: GestureDetector(
                          onTap: () {
                            PlatformBottomSheet.show(
                              context: context,
                              isScrollControlled: true,
                              child: AddExpenseSheet(expenseToEdit: expense),
                            );
                          },
                          child: ExpenseCard(expense: expense),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: (index * 30).ms).slideX(begin: 0.1, end: 0),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDeleteDialog(BuildContext context) async {
    if (PlatformInfo.isIOS) {
       return await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Delete'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );
    } else {
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }
}
