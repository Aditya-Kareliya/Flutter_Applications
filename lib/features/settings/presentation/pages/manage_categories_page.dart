import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/settings/settings_provider.dart';
import '../../../../core/widgets/platform/platform_scaffold.dart';
import '../../../expense/domain/entities/category.dart';
import '../../../expense/domain/entities/transaction_type.dart';
import '../../../expense/presentation/provider/expense_provider.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TransactionType _selectedType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedType = _tabController.index == 0 ? TransactionType.expense : TransactionType.income;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PlatformScaffold(
      appBar: AppBar(
        title: Text('Manage Categories', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          if (Platform.isIOS)
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.add),
              onPressed: () => _showAddEditCategoryDialog(context, type: _selectedType),
            )
        ],
        bottom: Platform.isAndroid ? TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          indicatorColor: theme.primaryColor,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ) : null,
      ),
      cupertinoNavigationBar: CupertinoNavigationBar(
        middle: Text('Manage Categories', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        border: null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () => _showAddEditCategoryDialog(context, type: _selectedType),
        ),
      ),
      floatingActionButton: Platform.isAndroid
          ? FloatingActionButton(
              onPressed: () => _showAddEditCategoryDialog(context, type: _selectedType),
              child: const Icon(Icons.add),
            )
          : null,
      body: Consumer2<ExpenseProvider, SettingsProvider>(
        builder: (context, expenseProvider, settings, _) {
          final categories = expenseProvider.categories.where((c) => c.type == _selectedType.name).toList();

          return Column(
              children: [
                if (Platform.isIOS) ...[
                  SizedBox(height: 1.h),
                   Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<TransactionType>(
                          groupValue: _selectedType,
                          onValueChanged: (v) {
                            if (v != null) setState(() => _selectedType = v);
                          },
                          children: const {
                             TransactionType.expense: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Expense')),
                             TransactionType.income: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Income')),
                          },
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],

                if (categories.isEmpty) 
                   Padding(
                     padding: EdgeInsets.only(top: 5.h),
                     child: const Center(child: Text("No categories found")),
                   )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(4.w),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isHidden = settings.hiddenCategories.contains(category.name);

                        if (Platform.isIOS) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 1.h),
                            decoration: BoxDecoration(
                              color: isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CupertinoListTile(
                              title: Text(category.name, style: GoogleFonts.outfit()),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CupertinoSwitch(
                                    value: !isHidden,
                                    activeTrackColor: settings.primaryColor,
                                    onChanged: (val) {
                                      settings.toggleCategoryVisibility(category.name);
                                    },
                                  ),
                                  CupertinoButton(
                                     padding: EdgeInsets.zero,
                                     child: const Icon(CupertinoIcons.pencil),
                                     onPressed: () => _showAddEditCategoryDialog(context, category: category),
                                  ),
                                  CupertinoButton(
                                     padding: EdgeInsets.zero,
                                     child: const Icon(CupertinoIcons.trash, color: CupertinoColors.destructiveRed),
                                     onPressed: () => _confirmDelete(context, category, expenseProvider),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Dismissible(
                          key: Key(category.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                             return await _confirmDelete(context, category, expenseProvider, onlyBool: true) ?? false;
                          },
                          child: SwitchListTile(
                            title: Text(category.name, style: GoogleFonts.outfit()),
                            secondary: IconButton(
                              icon: const Icon(Icons.edit_rounded),
                              onPressed: () => _showAddEditCategoryDialog(context, category: category),
                            ),
                            value: !isHidden,
                            activeTrackColor: settings.primaryColor,
                            onChanged: (val) {
                              settings.toggleCategoryVisibility(category.name);
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, Category category, ExpenseProvider provider, {bool onlyBool = false}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete ${category.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && !onlyBool) {
      provider.deleteCategory(category.id);
    }
    return confirmed;
  }

  void _showAddEditCategoryDialog(BuildContext context, {Category? category, TransactionType? type}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    
    // If editing, use category's type. If adding, use passed type (from tab)
    String selectedType = category?.type ?? (type == TransactionType.income ? 'income' : 'expense');
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text(isEditing ? 'Edit Category' : 'New Category'),
          content: Material(
             color: Colors.transparent,
             child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                SizedBox(height: 2.h),
                // Displaying type only, not editable if added via specific tab, or maybe allow changing?
                // For simplicity and to match request "expense category display only expense", let's fix it to the tab.
                Row(
                   children: [
                     const Text("Type: "),
                     Text(selectedType.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                   ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final provider = context.read<ExpenseProvider>();
                  if (isEditing) {
                    final updated = Category(
                      id: category.id,
                      name: nameController.text,
                      icon: category.icon, // Keep same
                      color: category.color, // Keep same
                      type: selectedType, 
                    );
                    provider.updateCategory(updated);
                  } else {
                    final newCat = Category(
                      id: const Uuid().v4(),
                      name: nameController.text,
                      icon: 'help', // Default
                      color: '0xFF9E9E9E', // Default grey
                      type: selectedType,
                    );
                    provider.addCategory(newCat);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
