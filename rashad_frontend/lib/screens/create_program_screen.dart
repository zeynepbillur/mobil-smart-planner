import 'package:flutter/material.dart';
import 'package:rashad_frontend/models/user.dart';
import 'package:rashad_frontend/models/program.dart';
import 'package:rashad_frontend/providers/program_provider.dart';
import 'package:provider/provider.dart';
import 'package:rashad_frontend/utils/app_colors.dart';

class CreateProgramScreen extends StatefulWidget {
  final User currentUser;
  final VoidCallback onProgramCreated;

  const CreateProgramScreen({
    Key? key,
    required this.currentUser,
    required this.onProgramCreated,
  }) : super(key: key);

  @override
  _CreateProgramScreenState createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends State<CreateProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = true;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createProgram() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newProgram = Program(
      id: '', // Backend will generate
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      code: '', // Backend will generate
      adminId: widget.currentUser.id,
      isPublic: _isPublic,
      tasks: [],
      startDate: _startDate,
      endDate: _endDate,
      status: 'active',
      memberIds: [],
      pendingRequests: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final createdProgram = await context.read<ProgramProvider>().createProgram(newProgram);
      widget.onProgramCreated();
      _showSuccessDialog(createdProgram.code);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Program Oluşturuldu!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Program başarıyla oluşturuldu.'),
            SizedBox(height: 16),
            Text(
              'Program Kodu:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      code,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Kod kopyalandı!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Bu kodu kullanıcılarla paylaşın.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close create screen
            },
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Program Oluştur'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Program Bilgileri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Program Adı *',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Program adı gereklidir';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Açıklama *',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Açıklama gereklidir';
                        }
                        return null;
                      },
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
                      'Erişim Ayarları',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('Public Program'),
                      subtitle: Text(
                        _isPublic
                            ? 'Herkes kod ile katılabilir'
                            : 'Katılma isteği admin onayı gerektirir',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() {
                          _isPublic = value;
                        });
                      },
                      secondary: Icon(
                        _isPublic ? Icons.public : Icons.lock,
                        color: _isPublic ? Colors.green : Colors.orange,
                      ),
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
                      'Program Tarihleri (Opsiyonel)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('Başlangıç Tarihi'),
                      subtitle: Text(
                        _startDate != null
                            ? _startDate.toString().split(' ')[0]
                            : 'Seçilmedi',
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                          });
                        }
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.event),
                      title: Text('Bitiş Tarihi'),
                      subtitle: Text(
                        _endDate != null
                            ? _endDate.toString().split(' ')[0]
                            : 'Seçilmedi',
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: _startDate ?? DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 730)),
                        );
                        if (date != null) {
                          setState(() {
                            _endDate = date;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _createProgram,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Program Oluştur',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
