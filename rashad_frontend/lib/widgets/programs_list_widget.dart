import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rashad_frontend/providers/program_provider.dart';

class ProgramsListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final programs = context.watch<ProgramProvider>().programs;

    return ListView.builder(
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];
        final completedTasks =
            program.tasks.where((t) => t.status == 'completed').length;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: ExpansionTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.group_work, color: Colors.blue, size: 28),
            ),
            title: Text(
              program.name,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  program.description,
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.code, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Kod: ${program.code}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    SizedBox(width: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(program.status),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getStatusText(program.status),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if (program.tasks.isNotEmpty)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: completedTasks / program.tasks.length,
                        backgroundColor: Colors.grey[200],
                        color: Colors.blue,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '$completedTasks/${program.tasks.length} görev tamamlandı',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
              ],
            ),
            children: [
              if (program.tasks.isEmpty)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Bu programda henüz görev yok',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              else
                ...program.tasks.map((task) {
                  return ListTile(
                    leading: Icon(
                      task.status == 'completed'
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: task.status == 'completed'
                          ? Colors.green
                          : Colors.grey,
                    ),
                    title: Text(task.title),
                    subtitle: Text(
                      'Bitiş: ${DateFormat('dd.MM.yyyy').format(task.dueDate)}',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Chip(
                      label: Text(
                        _getTaskStatusText(task.status),
                        style: TextStyle(fontSize: 10),
                      ),
                      backgroundColor: _getTaskStatusColor(task.status),
                    ),
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'planning':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'archived':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'planning':
        return 'Planlamada';
      case 'completed':
        return 'Tamamlandı';
      case 'archived':
        return 'Arşivlendi';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getTaskStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green[100]!;
      case 'in-progress':
        return Colors.orange[100]!;
      case 'pending':
      default:
        return Colors.grey[200]!;
    }
  }

  String _getTaskStatusText(String status) {
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
