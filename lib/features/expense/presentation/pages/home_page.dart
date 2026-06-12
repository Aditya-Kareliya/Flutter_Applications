import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/navigation_provider.dart';
import 'dashboard_page.dart';
import 'stats_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, nav, child) {
        if (Platform.isIOS) {
          return CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              currentIndex: nav.currentIndex,
              onTap: (index) => nav.setIndex(index),
              activeColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF1E1E1E) // Darker grey for tab bar in dark mode
                  : const Color(0xFFFAFAFA), // Off-white for light mode
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white12 
                      : Colors.black12,
                  width: 0.5,
                ),
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.home),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.chart_pie),
                  label: 'Analytics',
                ),
              ],
            ),
            tabBuilder: (context, index) {
              return index == 0 ? const DashboardPage() : const StatsPage();
            },
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: nav.currentIndex,
            children: const [
              DashboardPage(),
              StatsPage(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: nav.currentIndex,
            onDestinationSelected: (index) {
              nav.setIndex(index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.pie_chart_outline),
                selectedIcon: Icon(Icons.pie_chart),
                label: 'Stats',
              ),
            ],
          ),
        );
      },
    );
  }
}
