import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/profile_viewmodel.dart';
import '../../auth/login_screen.dart';

const _green = Color(0xFF0F9D58);

class ProfileDesktopView extends StatelessWidget {
  const ProfileDesktopView({super.key});

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
      return const Center(child: CircularProgressIndicator(color: _green));
    }

    return SingleChildScrollView(
      // bottom padding keeps content clear of the floating nav bar
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 140),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profile',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Manage your account and preferences',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: identity card
                  SizedBox(
                    width: 320,
                    child: _IdentityCard(
                      name: vm.name,
                      email: vm.email,
                      onLogout: () => _confirmLogout(context, vm),
                    ),
                  ),
                  const SizedBox(width: 28),

                  // Right: settings
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Section(
                          title: 'Account',
                          children: [
                            _Tile(
                              icon: Icons.person_outline,
                              label: 'Edit profile',
                              subtitle: 'Update your name and details',
                              onTap: () => _comingSoon(context, 'Edit profile'),
                            ),
                            _Tile(
                              icon: Icons.lock_outline,
                              label: 'Change password',
                              subtitle: 'Keep your account secure',
                              onTap: () =>
                                  _comingSoon(context, 'Change password'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _Section(
                          title: 'Preferences',
                          children: [
                            _Tile(
                              icon: Icons.notifications_none,
                              label: 'Notifications',
                              subtitle: 'Choose what you get alerted about',
                              onTap: () =>
                                  _comingSoon(context, 'Notifications'),
                            ),
                            _Tile(
                              icon: Icons.language,
                              label: 'Language',
                              subtitle: 'App language',
                              trailingText: 'English',
                              onTap: () => _comingSoon(context, 'Language'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _Section(
                          title: 'Support',
                          children: [
                            _Tile(
                              icon: Icons.help_outline,
                              label: 'Help & support',
                              subtitle: 'Get help with Khiratna',
                              onTap: () =>
                                  _comingSoon(context, 'Help & support'),
                            ),
                            _Tile(
                              icon: Icons.info_outline,
                              label: 'About Khiratna',
                              subtitle: 'Version 1.0.0',
                              onTap: () => _comingSoon(context, 'About'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final String name, email;
  final VoidCallback onLogout;
  const _IdentityCard({
    required this.name,
    required this.email,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: _green.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: Colors.white,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontSize: 44, color: _green, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            name.isEmpty ? 'User' : name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Log out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(Divider(
            height: 1, indent: 72, endIndent: 20, color: Colors.grey.shade200));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
        ),
        Container(
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
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final String? trailingText;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: _green.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _green, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(trailingText!,
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade500)),
              ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}