import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rashad_frontend/models/task.dart';
import 'package:rashad_frontend/services/category_service.dart';
import 'package:rashad_frontend/providers/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:rashad_frontend/screens/task_detail_screen.dart';
import 'package:rashad_frontend/utils/app_colors.dart';

class CalendarViewScreen extends StatefulWidget {
  @override
  _CalendarViewScreenState createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  List<Task> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks().then((_) => _updateFilteredTasks());
    });
  }

  void _updateFilteredTasks() {
    final tasks = context.read<TaskProvider>().tasks;
    setState(() {
      _filteredTasks = tasks.where((task) {
        return task.dueDate.year == _selectedDate.year &&
            task.dueDate.month == _selectedDate.month &&
            task.dueDate.day == _selectedDate.day;
      }).toList();
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + delta,
        1,
      );
    });
  }

  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    
    List<DateTime> days = [];
    
    // Add empty days for alignment
    int firstWeekday = firstDay.weekday;
    for (int i = 1; i < firstWeekday; i++) {
      days.add(firstDay.subtract(Duration(days: firstWeekday - i)));
    }
    
    // Add all days of month
    for (int i = 0; i < lastDay.day; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, i + 1));
    }
    
    return days;
  }

  int _getTaskCountForDay(DateTime day) {
    final tasks = context.read<TaskProvider>().tasks;
    return tasks.where((task) {
      return task.dueDate.year == day.year &&
          task.dueDate.month == day.month &&
          task.dueDate.day == day.day;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Takvim'),
        actions: [
          IconButton(
            icon: Icon(Icons.today_rounded),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _focusedMonth = DateTime.now();
                _updateFilteredTasks();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Month navigation bar
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left_rounded),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  DateFormat('MMMM yyyy', 'tr').format(_focusedMonth),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          
          // Weekday headers
          Container(
            color: AppColors.background,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          
          // Calendar grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.8,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _getDaysInMonth().length,
              itemBuilder: (context, index) {
                final day = _getDaysInMonth()[index];
                final isCurrentMonth = day.month == _focusedMonth.month;
                final isSelected = day.year == _selectedDate.year &&
                    day.month == _selectedDate.month &&
                    day.day == _selectedDate.day;
                final isToday = day.year == DateTime.now().year &&
                    day.month == DateTime.now().month &&
                    day.day == DateTime.now().day;
                final taskCount = _getTaskCountForDay(day);
                final hasTasks = taskCount > 0;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                      _updateFilteredTasks();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : (isToday ? AppColors.primaryLight.withOpacity(0.2) : null),
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.primaryColor, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: !isCurrentMonth
                                ? AppColors.textHint
                                : (isSelected ? Colors.white : AppColors.textPrimary),
                          ),
                        ),
                        SizedBox(height: 4),
                        if (hasTasks)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.accentColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$taskCount',
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Selected date info
          Container(
            padding: EdgeInsets.all(12),
            color: AppColors.surface,
            child: Row(
              children: [
                Icon(Icons.event_rounded, color: AppColors.primaryColor),
                SizedBox(width: 8),
                Text(
                  DateFormat('d MMMM yyyy', 'tr').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                if (_filteredTasks.isNotEmpty)
                  Chip(
                    label: Text(
                      '${_filteredTasks.length} görev',
                      style: TextStyle(fontSize: 12, color: AppColors.primaryColor),
                    ),
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    side: BorderSide.none,
                  ),
              ],
            ),
          ),
          
          // Task list for selected date
          Expanded(
            child: _filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available_rounded,
                          size: 64,
                          color: AppColors.textHint.withOpacity(0.5),
                        ),
                        SizedBox(height: 16),
                          Text(
                            'Bu tarihte görev yok',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      final category = CategoryService.getCategoryById(task.categoryId);

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.status == 'completed',
                            onChanged: (value) async {
                              await context.read<TaskProvider>().toggleTaskCompletion(task.id);
                              _updateFilteredTasks();
                            },
                            activeColor: AppColors.primaryColor,
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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: category.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    category.name,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Spacer(),
                                  Text(
                                    DateFormat('HH:mm').format(task.dueDate),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailScreen(
                                  task: task,
                                  onTaskUpdated: () {
                                    setState(() {
                                      _updateFilteredTasks();
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
