import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rashad_frontend/providers/user_provider.dart';
import 'package:rashad_frontend/providers/task_provider.dart';
import 'package:rashad_frontend/utils/app_colors.dart';

class AdminViewWidget extends StatefulWidget {
  @override
  _AdminViewWidgetState createState() => _AdminViewWidgetState();
}

class _AdminViewWidgetState extends State<AdminViewWidget> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      context.read<UserProvider>().loadUsers(),
      context.read<TaskProvider>().loadAllTasks(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Veriler yükleniyor...',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        final users = context.watch<UserProvider>().users;
        final allTasks = context.watch<TaskProvider>().tasks;
        final isTasksLoading = context.watch<TaskProvider>().isLoading;

        if (users.isEmpty) {
          return Center(
            child: Text(
              'Henüz kullanıcı bulunmuyor',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final userTasks = allTasks.where((t) => t.userId == user.id).toList();
            final completedTasks =
                userTasks.where((t) => t.status == 'completed').length;

            return Card(
              elevation: 0,
              color: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.textHint.withOpacity(0.1)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: user.role == 'admin'
                      ? AppColors.error.withOpacity(0.2)
                      : AppColors.primaryColor.withOpacity(0.2),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: user.role == 'admin' ? AppColors.error : AppColors.primaryColor,
                    ),
                  ),
                ),
                title: Text(
                  user.name,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: AppColors.textSecondary),
                        SizedBox(width: 4),
                        Text(
                          userTasks.isNotEmpty 
                            ? '$completedTasks/${userTasks.length} tamamlandı'
                            : (isTasksLoading ? 'Yükleniyor...' : 'Görev verisi yok'),
                          style: TextStyle(fontSize: 12),
                        ),
                        if (userTasks.isNotEmpty) ...[
                          SizedBox(width: 16),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: completedTasks / userTasks.length,
                              backgroundColor: AppColors.background,
                              color: user.role == 'admin'
                                  ? AppColors.error
                                  : AppColors.primaryColor,
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.role == 'admin'
                            ? AppColors.error.withOpacity(0.2)
                            : AppColors.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: user.role == 'admin' ? AppColors.error : AppColors.primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.list_alt_rounded, color: AppColors.primaryColor),
                      onPressed: () => _showUserTasks(context, user),
                      tooltip: 'Görevleri Listele',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUserTasks(BuildContext context, user) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                      child: Text(user.name[0].toUpperCase()),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Görev Listesi',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: context.read<TaskProvider>().getUserTasks(user.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Hata: ${snapshot.error}'));
                    }
                    final tasks = snapshot.data as List?;
                    if (tasks == null || tasks.isEmpty) {
                      return Center(
                        child: Text(
                          'Henüz görev eklenmemiş',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return ListTile(
                          leading: Icon(
                            task.status == 'completed' 
                              ? Icons.check_circle 
                              : Icons.radio_button_unchecked,
                            color: task.status == 'completed' 
                              ? Colors.green 
                              : AppColors.textHint,
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.status == 'completed' 
                                ? TextDecoration.lineThrough 
                                : null,
                            ),
                          ),
                          subtitle: Text(task.description),
                          trailing: Text(
                            '${task.dueDate.day}/${task.dueDate.month}',
                            style: TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
