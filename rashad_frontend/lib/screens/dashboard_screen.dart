import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rashad_frontend/models/user.dart';
import 'package:rashad_frontend/models/task.dart';
import 'package:rashad_frontend/providers/user_provider.dart';
import 'package:rashad_frontend/services/category_service.dart';
import 'package:rashad_frontend/providers/auth_provider.dart';
import 'package:rashad_frontend/providers/task_provider.dart';
import 'package:rashad_frontend/screens/task_detail_screen.dart';
import 'package:rashad_frontend/screens/calendar_view_screen.dart';
import 'package:rashad_frontend/screens/program_management_screen.dart';
import 'package:rashad_frontend/screens/ai_screen.dart';
import 'package:rashad_frontend/screens/edit_profile_screen.dart';
import 'package:rashad_frontend/utils/app_colors.dart';
import 'package:rashad_frontend/widgets/admin_view_widget.dart';
import 'package:rashad_frontend/widgets/categories_grid_widget.dart';
import 'package:rashad_frontend/widgets/task_list_widget.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isAdminView = false;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      context.read<TaskProvider>().loadTasks(),
      context.read<UserProvider>().loadUsers(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarViewScreen()),
              );
            },
            tooltip: 'Takvim',
          ),
          IconButton(
            icon: Icon(Icons.auto_awesome_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AIScreen()),
              );
            },
            tooltip: 'AI Asistan',
          ),
          IconButton(
            icon: Icon(Icons.hub_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProgramManagementScreen(
                    currentUser: currentUser!,
                  ),
                ),
              );
            },
            tooltip: 'Programlar',
          ),
          if (currentUser?.role == 'admin')
            IconButton(
              icon: Icon(_isAdminView ? Icons.person : Icons.admin_panel_settings),
              onPressed: () {
                setState(() {
                  _isAdminView = !_isAdminView;
                });
              },
              tooltip: _isAdminView ? 'Kullanıcı Görünümü' : 'Admin Görünümü',
            ),
        ],
      ),
      body: _buildBody(currentUser),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddTaskDialog(context, currentUser),
              icon: Icon(Icons.add_rounded),
              label: Text('Yeni Görev'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(_isAdminView ? Icons.admin_panel_settings : Icons.list_alt_rounded),
            label: _isAdminView ? 'Admin' : 'Görevler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Kategoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune_rounded),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, User? currentUser) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategoryId = CategoryService.defaultCategory.id;
    DateTime selectedDate = DateTime.now().add(Duration(days: 1));
    String selectedStatus = 'pending';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Yeni Görev Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Başlık',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: CategoryService.categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Row(
                        children: [
                          Icon(cat.icon ?? Icons.category, color: cat.color, size: 20),
                          SizedBox(width: 8),
                          Text(cat.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedCategoryId = value;
                      });
                    }
                  },
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Teslim Tarihi',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormat('dd MMMM yyyy', 'tr_TR').format(selectedDate),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Durum',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'pending', child: Text('Beklemede')),
                    DropdownMenuItem(value: 'in_progress', child: Text('Devam Ediyor')),
                    DropdownMenuItem(value: 'completed', child: Text('Tamamlandı')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lütfen başlık girin')),
                  );
                  return;
                }

                final newTask = Task(
                  id: '', // Backend will generate
                  title: titleController.text,
                  description: descriptionController.text,
                  dueDate: selectedDate,
                  status: selectedStatus,
                  userId: currentUser?.id ?? '',
                  categoryId: selectedCategoryId,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                final success = await context.read<TaskProvider>().addTask(newTask);

                if (!mounted) return;
                
                Navigator.pop(context);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Görev başarıyla eklendi!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Görev eklenemedi!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  List<Task> _getFilteredTasks(User? currentUser) {
    final tasks = context.read<TaskProvider>().tasks;
    return tasks.where((task) {
      if (_isAdminView) {
        return true; // Admin tüm taskları görür
      }
      return task.userId == currentUser?.id;
    }).toList();
  }

  void _onTaskTap(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: task,
          onTaskUpdated: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildBody(User? currentUser) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final filteredTasks = _getFilteredTasks(currentUser);
        
        switch (_selectedIndex) {
          case 0:
            return _isAdminView
                ? AdminViewWidget()
                : TaskListWidget(
                    tasks: filteredTasks,
                    onTaskTap: _onTaskTap,
                    onRefresh: () {
                      setState(() {
                         _initFuture = _loadInitialData();
                      });
                    },
                  );
          case 1:
            return CategoriesGridWidget(
              onRefresh: () {
                setState(() {
                   _initFuture = _loadInitialData();
                });
              },
            );
          case 2:
            return _buildSettingsTab(currentUser);
          default:
            return Container();
        }
      },
    );
  }

  Widget _buildSettingsTab(User? currentUser) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                  child: Text(
                    currentUser?.name[0].toUpperCase() ?? 'U',
                    style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(currentUser?.name ?? 'User', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(currentUser?.email ?? '', style: TextStyle(color: AppColors.textSecondary)),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: currentUser?.role == 'admin'
                        ? AppColors.error.withOpacity(0.2)
                        : AppColors.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentUser?.role.toUpperCase() ?? 'USER',
                    style: TextStyle(
                      color: currentUser?.role == 'admin'
                          ? AppColors.error
                          : AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.edit_rounded, color: AppColors.primaryColor),
                title: Text('Profili Düzenle'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfileScreen()),
                  );
                },
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
