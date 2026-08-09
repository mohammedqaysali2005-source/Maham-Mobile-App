import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';

class AppDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AppDrawer({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
      ),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final userName = (state is Authenticated)
              ? state.user.fullName
              : 'مستخدم مهام';
          final userEmail = (state is Authenticated)
              ? state.user.email
              : 'user@maham.com';
          final userInitial = userName.isNotEmpty ? userName[0] : 'م';

          return Column(
            children: [
              _buildHeader(context, userName, userEmail, userInitial),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.grid_view_rounded,
                      label: AppStrings.home,
                      path: '/home',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.folder_rounded,
                      label: AppStrings.projects,
                      path: '/projects',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.task_alt_rounded,
                      label: AppStrings.tasks,
                      path: '/tasks',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.person_rounded,
                      label: AppStrings.profile,
                      path: '/profile',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.settings_rounded,
                      label: AppStrings.settings,
                      path: '/settings',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: _buildLogoutItem(context),
              ),
              _buildVersion(),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, String userEmail,
      String userInitial) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E1B4B),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'نسخة المؤسسة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            userName,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (userEmail.isNotEmpty)
            Text(
              userEmail,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.5,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String path,
  }) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final isSelected = currentLocation.startsWith(path);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.accent : AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.accent.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        horizontalTitleGap: 4,
        onTap: () {
          Navigator.of(context).pop();
          context.go(path);
        },
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.logout_rounded,
        color: AppColors.error,
        size: 22,
      ),
      title: const Text(
        AppStrings.logout,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: AppColors.error,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: () {
        Navigator.of(context).pop();
        _showLogoutDialog(context);
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800),
          textAlign: TextAlign.right,
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج من الحساب؟',
          style: TextStyle(fontFamily: 'Cairo'),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersion() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text(
        'منصة مهام • Maham Enterprise v1.0.0',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
