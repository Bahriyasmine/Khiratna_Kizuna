import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/profile_viewmodel.dart';
import 'mobile/profile_mobile_view.dart';
import 'web/profile_desktop_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= 700
            ? const ProfileDesktopView()
            : const ProfileMobileView(),
      ),
    );
  }
}