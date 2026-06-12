import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/settings/settings_provider.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/platform/platform_button.dart';
import '../../../../core/widgets/platform/platform_text_field.dart';
import '../../domain/entities/expense.dart';
import '../provider/expense_provider.dart';

class AddExpenseSheet extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpenseSheet({super.key, this.expenseToEdit});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  Category? _selectedCategory;
  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load categories if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ExpenseProvider>();
      if (provider.categories.isEmpty) {
        provider.loadCategories().then((_) {
           if (mounted && _selectedCategory == null && provider.categories.isNotEmpty) {
             setState(() {
               _selectedCategory = provider.categories.first;
             });
           }
        });
      } else {
         if (_selectedCategory == null) {
           setState(() {
             _selectedCategory = provider.categories.first; 
           });
         }
      }
    });

    if (widget.expenseToEdit != null) {
      _titleController.text = widget.expenseToEdit!.title;
      _amountController.text = widget.expenseToEdit!.amount.toString();
      _selectedCategory = widget.expenseToEdit!.category;
      _selectedType = widget.expenseToEdit!.type;
      _selectedDate = widget.expenseToEdit!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      CustomSnackbar.showError(context, 'Please fill all fields');
      return;
    }

    if (_selectedCategory == null) {
      CustomSnackbar.showError(context, 'Please select a category');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      CustomSnackbar.showError(context, 'Invalid amount');
      return;
    }

    final expense = Expense(
      id: widget.expenseToEdit?.id ?? const Uuid().v4(),
      title: _titleController.text,
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory!,
      type: _selectedType,
    );

    if (widget.expenseToEdit != null) {
      await context.read<ExpenseProvider>().updateExpense(expense);
    } else {
      await context.read<ExpenseProvider>().addExpense(expense);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showDatePicker() async {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              SizedBox(
                height: 240,
                child: CupertinoDatePicker(
                  initialDateTime: _selectedDate,
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() => _selectedDate = newDate);
                  },
                ),
              ),
              CupertinoButton(
                child: const Text('Done'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
      );
    } else {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != _selectedDate) {
        setState(() => _selectedDate = picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final provider = context.watch<ExpenseProvider>();
    final categories = provider.categories
        .where((c) => !settings.hiddenCategories.contains(c.name) && c.type == _selectedType.name)
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.expenseToEdit != null ? 'Edit Transaction' : 'New Transaction',
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (Platform.isIOS)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                ],
              ),
              SizedBox(height: 3.h),
              
              Center(
                child: Platform.isIOS 
                ? CupertinoSlidingSegmentedControl<TransactionType>(
                    groupValue: _selectedType,
                     onValueChanged: (v) {
                       setState(() {
                         _selectedType = v!;
                         _selectedCategory = null;
                         
                         // Auto-select first category of new type if available
                         final provider = context.read<ExpenseProvider>();
                         final settings = context.read<SettingsProvider>();
                         final validCategories = provider.categories.where((c) => 
                           !settings.hiddenCategories.contains(c.name) && c.type == _selectedType.name
                         ).toList();
                         
                         if (validCategories.isNotEmpty) {
                           _selectedCategory = validCategories.first;
                         }
                       });
                     },
                    children: {
                      TransactionType.expense: Padding(padding: EdgeInsets.symmetric(horizontal: 4.w), child: const Text('Expense')),
                      TransactionType.income: Padding(padding: EdgeInsets.symmetric(horizontal: 4.w), child: const Text('Income')),
                    },
                  )
                : SegmentedButton<TransactionType>(
                    segments: const [
                       ButtonSegment(value: TransactionType.expense, label: Text('Expense'), icon: Icon(Icons.remove_circle_outline)),
                       ButtonSegment(value: TransactionType.income, label: Text('Income'), icon: Icon(Icons.add_circle_outline)),
                    ],
                    selected: {_selectedType},
                    onSelectionChanged: (v) {
                      setState(() {
                        _selectedType = v.first;
                        _selectedCategory = null;
                        
                        // Auto-select first category of new type if available
                        final provider = context.read<ExpenseProvider>();
                        final settings = context.read<SettingsProvider>();
                        final validCategories = provider.categories.where((c) => 
                           !settings.hiddenCategories.contains(c.name) && c.type == _selectedType.name
                        ).toList();
                         
                        if (validCategories.isNotEmpty) {
                           _selectedCategory = validCategories.first;
                        }
                      });
                    },
                  ),
              ),
              
              SizedBox(height: 3.h),
              
              PlatformTextField(
                controller: _amountController,
                label: 'Amount',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  child: SizedBox(
                    width: 24,
                    child: Text(
                      settings.currency,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        color: Platform.isIOS ? CupertinoColors.systemGrey : Colors.grey,
                      ),
                    ),
                  ),
                ),
                placeholder: '0.00',
              ),
              
              SizedBox(height: 2.h),
              
              PlatformTextField(
                controller: _titleController,
                label: 'Description',
                placeholder: 'What was this for?',
                prefixIcon: Platform.isIOS ? CupertinoIcons.pencil : Icons.edit_note_rounded,
              ),
              
              SizedBox(height: 3.h),
              
              Text(
                'Category',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              SizedBox(height: 1.h),
              
              SizedBox(
                height: 6.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: EdgeInsets.only(right: 2.w),
                      child: ChoiceChip(
                        label: Text(category.name, style: GoogleFonts.outfit(fontSize: 14.sp)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = category);
                        },
                        selectedColor: settings.primaryColor.withValues(alpha: 0.2),
                        checkmarkColor: settings.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? settings.primaryColor : (isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 3.h),
              
              GestureDetector(
                onTap: _showDatePicker,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Platform.isIOS ? CupertinoIcons.calendar : Icons.calendar_today_rounded, color: settings.primaryColor),
                      SizedBox(width: 4.w),
                      Text(
                        'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: GoogleFonts.outfit(fontSize: 16.sp),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 4.h),
              
              SizedBox(
                width: double.infinity,
                child: PlatformButton(
                  onPressed: _submit,
                  color: settings.primaryColor,
                  child: Text(
                    widget.expenseToEdit != null ? 'SAVE CHANGES' : 'ADD TRANSACTION',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
