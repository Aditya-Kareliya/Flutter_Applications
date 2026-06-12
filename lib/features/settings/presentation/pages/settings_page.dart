import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import 'manage_categories_page.dart';
import '../../../../core/settings/settings_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/platform/platform_scaffold.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../auth/domain/entities/user.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return PlatformScaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      cupertinoNavigationBar: CupertinoNavigationBar(
        middle: Text('Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, // Or system background
        border: null,
      ),
      body: Consumer3<SettingsProvider, ThemeProvider, AuthProvider>(
        builder: (context, settings, themeProvider, auth, _) {
          final textColor = isDark ? Colors.white : Colors.black;
          final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

          if (Platform.isIOS) {
            return ListView(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              children: [
                CupertinoListSection.insetGrouped(
                  header: Text('APPEARANCE', style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey)),
                  children: [
                    CupertinoListTile(
                      title: Text('Dark Mode', style: GoogleFonts.outfit(color: textColor)),
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.purple.shade400, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(CupertinoIcons.moon_fill, color: Colors.white, size: 18),
                      ),
                      trailing: CupertinoSwitch(
                        value: themeProvider.themeMode == ThemeMode.dark,
                        activeColor: settings.primaryColor,
                        onChanged: (val) {
                          final newMode = val ? ThemeMode.dark : ThemeMode.light;
                          themeProvider.setThemeMode(newMode);
                          _persistSettings(context, auth, settings, themeProvider);
                        },
                      ),
                    ),
                    CupertinoListTile(
                      title: Text('Accent Color', style: GoogleFonts.outfit(color: textColor)),
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.blue.shade400, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(CupertinoIcons.paintbrush_fill, color: Colors.white, size: 18),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(backgroundColor: settings.primaryColor, radius: 12),
                          const SizedBox(width: 8),
                          const Icon(CupertinoIcons.chevron_forward, color: CupertinoColors.systemGrey3, size: 16),
                        ],
                      ),
                      onTap: () => _showColorPicker(context, settings, auth, themeProvider),
                    ),
                  ],
                ),
                
                 CupertinoListSection.insetGrouped(
                  header: Text('PREFERENCES', style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey)),
                  children: [
                    CupertinoListTile(
                      title: Text('Currency', style: GoogleFonts.outfit(color: textColor)),
                       leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.green.shade400, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(CupertinoIcons.money_dollar, color: Colors.white, size: 18),
                      ),
                      additionalInfo: Text(settings.currency, style: GoogleFonts.outfit(color: subtitleColor, fontSize: 16.sp)),
                      trailing: const Icon(CupertinoIcons.chevron_forward, color: CupertinoColors.systemGrey3, size: 16),
                      onTap: () => _showCurrencyPicker(context, settings, auth, themeProvider),
                    ),
                    CupertinoListTile(
                      title: Text('Manage Categories', style: GoogleFonts.outfit(color: textColor)),
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.orange.shade400, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(CupertinoIcons.square_list_fill, color: Colors.white, size: 18),
                      ),
                      trailing: const Icon(CupertinoIcons.chevron_forward, color: CupertinoColors.systemGrey3, size: 16),
                      onTap: () {
                         Navigator.push(
                           context,
                           CupertinoPageRoute(builder: (context) => const ManageCategoriesPage()),
                         );
                      },
                    ),
                  ],
                ),
                
                CupertinoListSection.insetGrouped(
                  header: Text('ACCOUNT', style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey)),
                  children: [
                    CupertinoListTile(
                      title: Text(auth.user?.name ?? 'User', style: GoogleFonts.outfit(color: textColor)),
                      subtitle: Text(auth.user?.email ?? '', style: GoogleFonts.outfit(color: subtitleColor, fontSize: 12.sp)),
                       leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(CupertinoIcons.person_fill, color: Colors.white, size: 18),
                      ),
                    ),
                    CupertinoListTile(
                      title: Text('Logout', style: GoogleFonts.outfit(color: CupertinoColors.destructiveRed)),
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: CupertinoColors.destructiveRed, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(CupertinoIcons.arrow_right_square_fill, color: Colors.white, size: 18),
                      ),
                      onTap: () {
                          context.read<SettingsProvider>().reset();
                          auth.logout();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                ),
              ],
            );
          }

          // Android / Material Layout
          return ListView(
            padding: EdgeInsets.all(4.w),
            children: [
              _buildSectionHeader(context, 'Appearance'),
              SwitchListTile(
                title: Text('Dark Mode', style: GoogleFonts.outfit(color: textColor)),
                secondary: Icon(Icons.dark_mode, color: settings.primaryColor),
                value: themeProvider.themeMode == ThemeMode.dark,
                activeColor: settings.primaryColor,
                onChanged: (val) {
                  final newMode = val ? ThemeMode.dark : ThemeMode.light;
                  themeProvider.setThemeMode(newMode);
                  _persistSettings(context, auth, settings, themeProvider);
                },
              ),
              ListTile(
                title: Text('Accent Color', style: GoogleFonts.outfit(color: textColor)),
                leading: Icon(Icons.color_lens, color: settings.primaryColor),
                trailing: CircleAvatar(backgroundColor: settings.primaryColor, radius: 15),
                onTap: () => _showColorPicker(context, settings, auth, themeProvider), 
              ),
              
              SizedBox(height: 2.h),
              _buildSectionHeader(context, 'Preferences'),
              ListTile(
                title: Text('Currency', style: GoogleFonts.outfit(color: textColor)),
                leading: Icon(Icons.attach_money, color: settings.primaryColor),
                trailing: Text(settings.currency, style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold, color: textColor)),
                onTap: () => _showCurrencyPicker(context, settings, auth, themeProvider),
              ),
              ListTile(
                title: Text('Manage Categories', style: GoogleFonts.outfit(color: textColor)),
                leading: Icon(Icons.category, color: settings.primaryColor),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: subtitleColor),
                onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const ManageCategoriesPage()),
                   );
                },
              ),

              SizedBox(height: 2.h),
              _buildSectionHeader(context, 'A ccount'),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.grey),
                title: Text(auth.user?.name ?? 'User', style: GoogleFonts.outfit(color: textColor)),
                subtitle: Text(auth.user?.email ?? '', style: GoogleFonts.outfit(color: subtitleColor)),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text('Logout', style: GoogleFonts.outfit(color: Colors.red)),
                onTap: () {
                   context.read<SettingsProvider>().reset();
                   auth.logout();
                   Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
      ),
    );
  }

  void _persistSettings(
      BuildContext context, AuthProvider auth, SettingsProvider settings, ThemeProvider themeProvider) {
      if (auth.user != null) {
        // Using value for now as it works reliably across versions, ignoring deprecation for this specific line if analyzer complains
        // ignore: deprecated_member_use
        final colorValue = settings.primaryColor.value; 
        
        final updatedUser = auth.user!.copyWith(
          currency: settings.currency,
          themeMode: themeProvider.themeMode.toString().split('.').last,
          themeColor: '0x${colorValue.toRadixString(16).padLeft(8, '0').toUpperCase()}',
        );
        auth.updateUser(updatedUser);
      }
  }

  void _showColorPicker(BuildContext context, SettingsProvider settings, AuthProvider auth, ThemeProvider themeProvider) {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.indigo
    ];

    if (Platform.isIOS) {
       showCupertinoModalPopup(
        context: context,
        builder: (ctx) => Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
               Text('Pick Color', style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold)),
               SizedBox(height: 2.h),
               Expanded(
                 child: GridView.count(
                   crossAxisCount: 4,
                   mainAxisSpacing: 10,
                   crossAxisSpacing: 10,
                   children: colors.map((c) => GestureDetector(
                     onTap: () {
                        settings.updatePrimaryColor(c);
                        _persistSettings(context, auth, settings, themeProvider);
                        Navigator.pop(ctx);
                     },
                     child: CircleAvatar(backgroundColor: c, radius: 20),
                   )).toList(),
                 ),
               ),
            ],
          ),
        ),
      );
    } else {
      showDialog(
        context: context, 
        builder: (ctx) => AlertDialog(
          title: Text('Pick Color', style: GoogleFonts.outfit()),
          content: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: colors.map((c) => GestureDetector(
              onTap: () {
                settings.updatePrimaryColor(c);
                _persistSettings(context, auth, settings, themeProvider);
                Navigator.pop(ctx);
              },
              child: CircleAvatar(backgroundColor: c, radius: 20),
            )).toList(),
          ),
        )
      );
    }
  }

  void _showCurrencyPicker(BuildContext context, SettingsProvider settings, AuthProvider auth, ThemeProvider themeProvider) {
     final currencies = ['₹', '\$', '€', '£', '¥', 'Custom'];
     
     if (Platform.isIOS) {
       showCupertinoModalPopup(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          title: Text('Select Currency', style: GoogleFonts.outfit()),
          actions: currencies.map((c) => CupertinoActionSheetAction(
             onPressed: () {
                Navigator.pop(ctx);
                if (c == 'Custom') {
                  _showCustomCurrencyDialog(context, settings, auth, themeProvider);
                } else {
                  settings.updateCurrency(c);
                  _persistSettings(context, auth, settings, themeProvider);
                }
             },
             child: Text(c, style: GoogleFonts.outfit(fontSize: 18.sp, color: CupertinoColors.label.resolveFrom(context))), 
          )).toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx),
            isDestructiveAction: true,
            child: const Text('Cancel'),
          ),
        ),
       );
     } else {
       showDialog(
        context: context, 
        builder: (ctx) => SimpleDialog(
          title: Text('Select Currency', style: GoogleFonts.outfit()),
          children: currencies.map((c) => SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              if (c == 'Custom') {
                _showCustomCurrencyDialog(context, settings, auth, themeProvider);
              } else {
                settings.updateCurrency(c);
                _persistSettings(context, auth, settings, themeProvider);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(c, style: GoogleFonts.outfit(fontSize: 18.sp)),
            ),
          )).toList(),
        )
      );
     }
  }

  void _showCustomCurrencyDialog(
      BuildContext context, SettingsProvider settings, AuthProvider auth, ThemeProvider themeProvider) {
    final controller = TextEditingController(text: settings.currency);
    
    // We can use a platform-specific dialog wrapper if strict parity needed, 
    // but AlertDialog.adaptive usually handles fields poorly on iOS (CupertinoAlertDialog doesn't natively support TextFormField easily without tricks).
    // So for consistency, let's use a Material dialog or explicit CupertinoDialog with a CupertinoTextField.
    
    if (Platform.isIOS) {
       showCupertinoDialog(
         context: context, 
         builder: (ctx) => CupertinoAlertDialog(
           title: const Text('Custom Currency'),
           content: Padding(
             padding: const EdgeInsets.only(top: 10),
             child: CupertinoTextField(
               controller: controller, 
               placeholder: 'Symbol (e.g. BTC)',
               autofocus: true,
             ),
           ),
           actions: [
             CupertinoDialogAction(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
             CupertinoDialogAction(
               onPressed: () {
                 if (controller.text.isNotEmpty) {
                    settings.updateCurrency(controller.text);
                    _persistSettings(context, auth, settings, themeProvider);
                 }
                 Navigator.pop(ctx);
               }, 
               child: const Text('Save'),
             ),
           ],
         )
       );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Custom Currency'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Symbol (e.g. BTC)'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  settings.updateCurrency(controller.text);
                  _persistSettings(context, auth, settings, themeProvider);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        )
      );
    }
  }
}

// Extension to help copyWith on User since we didn't add it to entity yet
extension UserCopyWith on User {
  User copyWith({
    String? name,
    String? currency,
    String? themeMode,
    String? themeColor,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}
