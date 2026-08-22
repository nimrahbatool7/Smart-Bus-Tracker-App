import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight   = Theme.of(context).brightness == Brightness.light;
    final themeMode = ref.watch(themeProvider);
    final profile   = ref.watch(currentProfileProvider);

    final displayName  = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : 'Rider';
    final displayEmail = ref
            .watch(authRepositoryProvider)
            .currentUser
            ?.email ??
        '';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Profile header ──────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        border: Border.all(
                            color: AppTheme.primaryColor, width: 2),
                      ),
                      child: profile?.avatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                profile!.avatarUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.person,
                                  size: 50, color: AppTheme.primaryColor),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ).animate().scale(duration: 400.ms),

                const SizedBox(height: 16),

                Text(
                  displayName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 4),

                Text(
                  displayEmail,
                  style: TextStyle(
                    color: isLight
                        ? Colors.grey.shade600
                        : Colors.white60,
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ── Theme switcher ──────────────────────────────────────────────
          GlassCard(
            color: isLight ? Colors.white : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLight ? Colors.black87 : Colors.white,
                      ),
                    ),
                  ],
                ),
                DropdownButton<ThemeMode>(
                  value: themeMode,
                  underline: const SizedBox(),
                  dropdownColor:
                      isLight ? Colors.white : AppTheme.surfaceColorDark,
                  style: TextStyle(
                    color: isLight ? Colors.black87 : Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(
                        value: ThemeMode.dark, child: Text('Dark')),
                    DropdownMenuItem(
                        value: ThemeMode.system, child: Text('System')),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      ref
                          .read(themeProvider.notifier)
                          .setThemeMode(mode);
                    }
                  },
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideX(),

          const SizedBox(height: 16),

          _buildSettingsGroup(
            'Account',
            [
              _buildSettingItem(
                  Icons.person_outline, 'Personal Information', isLight),
              _buildSettingItem(
                  Icons.payment, 'Payment Methods', isLight),
              _buildSettingItem(
                  Icons.history, 'Ride History', isLight),
            ],
            500.ms,
          ),

          const SizedBox(height: 16),

          _buildSettingsGroup(
            'Preferences',
            [
              _buildSettingItem(
                  Icons.notifications_outlined, 'Notifications', isLight,
                  hasSwitch: true),
              _buildSettingItem(
                  Icons.security, 'Privacy & Security', isLight),
              _buildSettingItem(
                  Icons.help_outline, 'Help & Support', isLight),
            ],
            600.ms,
          ),

          const SizedBox(height: 40),

          // ── Logout ────────────────────────────────────────────────────
          GestureDetector(
            onTap: () async {
              await ref
                  .read(passengerAuthProvider.notifier)
                  .signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: GlassCard(
              color: Colors.red.withValues(alpha: 0.1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.5),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(
      String title, List<Widget> items, Duration delay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey),
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.all(0),
          child: Column(children: items),
        ),
      ],
    ).animate().fadeIn(delay: delay).slideX();
  }

  Widget _buildSettingItem(IconData icon, String title, bool isLight,
      {bool hasSwitch = false}) {
    return ListTile(
      leading: Icon(icon,
          color: isLight ? Colors.blue.shade700 : Colors.white70),
      title: Text(title,
          style:
              TextStyle(color: isLight ? Colors.black87 : Colors.white)),
      trailing: hasSwitch
          ? Switch(
              value: true,
              onChanged: (val) {},
              activeThumbColor: AppTheme.primaryColor,
            )
          : Icon(Icons.arrow_forward_ios,
              size: 16,
              color: isLight ? Colors.grey : Colors.white54),
      onTap: () {},
    );
  }
}
