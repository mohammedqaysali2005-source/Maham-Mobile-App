import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../features/shell/widgets/sheet_modal.dart';

class ColumnFormSheet {
  static Future<void> show({
    required BuildContext context,
    String title = 'إضافة عمود جديد',
    String? initialName,
    required void Function(String name) onSubmit,
  }) async {
    final nameCtrl = TextEditingController(text: initialName ?? '');
    final formKey = GlobalKey<FormState>();

    await SheetModal.show(
      context: context,
      title: title,
      initialChildSize: 0.4,
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
                  labelText: 'اسم العمود *',
                  prefixIcon: Icon(Icons.view_column_rounded, color: AppColors.accent),
                  hintText: 'مثال: قيد المراجعة',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'اسم العمود مطلوب';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.lg),
              ElevatedButton.icon(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(ctx).pop();
                    onSubmit(nameCtrl.text.trim());
                  }
                },
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  initialName != null ? 'حفظ التعديلات' : 'إضافة العمود',
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
