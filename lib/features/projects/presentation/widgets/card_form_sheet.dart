import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../features/shell/widgets/sheet_modal.dart';

class CardFormSheet {
  static Future<void> show({
    required BuildContext context,
    String title = 'إضافة بطاقة جديدة',
    String? initialTitle,
    String? initialDesc,
    String? initialPriority,
    DateTime? initialDate,
    VoidCallback? onDelete,
    required void Function(String title, String? description, String priority, DateTime? dueDate) onSubmit,
  }) async {
    final titleCtrl = TextEditingController(text: initialTitle ?? '');
    final descCtrl = TextEditingController(text: initialDesc ?? '');
    final formKey = GlobalKey<FormState>();

    String selectedPriority = initialPriority ?? 'Medium';
    DateTime? selectedDate = initialDate;

    await SheetModal.show(
      context: context,
      title: title,
      initialChildSize: 0.75,
      content: StatefulBuilder(
        builder: (ctx, setState) => Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: titleCtrl,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'عنوان البطاقة *',
                  prefixIcon: Icon(Icons.title_rounded, color: AppColors.accent),
                  hintText: 'عنوان المهمة...',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'عنوان البطاقة مطلوب';
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
                  hintText: 'تفاصيل وشرح المهمة...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Priority Dropdown
              DropdownButtonFormField<String>(
                initialValue: selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'الأولوية',
                  prefixIcon: Icon(Icons.flag_rounded, color: AppColors.accent),
                ),
                alignment: Alignment.centerRight,
                items: const [
                  DropdownMenuItem(value: 'Low', child: Align(alignment: Alignment.centerRight, child: Text('منخفضة', style: TextStyle(fontFamily: 'Cairo')))),
                  DropdownMenuItem(value: 'Medium', child: Align(alignment: Alignment.centerRight, child: Text('متوسطة', style: TextStyle(fontFamily: 'Cairo')))),
                  DropdownMenuItem(value: 'High', child: Align(alignment: Alignment.centerRight, child: Text('عالية', style: TextStyle(fontFamily: 'Cairo')))),
                  DropdownMenuItem(value: 'Critical', child: Align(alignment: Alignment.centerRight, child: Text('حرجة', style: TextStyle(fontFamily: 'Cairo')))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => selectedPriority = val);
                  }
                },
              ),
              const SizedBox(height: AppSizes.md),

              // Due Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_rounded, color: AppColors.accent),
                title: const Text('تاريخ الاستحقاق', style: TextStyle(fontFamily: 'Cairo', fontSize: 14)),
                subtitle: Text(
                  selectedDate != null ? DateFormatter.formatDate(selectedDate!) : 'غير محدد',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.error),
                        onPressed: () => setState(() => selectedDate = null),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit_calendar_rounded, color: AppColors.accent),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.lg),
              Row(
                children: [
                  if (initialTitle != null && onDelete != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          onDelete();
                        },
                        icon: const Icon(Icons.delete_rounded, color: AppColors.error),
                        label: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.of(ctx).pop();
                          onSubmit(
                            titleCtrl.text.trim(),
                            descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                            selectedPriority,
                            selectedDate,
                          );
                        }
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: Text(
                        initialTitle != null ? 'حفظ التعديلات' : 'إضافة البطاقة',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
