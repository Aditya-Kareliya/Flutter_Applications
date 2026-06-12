import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/settings/settings_provider.dart';
import '../../../../core/widgets/platform/platform_scaffold.dart';
import '../provider/expense_provider.dart';
import '../provider/search_provider.dart';
import '../widgets/expense_card.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
       return PlatformScaffold(
         cupertinoNavigationBar: const CupertinoNavigationBar(
           middle: Text('Search'),
           backgroundColor: Colors.transparent, // or standard
           border: null,
         ),
         body: SafeArea(
           child: Column(
             children: [
               Padding(
                 padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                 child: CupertinoSearchTextField(
                   autofocus: true,
                   onChanged: (value) {
                     context.read<SearchProvider>().setQuery(value);
                   },
                   style: GoogleFonts.outfit(),
                 ),
               ),
               Expanded(child: _buildResultsList(context)),
             ],
           ),
         ),
       );
    }

    return PlatformScaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          style: GoogleFonts.outfit(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: 'Search transactions...',
            hintStyle: GoogleFonts.outfit(color: Colors.grey),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (value) {
            context.read<SearchProvider>().setQuery(value);
          },
        ),
        backgroundColor: Colors.transparent, 
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
      ),
      body: _buildResultsList(context),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    return Consumer3<SearchProvider, ExpenseProvider, SettingsProvider>(
      builder: (context, searchProvider, expenseProvider, settings, child) {
        final results = searchProvider.filterExpenses(expenseProvider.expenses).where((e) {
           return !settings.hiddenCategories.contains(e.category.name);
        }).toList();

        if (searchProvider.query.isEmpty) {
          return Center(
            child: Text(
              'Type to search...',
              style: GoogleFonts.outfit(fontSize: 18.sp, color: Colors.grey),
            ),
          );
        }

        if (results.isEmpty) {
          return Center(
            child: Text(
              'No matches found',
              style: GoogleFonts.outfit(fontSize: 18.sp, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w), // Added horizontal padding for cards
          itemCount: results.length,
          itemBuilder: (context, index) {
            return ExpenseCard(expense: results[index]);
          },
        );
      },
    );
  }
}
