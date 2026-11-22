import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/profile_viewmodel.dart';
import '../../auth/login_screen.dart';

const _green = Color(0xFF0F9D58);

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label - coming soon')));
  }

  Future<void> _confirmLogout(BuildContext context, ProfileViewModel vm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await vm.logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    if (vm.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 120),
        child: Center(child: CircularProgressIndicator(color: _green)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Profile',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),

        // Header card
        _HeaderCard(name: vm.name, email: vm.email),
        const SizedBox(height: 24),

        // Account
        const _SectionTitle('Account'),
        _SettingsGroup(children: [
          _SettingsTile(
            icon: Icons.person_outline,
            label: 'Edit profile',
            onTap: () => _comingSoon(context, 'Edit profile'),
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            label: 'Change password',
            onTap: () => _comingSoon(context, 'Change password'),
          ),
        ]),
        const SizedBox(height: 20),

        // Preferences
        const _SectionTitle('Preferences'),
        _SettingsGroup(children: [
          _SettingsTile(
            icon: Icons.notifications_none,
            label: 'Notifications',
            onTap: () => _comingSoon(context, 'Notifications'),
          ),
          _SettingsTile(
            icon: Icons.language,
            label: 'Language',
            trailingText: 'English',
            onTap: () => _comingSoon(context, 'Language'),
          ),
        ]),
        const SizedBox(height: 20),

        // Support
        const _SectionTitle('Support'),
        _SettingsGroup(children: [
          _SettingsTile(
            icon: Icons.help_outline,
            label: 'Help & support',
            onTap: () => _comingSoon(context, 'Help & support'),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            label: 'About Khiratna',
            onTap: () => _comingSoon(context, 'About'),
          ),
        ]),
        const SizedBox(height: 28),

        // Logout
        OutlinedButton.icon(
          onPressed: () => _confirmLogout(context, vm),
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text('Khiratna v1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String name, email;
  const _HeaderCard({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: _green.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontSize: 30, color: _green, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'User' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600)),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(Divider(
            height: 1, indent: 60, endIndent: 16, color: Colors.grey.shade200));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.white,
          child: Column(children: items),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _green, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 15)),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(trailingText!,
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}