import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/models/priority_enum.dart';
import '../../../../shared/models/card_status_enum.dart';
import '../../data/models/board_model.dart';
import '../../data/models/column_model.dart';
import '../../data/models/card_model.dart';
import '../bloc/board_bloc.dart';
import '../bloc/board_event.dart';
import '../bloc/board_state.dart';
import '../widgets/column_form_sheet.dart';
import '../widgets/card_form_sheet.dart';

class BoardKanbanScreen extends StatelessWidget {
  final String projectId;
  final String boardId;

  const BoardKanbanScreen({super.key, required this.projectId, required this.boardId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<BoardBloc>()..add(BoardDetailLoadRequested(boardId)),
      child: _BoardKanbanView(projectId: projectId, boardId: boardId),
    );
  }
}

class _BoardKanbanView extends StatelessWidget {
  final String projectId;
  final String boardId;

  const _BoardKanbanView({required this.projectId, required this.boardId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: BlocBuilder<BoardBloc, BoardState>(
          builder: (context, state) {
            final title = (state is BoardDetailLoaded) ? state.board.name : 'لوحة كانبان';
            return Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Colors.white,
              ),
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.go('/projects/$projectId'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add_rounded, color: Colors.white, size: 26),
            onPressed: () => _addColumn(context),
            tooltip: 'إضافة عمود جديد',
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
              ],
            ),
          ),
        ),
      ),
      body: BlocConsumer<BoardBloc, BoardState>(
        listener: (context, state) {
          if (state is BoardActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ));
          }
          if (state is BoardFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ));
          }
        },
        builder: (context, state) {
          if (state is BoardDetailLoading || state is BoardActionInProgress) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          if (state is BoardDetailLoaded) {
            final board = state.board;
            return _buildColumnsList(context, board);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildColumnsList(BuildContext context, BoardModel board) {
    if (board.columns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.accentLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.view_column_rounded, size: 48, color: AppColors.accent),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد أعمدة في هذه اللوحة بعد',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'أضف أعمدة مثل (قيد الانتظار، جاري العمل، مكتمل)',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => _addColumn(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة أول عمود'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      itemCount: board.columns.length,
      itemBuilder: (ctx, i) {
        final col = board.columns[i];
        return _buildColumnWrapper(context, board, col);
      },
    );
  }

  Widget _buildColumnWrapper(BuildContext context, BoardModel board, ColumnModel column) {
    return DragTarget<CardModel>(
      onAcceptWithDetails: (details) {
        final card = details.data;
        if (card.columnId != column.id) {
          context.read<BoardBloc>().add(CardMoveRequested(
                boardId: boardId,
                cardId: card.id,
                targetColumnId: column.id,
                newOrder: column.cards.length,
              ));
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isOver = candidateData.isNotEmpty;
        return Container(
          width: 290,
          margin: const EdgeInsets.only(left: 14),
          decoration: BoxDecoration(
            color: isOver ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isOver ? AppColors.accent : const Color(0xFFE2E8F0),
              width: isOver ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Column Header
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 14, 14, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '${column.cards.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        column.name,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary, size: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onSelected: (val) {
                        if (val == 'edit') _editColumn(context, column);
                        if (val == 'delete') _deleteColumn(context, column);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('تعديل العمود', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('حذف العمود', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              // Cards List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: column.cards.length,
                  itemBuilder: (ctx, i) {
                    final card = column.cards[i];
                    return _buildCardDraggable(context, card);
                  },
                ),
              ),
              // Footer Add Card Button
              Padding(
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _addCard(context, column),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, size: 18, color: AppColors.accent),
                        SizedBox(width: 4),
                        Text(
                          'إضافة بطاقة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardDraggable(BuildContext context, CardModel card) {
    return Draggable<CardModel>(
      data: card,
      feedback: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 270,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            card.title,
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _buildCardItem(context, card),
      ),
      child: _buildCardItem(context, card),
    );
  }

  Widget _buildCardItem(BuildContext context, CardModel card) {
    final priorityColor = _getPriorityColor(card.priority);
    final priorityBg = _getPriorityBgColor(card.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _editCard(context, card),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    card.priority.label,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: priorityColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  card.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Description
                if (card.description != null && card.description!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    card.description!,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                // Footer: Due Date & Assignee Avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (card.dueDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: DateFormatter.isOverdue(card.dueDate) ? AppColors.error : AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.formatDate(card.dueDate!),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: DateFormatter.isOverdue(card.dueDate) ? AppColors.error : AppColors.textMuted,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    if (card.assigneeName != null)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accent, width: 1.2),
                        ),
                        child: Center(
                          child: Text(
                            card.assigneeName!.substring(0, 1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
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

  Color _getPriorityBgColor(Priority p) {
    switch (p) {
      case Priority.low:
        return AppColors.successLight;
      case Priority.medium:
        return AppColors.warningLight;
      case Priority.high:
        return AppColors.errorLight;
      case Priority.critical:
        return const Color(0xFFF5F3FF);
    }
  }

  void _addColumn(BuildContext context) {
    ColumnFormSheet.show(
      context: context,
      onSubmit: (name) {
        context.read<BoardBloc>().add(ColumnCreateRequested(
              boardId: boardId,
              name: name,
            ));
      },
    );
  }

  void _editColumn(BuildContext context, ColumnModel col) {
    ColumnFormSheet.show(
      context: context,
      title: 'تعديل العمود',
      initialName: col.name,
      onSubmit: (name) {
        context.read<BoardBloc>().add(ColumnUpdateRequested(
              boardId: boardId,
              columnId: col.id,
              name: name,
            ));
      },
    );
  }

  void _deleteColumn(BuildContext context, ColumnModel col) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف العمود', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800), textAlign: TextAlign.right),
        content: Text('هل تريد حذف العمود "${col.name}"؟ سيتم حذف جميع البطاقات بداخله.', style: const TextStyle(fontFamily: 'Cairo'), textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BoardBloc>().add(ColumnDeleteRequested(boardId: boardId, columnId: col.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _addCard(BuildContext context, ColumnModel col) {
    CardFormSheet.show(
      context: context,
      onSubmit: (title, desc, prio, due) {
        context.read<BoardBloc>().add(CardCreateRequested(
              boardId: boardId,
              columnId: col.id,
              title: title,
              description: desc,
              priority: prio,
              dueDate: due,
            ));
      },
    );
  }

  void _editCard(BuildContext context, CardModel card) {
    CardFormSheet.show(
      context: context,
      title: 'تعديل البطاقة',
      initialTitle: card.title,
      initialDesc: card.description,
      initialPriority: card.priority.apiValue,
      initialDate: card.dueDate,
      onSubmit: (title, desc, prio, due) {
        context.read<BoardBloc>().add(CardUpdateRequested(
              boardId: boardId,
              cardId: card.id,
              title: title,
              description: desc,
              priority: prio,
              status: card.status.apiValue,
              dueDate: due,
            ));
      },
    );
  }
}
