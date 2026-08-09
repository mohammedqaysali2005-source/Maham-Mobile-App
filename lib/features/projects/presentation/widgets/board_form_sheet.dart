import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../features/shell/widgets/sheet_modal.dart';

class BoardFormSheet {
  static Future<void> show({
    required BuildContext context,
    String title = 'إنشاء لوحة جديدة',
    String? initialName,
    String? initialDesc,
    required void Function(String name, String? description) onSubmit,
  }) async {
    final nameCtrl = TextEditingController(text: initialName ?? '');
    final descCtrl = TextEditingController(text: initialDesc ?? '');
    final formKey = GlobalKey<FormState>();

    await SheetModal.show(
      context: context,
      title: title,
      initialChildSize: 0.55,
      content: StatefulBuilder(
        builder: (ctx, setState) => Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameCtrl,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'اسم اللوحة *',
                  prefixIcon: Icon(Icons.dashboard_rounded, color: AppColors.accent),
                  hintText: 'مثال: لوحة التطوير الرئيسية',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'اسم اللوحة مطلوب';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: descCtrl,
                textAlign: TextAlign.right,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'الوصف (اختياري)',
                  prefixIcon: Icon(Icons.description_rounded, color: AppColors.accent),
                  hintText: 'أضف وصفاً للوحة العمل...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              ElevatedButton.icon(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(ctx).pop();
                    onSubmit(nameCtrl.text.trim(), descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim());
                  }
                },
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  initialName != null ? 'حفظ التعديلات' : 'إنشاء اللوحة',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
