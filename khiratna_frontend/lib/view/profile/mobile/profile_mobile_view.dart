import 'package:flutter/material.dart';
import '../widgets/profile_content.dart';

class ProfileMobileView extends StatelessWidget {
  const ProfileMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: ProfileContent(),
      ),
    );
  }
}