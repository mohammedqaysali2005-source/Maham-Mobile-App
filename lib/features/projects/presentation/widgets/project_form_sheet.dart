import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../features/shell/widgets/sheet_modal.dart';

class ProjectFormSheet {
  static Future<void> show({
    required BuildContext context,
    String title = 'إنشاء مشروع جديد',
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
              // اسم المشروع
              TextFormField(
                controller: nameCtrl,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'اسم المشروع *',
                  prefixIcon: Icon(Icons.folder_rounded, color: AppColors.accent),
                  hintText: 'مثال: تطوير تطبيق مهام',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'اسم المشروع مطلوب';
                  if (v.trim().length < 3) return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              // الوصف
              TextFormField(
                controller: descCtrl,
                textAlign: TextAlign.right,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'الوصف (اختياري)',
                  prefixIcon: Icon(Icons.description_rounded, color: AppColors.accent),
                  hintText: 'وصف مختصر للمشروع...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              ElevatedButton.icon(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(ctx).pop();
                    onSubmit(
                      nameCtrl.text.trim(),
                      descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                    );
                  }
                },
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  initialName != null ? 'حفظ التعديلات' : 'إنشاء المشروع',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
