import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rashad_frontend/models/task.dart';
import 'package:rashad_frontend/models/category.dart';
import 'package:rashad_frontend/services/category_service.dart';
import 'package:rashad_frontend/providers/task_provider.dart';
import 'package:provider/provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final VoidCallback onTaskUpdated;

  const TaskDetailScreen({
    Key? key,
    required this.task,
    required this.onTaskUpdated,
  }) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedStatus;
  late String? _selectedCategoryId;
  late DateTime _selectedDueDate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _selectedStatus = widget.task.status;
    _selectedCategoryId = widget.task.categoryId;
    _selectedDueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Category get _selectedCategory {
    return CategoryService.getCategoryById(_selectedCategoryId);
  }

  Future<void> _saveChanges() async {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      status: _selectedStatus,
      categoryId: _selectedCategoryId,
      dueDate: _selectedDueDate,
      updatedAt: DateTime.now(),
    );

    final success = await context.read<TaskProvider>().updateTask(updatedTask);

    if (!mounted) return;

    setState(() {
      _isEditing = false;
    });

    widget.onTaskUpdated();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Görev güncellendi' : 'Güncelleme başarısız'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Görevi Sil'),
        content: Text('"${widget.task.title}" görevini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<TaskProvider>().deleteTask(widget.task.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
              widget.onTaskUpdated();
            },
            child: Text('Sil'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Görevi Düzenle' : 'Görev Detayı'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            _isEditing
                ? TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Başlık',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                : Text(
                    widget.task.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            SizedBox(height: 24),

            // Açıklama
            Text(
              'Açıklama',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            _isEditing
                ? TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Açıklama',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  )
                : Text(
                    widget.task.description,
                    style: TextStyle(fontSize: 16),
                  ),
            SizedBox(height: 24),

            // Kategori
            _buildInfoCard(
              title: 'Kategori',
              child: _isEditing
                  ? DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: CategoryService.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: category.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value!;
                        });
                      },
                    )
                  : Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _selectedCategory.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          _selectedCategory.name,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
            ),
            SizedBox(height: 16),

            // Durum
            _buildInfoCard(
              title: 'Durum',
              child: _isEditing
                  ? DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: 'pending', child: Text('Bekliyor')),
                        DropdownMenuItem(value: 'in-progress', child: Text('Devam Ediyor')),
                        DropdownMenuItem(value: 'completed', child: Text('Tamamlandı')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    )
                  : Row(
                      children: [
                        Icon(
                          _getStatusIcon(_selectedStatus),
                          color: _getStatusColor(_selectedStatus),
                        ),
                        SizedBox(width: 12),
                        Text(
                          _getStatusText(_selectedStatus),
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
            ),
            SizedBox(height: 16),

            // Bitiş Tarihi
            _buildInfoCard(
              title: 'Bitiş Tarihi',
              child: _isEditing
                  ? InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd MMMM yyyy', 'tr').format(_selectedDueDate)),
                            Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey),
                        SizedBox(width: 12),
                        Text(
                          DateFormat('dd MMMM yyyy', 'tr').format(_selectedDueDate),
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
            ),
            SizedBox(height: 24),

            // Kaydet butonu (sadece edit modunda)
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Kaydet'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _titleController.text = widget.task.title;
                          _descriptionController.text = widget.task.description;
                          _selectedStatus = widget.task.status;
                          _selectedCategoryId = widget.task.categoryId;
                          _selectedDueDate = widget.task.dueDate;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('İptal'),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        child,
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in-progress':
        return Icons.hourglass_empty;
      case 'pending':
      default:
        return Icons.pending_actions;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in-progress':
        return Colors.orange;
      case 'pending':
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Tamamlandı';
      case 'in-progress':
        return 'Devam Ediyor';
      case 'pending':
      default:
        return 'Bekliyor';
    }
  }
}
