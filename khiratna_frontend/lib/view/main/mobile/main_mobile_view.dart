import 'package:flutter/material.dart';
import 'package:khiratna_frontend/view/services/services_screen.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/main_viewmodel.dart';
import '../../home/home_screen.dart';
import '../../profile/profile_screen.dart';

const _green = Color(0xFF0F9D58);

class MainMobileView extends StatelessWidget {
  const MainMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: vm.index,
        children: const [HomeScreen(), ServicesScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: vm.index,
        onTap: vm.setIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _green,
        unselectedItemColor: Colors.grey.shade400,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Services'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}