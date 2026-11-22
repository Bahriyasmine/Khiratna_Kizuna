import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/main_viewmodel.dart';
import 'mobile/main_mobile_view.dart';
import 'web/main_desktop_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainViewModel(),
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= 900
            ? const MainDesktopView()
            : const MainMobileView(),
      ),
    );
  }
}