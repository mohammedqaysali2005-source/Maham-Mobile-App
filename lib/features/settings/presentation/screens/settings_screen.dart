import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          _buildSectionHeader('عام'),
          _buildSettingTile(
            context,
            'اللغة',
            'العربية (اللغة الافتراضية)',
            Icons.language_rounded,
            () {},
          ),
          _buildSettingSwitchTile(
            context,
            'الوضع الداكن',
            'تفعيل المظهر المظلم للتطبيق (قريباً)',
            Icons.dark_mode_rounded,
            false,
            (val) {},
          ),
          const SizedBox(height: AppSizes.md),
          _buildSectionHeader('التنبيهات'),
          _buildSettingSwitchTile(
            context,
            'إشعارات النظام',
            'تلقي تنبيهات عند تغيير حالة المهام أو إضافة تعليقات',
            Icons.notifications_active_rounded,
            true,
            (val) {},
          ),
          const SizedBox(height: AppSizes.md),
          _buildSectionHeader('الدعم والخصوصية'),
          _buildSettingTile(
            context,
            'سياسة الخصوصية',
            'اقرأ شروط الاستخدام والخصوصية',
            Icons.privacy_tip_rounded,
            () {},
          ),
          _buildSettingTile(
            context,
            'عن التطبيق',
            'معلومات حول منصة مهام لإدارة المشاريع',
            Icons.info_rounded,
            () {},
          ),
          const SizedBox(height: AppSizes.lg),
          const Center(
            child: Text(
              'مهام — الإصدار 1.0.0\nحقوق الطبع محفوظة © 2026',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildSettingSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool val,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        value: val,
        onChanged: onChanged,
        secondary: Icon(icon, color: AppColors.primary),
        activeTrackColor: AppColors.accent,
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
