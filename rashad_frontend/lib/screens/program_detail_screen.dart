import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:rashad_frontend/models/program.dart';
import 'package:rashad_frontend/models/user.dart';
import 'package:rashad_frontend/models/task.dart';
import 'package:rashad_frontend/providers/user_provider.dart';
import 'package:rashad_frontend/providers/task_provider.dart';
import 'package:rashad_frontend/services/category_service.dart';
import 'package:rashad_frontend/utils/app_colors.dart';
import 'package:rashad_frontend/providers/program_provider.dart';
import 'package:provider/provider.dart';
import 'package:rashad_frontend/screens/task_detail_screen.dart';

class ProgramDetailScreen extends StatefulWidget {
  final Program program;
  final User currentUser;
  final VoidCallback onUpdate;

  const ProgramDetailScreen({
    Key? key,
    required this.program,
    required this.currentUser,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ProgramDetailScreenState createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    bool isAdmin = widget.program.adminId == widget.currentUser.id;
    _tabController = TabController(length: isAdmin ? 3 : 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgramProvider>().loadProgramTasks(widget.program.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get isAdmin => widget.currentUser.id == widget.program.adminId;
  bool get isMember =>
      widget.program.memberIds?.contains(widget.currentUser.id) ?? false;

  List<Task> get programTasks {
    return context.watch<ProgramProvider>().programTasks[widget.program.id] ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.program.name),
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded),
            onPressed: () {
              Share.share(
                'Program: ${widget.program.name}\n'
                'Açıklama: ${widget.program.description}\n'
                'Katılmak için kod: ${widget.program.code}',
                subject: '${widget.program.name} programına davet',
              );
            },
          ),
          if (isAdmin)
            IconButton(icon: Icon(Icons.edit_rounded), onPressed: _editProgram),
          if (isMember && !isAdmin)
            IconButton(
              icon: Icon(Icons.exit_to_app_rounded),
              onPressed: _leaveProgram,
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.program.description,
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: widget.program.code),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Davet kodu kopyalandı: ${widget.program.code}',
                                      ),
                                      backgroundColor: AppColors.success,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: _buildInfoChip(
                                  Icons.code_rounded,
                                  widget.program.code,
                                  AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(width: 8),
                              _buildInfoChip(
                                widget.program.isPublic
                                    ? Icons.public_rounded
                                    : Icons.lock_rounded,
                                widget.program.isPublic ? 'Public' : 'Private',
                                widget.program.isPublic
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                              SizedBox(width: 8),
                              _buildInfoChip(
                                Icons.people_rounded,
                                '${widget.program.memberIds?.length ?? 0} üye',
                                AppColors.info,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryColor,
            tabs: [
              Tab(text: 'Görevler'),
              Tab(text: 'Üyeler'),
              if (isAdmin) Tab(text: 'İstatistikler'),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTasksTab(),
                _buildMembersTab(),
                if (isAdmin) _buildStatisticsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: (isMember || isAdmin)
          ? FloatingActionButton(
              onPressed: _addTask,
              child: Icon(Icons.add),
              backgroundColor: AppColors.primaryColor,
            )
          : null,
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    if (programTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 64,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'Henüz görev yok',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            if (isMember || isAdmin)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: ElevatedButton.icon(
                  onPressed: _addTask,
                  icon: Icon(Icons.add),
                  label: Text('Görev Ekle'),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: programTasks.length,
      itemBuilder: (context, index) {
        final task = programTasks[index];
        final users = context.watch<UserProvider>().users;
        final user = users.firstWhere(
          (u) => u.id == task.userId,
          orElse: () => User(id: task.userId, name: 'Unknown User', email: ''),
        );
        final category = CategoryService.getCategoryById(task.categoryId);

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: category.color.withOpacity(0.2),
              child: Icon(category.icon, color: category.color, size: 20),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
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
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      DateFormat('dd.MM.yyyy').format(task.dueDate),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: _buildStatusChip(task.status),
            onTap: () {
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
            },
          ),
        );
      },
    );
  }

  Widget _buildMembersTab() {
    final allUsers = context.watch<UserProvider>().users;
    final members = allUsers
        .where((u) => widget.program.memberIds?.contains(u.id) ?? false)
        .toList();

    if (members.isEmpty) {
      return Center(child: Text('Henüz üye yok'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final user = members[index];
        final userTasks = programTasks
            .where((t) => t.userId == user.id)
            .toList();
        final completedTasks = userTasks
            .where((t) => t.status == 'completed')
            .length;

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight.withOpacity(0.3),
              child: Text(
                user.name[0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            title: Text(user.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '$completedTasks/${userTasks.length} tamamlandı',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                if (userTasks.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(
                      value: completedTasks / userTasks.length,
                      backgroundColor: AppColors.background,
                      color: AppColors.success,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
            trailing: isAdmin
                ? IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      _showMemberOptions(user);
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    final totalTasks = programTasks.length;
    final completedTasks = programTasks
        .where((t) => t.status == 'completed')
        .length;
    final inProgressTasks = programTasks
        .where((t) => t.status == 'in-progress')
        .length;
    final pendingTasks = programTasks
        .where((t) => t.status == 'pending')
        .length;

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Genel İstatistikler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildStatRow(
                  'Toplam Görev',
                  totalTasks.toString(),
                  Icons.task_alt_rounded,
                  AppColors.info,
                ),
                _buildStatRow(
                  'Tamamlanan',
                  completedTasks.toString(),
                  Icons.check_circle_rounded,
                  AppColors.success,
                ),
                _buildStatRow(
                  'Devam Eden',
                  inProgressTasks.toString(),
                  Icons.hourglass_empty_rounded,
                  AppColors.warning,
                ),
                _buildStatRow(
                  'Bekleyen',
                  pendingTasks.toString(),
                  Icons.pending_rounded,
                  AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tamamlanma Oranı',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                if (totalTasks > 0)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: completedTasks / totalTasks,
                        minHeight: 20,
                        backgroundColor: AppColors.background,
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${((completedTasks / totalTasks) * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  )
                else
                  Text('Henüz görev yok'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 16))),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status) {
      case 'completed':
        color = AppColors.success;
        text = 'Tamamlandı';
        break;
      case 'in-progress':
        color = AppColors.warning;
        text = 'Devam Ediyor';
        break;
      default:
        color = AppColors.textSecondary;
        text = 'Bekliyor';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _addTask() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(Duration(days: 1));
    String selectedStatus = 'pending';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Programa Görev Ekle'),
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
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Beklemede'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Tamamlandı'),
                    ),
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
                  id: '',
                  title: titleController.text,
                  description: descriptionController.text,
                  dueDate: selectedDate,
                  status: selectedStatus,
                  userId: widget.currentUser.id,
                  categoryId: null, // Program görevleri kategorisiz
                  programId: widget.program.id, // Programa bağla
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                final success = await context.read<TaskProvider>().addTask(
                  newTask,
                );

                if (!mounted) return;

                Navigator.pop(context);

                if (success) {
                  // Program görevlerini yeniden yükle
                  await context.read<ProgramProvider>().loadProgramTasks(
                    widget.program.id,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Görev programa eklendi!'),
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

  void _editProgram() {
    final nameController = TextEditingController(text: widget.program.name);
    final descriptionController = TextEditingController(
      text: widget.program.description,
    );
    bool isPublic = widget.program.isPublic;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Programı Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Program Adı',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text('Public Program'),
                  subtitle: Text('Herkes kod ile katılabilir'),
                  value: isPublic,
                  onChanged: (value) {
                    setDialogState(() {
                      isPublic = value;
                    });
                  },
                  secondary: Icon(isPublic ? Icons.public : Icons.lock),
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
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lütfen program adı girin')),
                  );
                  return;
                }

                final updatedProgram = widget.program.copyWith(
                  name: nameController.text,
                  description: descriptionController.text,
                  isPublic: isPublic,
                );

                try {
                  await context.read<ProgramProvider>().updateProgram(
                    updatedProgram,
                  );

                  if (!mounted) return;

                  Navigator.pop(context);
                  setState(() {}); // Refresh UI
                  widget.onUpdate();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Program güncellendi!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Güncelleme başarısız: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  void _leaveProgram() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Programdan Ayrıl'),
        content: Text('Bu programdan ayrılmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.program.memberIds?.remove(widget.currentUser.id);
              });
              widget.onUpdate();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Ayrıl'),
          ),
        ],
      ),
    );
  }

  void _showMemberOptions(User user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.remove_circle_rounded,
                color: AppColors.error,
              ),
              title: Text(
                'Programdan Çıkar',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                setState(() {
                  widget.program.memberIds?.remove(user.id);
                });
                widget.onUpdate();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
