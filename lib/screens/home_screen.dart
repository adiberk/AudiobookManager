// lib/screens/main_screen.dart
import 'package:flutter/material.dart';

import 'audiobook_player_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => _buildPage(_selectedIndex),
          );
        },
      ),
      bottomSheet: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: Container(
          height: 55,
          color: Theme.of(context).colorScheme.secondary,
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Currently Playing Book'),
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _navigatorKey.currentState?.popUntil((route) => route.isFirst);
        },
        backgroundColor: Theme.of(context).canvasColor,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        // unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed, // or .fixed
        elevation: 20,
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const Center(child: Text('Profile Page'));
      case 2:
        return const Center(child: Text('Settings Page'));
      default:
        return const HomeScreen();
    }
  }
}

// lib/screens/home_screen.dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AudioBook Player'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // color: Theme.of(context).cardColor,
            child: ListTile(
              leading: const Icon(Icons.book),
              title: Text(
                'Audiobook ${index + 1}',
              ),
              subtitle: Text('Author Name'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AudiobookPlayer(index: index),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
