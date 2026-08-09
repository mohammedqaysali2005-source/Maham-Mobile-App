import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../tasks/presentation/bloc/tasks_bloc.dart';
import '../../../tasks/presentation/bloc/tasks_event.dart';
import '../../../tasks/presentation/bloc/tasks_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<TasksBloc>()..add(TasksLoadRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = (authState is Authenticated) ? authState.user : null;
          final userName = user?.fullName ?? 'مستخدم مهام';
          final userEmail = user?.email ?? '';
          final userRole = user?.role ?? 'Member';
          final userInitial = userName.isNotEmpty ? userName[0] : 'م';

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async {
              context.read<TasksBloc>().add(TasksLoadRequested());
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.md),
                  // Profile Card
                  _buildProfileCard(userInitial, userName, userEmail, userRole),
                  const SizedBox(height: AppSizes.md),

                  // Tasks stats
                  BlocBuilder<TasksBloc, TasksState>(
                    builder: (context, taskState) {
                      int assignedCount = 0;
                      if (taskState is TasksLoaded) {
                        assignedCount = taskState.tasks.length;
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatItem('المهام النشطة', '$assignedCount', Icons.bolt_rounded, AppColors.accent),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: _buildStatItem('الدور الحالي', userRole == 'Admin' ? 'مدير' : 'عضو', Icons.shield_rounded, AppColors.success),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // Actions list
                  _buildActionTile(context, 'تعديل الملف الشخصي', Icons.person_outline_rounded, () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعديل الملف الشخصي قريباً', style: TextStyle(fontFamily: 'Cairo'))));
                  }),
                  _buildActionTile(context, 'تغيير كلمة المرور', Icons.lock_outline_rounded, () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تغيير كلمة المرور قريباً', style: TextStyle(fontFamily: 'Cairo'))));
                  }),
                  _buildActionTile(context, 'تسجيل الخروج', Icons.logout_rounded, () => _showLogoutDialog(context), isDestructive: true),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(String initial, String name, String email, String role) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.accent,
              child: Text(
                initial,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              name,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                role == 'Admin' ? 'مسؤول النظام' : 'عضو فريق العمل',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  label,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String label, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: color),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: color),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
        title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold), textAlign: TextAlign.right),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟', style: TextStyle(fontFamily: 'Cairo'), textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
