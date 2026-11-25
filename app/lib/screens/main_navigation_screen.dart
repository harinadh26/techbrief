/// main_navigation_screen.dart - Bottom Navigation Scaffold for TechBrief
/// Houses Home, Explore, Bookmarks, and Settings tabs.

import 'package:flutter/material.dart';
import '../providers/news_provider.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  final NewsProvider provider;

  const MainNavigationScreen({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: provider,
      builder: (context, _) {
        final currentIndex = provider.activeNavIndex;

        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: [
              HomeScreen(provider: provider),
              ExploreScreen(provider: provider),
              BookmarksScreen(provider: provider),
              SettingsScreen(provider: provider),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              provider.setActiveNavIndex(index);
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore_rounded),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: provider.bookmarks.isNotEmpty,
                  label: Text('${provider.bookmarks.length}'),
                  child: const Icon(Icons.bookmarks_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: provider.bookmarks.isNotEmpty,
                  label: Text('${provider.bookmarks.length}'),
                  child: const Icon(Icons.bookmarks_rounded),
                ),
                label: 'Bookmarks',
              ),
              const NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
