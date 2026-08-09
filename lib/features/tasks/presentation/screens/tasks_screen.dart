import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/models/priority_enum.dart';
import '../../../../shared/models/card_status_enum.dart';
import '../../../projects/data/models/card_model.dart';
import '../bloc/tasks_bloc.dart';
import '../bloc/tasks_event.dart';
import '../bloc/tasks_state.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<TasksBloc>()..add(TasksLoadRequested()),
      child: const _TasksView(),
    );
  }
}

class _TasksView extends StatelessWidget {
  const _TasksView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is TasksLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          if (state is TasksFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      state.message,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.md),
                    ElevatedButton(
                      onPressed: () => context.read<TasksBloc>().add(TasksLoadRequested()),
                      child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is TasksLoaded) {
            final tasks = state.tasks;
            if (tasks.isEmpty) {
              return RefreshIndicator(
                color: AppColors.accent,
                onRefresh: () async {
                  context.read<TasksBloc>().add(TasksLoadRequested());
                  await Future.delayed(const Duration(milliseconds: 600));
                },
                child: ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                    const Center(
                      child: Column(
                        children: [
                          Icon(Icons.task_rounded, size: 80, color: AppColors.border),
                          SizedBox(height: AppSizes.md),
                          Text(
                            'لا توجد مهام مسندة إليك',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                          SizedBox(height: AppSizes.sm),
                          Text(
                            'ستظهر المهام التي تُسند إليك هنا',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () async {
                context.read<TasksBloc>().add(TasksLoadRequested());
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSizes.md),
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                itemBuilder: (ctx, i) {
                  final task = tasks[i];
                  return _buildTaskCard(task);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTaskCard(CardModel task) {
    final priorityColor = _getPriorityColor(task.priority);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.priority.label,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: priorityColor),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.status.label,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              task.title,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description!,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (task.dueDate != null) ...[
              const SizedBox(height: AppSizes.sm),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14, color: DateFormatter.isOverdue(task.dueDate) ? AppColors.error : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'تاريخ الاستحقاق: ${DateFormatter.formatDate(task.dueDate!)}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DateFormatter.isOverdue(task.dueDate) ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(Priority p) {
    switch (p) {
      case Priority.low:
        return AppColors.success;
      case Priority.medium:
        return AppColors.warning;
      case Priority.high:
        return AppColors.error;
      case Priority.critical:
        return AppColors.priorityCritical;
    }
  }
}
