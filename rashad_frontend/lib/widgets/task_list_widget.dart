import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rashad_frontend/models/task.dart';
import 'package:rashad_frontend/providers/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:rashad_frontend/services/category_service.dart';
import 'package:rashad_frontend/utils/app_colors.dart';

class TaskListWidget extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskTap;
  final VoidCallback onRefresh;

  const TaskListWidget({
    Key? key,
    required this.tasks,
    required this.onTaskTap,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt_rounded, size: 60, color: AppColors.textHint.withOpacity(0.5)),
            SizedBox(height: 16),
            Text(
              'Henüz göreviniz yok',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final categoryId = task.categoryId;
          final category = CategoryService.getCategoryById(categoryId);

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: task.status == 'completed',
                  onChanged: (value) async {
                    await context.read<TaskProvider>().toggleTaskCompletion(task.id);
                    onRefresh();
                  },
                  activeColor: AppColors.primaryColor,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  decoration: task.status == 'completed'
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    task.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        category.name,
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      Spacer(),
                      Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        DateFormat('dd.MM.yyyy').format(task.dueDate),
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
              onTap: () => onTaskTap(task),
            ),
          );
        },
      ),
    );
  }
}
