import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rashad_frontend/providers/user_provider.dart';
import 'package:rashad_frontend/models/program.dart';
import 'package:rashad_frontend/models/user.dart';
import 'package:rashad_frontend/providers/program_provider.dart';
import 'package:provider/provider.dart';
import 'package:rashad_frontend/utils/app_colors.dart';
import 'package:rashad_frontend/screens/program_detail_screen.dart';
import 'package:rashad_frontend/screens/create_program_screen.dart';

class ProgramManagementScreen extends StatefulWidget {
  final User currentUser;

  const ProgramManagementScreen({Key? key, required this.currentUser})
    : super(key: key);

  @override
  _ProgramManagementScreenState createState() =>
      _ProgramManagementScreenState();
}

class _ProgramManagementScreenState extends State<ProgramManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _programCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.currentUser.role == 'admin' ? 3 : 2,
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgramProvider>().loadPrograms();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _programCodeController.dispose();
    super.dispose();
  }

  List<Program> get _myPrograms {
    final programs = context.watch<ProgramProvider>().programs;
    if (widget.currentUser.role == 'admin') {
      return programs.where((p) => p.adminId == widget.currentUser.id).toList();
    }
    return programs
        .where((p) => p.memberIds?.contains(widget.currentUser.id) ?? false)
        .toList();
  }

  List<Program> get _publicPrograms {
    final programs = context.watch<ProgramProvider>().programs;
    return programs.where((p) => p.isPublic).toList();
  }

  List<Program> get _pendingRequests {
    final programs = context.watch<ProgramProvider>().programs;
    return programs
        .where(
          (p) =>
              p.adminId == widget.currentUser.id &&
              p.pendingRequests != null &&
              p.pendingRequests!.isNotEmpty,
        )
        .toList();
  }

  void _joinProgramWithCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Programa Katıl'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Program kodunu girin:'),
            SizedBox(height: 16),
            TextField(
              controller: _programCodeController,
              decoration: InputDecoration(
                labelText: 'Program Kodu',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _programCodeController.clear();
            },
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              _joinProgram(_programCodeController.text.trim());
            },
            child: Text('Katıl'),
          ),
        ],
      ),
    );
  }

  void _joinProgram(String code) async {
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen program kodu girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final program = await context.read<ProgramProvider>().joinProgram(code.toUpperCase());

      if (!mounted) return;

      Navigator.pop(context);
      _programCodeController.clear();

      String message = 'Programa başarıyla katıldınız!';
      if (program.pendingRequests?.contains(widget.currentUser.id) ?? false) {
        message = 'Katılım isteğiniz gönderildi, onay bekleniyor.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
        ),
      );

      setState(() {}); // Refresh UI
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);
      _programCodeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final programProvider = context.watch<ProgramProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Programlar'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Programlarım'),
            Tab(text: 'Keşfet'),
            if (widget.currentUser.role == 'admin') Tab(text: 'İstekler'),
          ],
        ),
      ),
      body: programProvider.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    programProvider.error!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProgramProvider>().loadPrograms();
                    },
                    child: Text('Tekrar Dene'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMyProgramsTab(),
                _buildPublicProgramsTab(),
                if (widget.currentUser.role == 'admin')
                  _buildPendingRequestsTab(),
              ],
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.currentUser.role == 'admin')
            FloatingActionButton(
              heroTag: 'create',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateProgramScreen(
                      currentUser: widget.currentUser,
                      onProgramCreated: () {
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
              child: Icon(Icons.add_rounded),
              backgroundColor: AppColors.primaryColor,
            ),
          SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'join',
            onPressed: _joinProgramWithCode,
            child: Icon(Icons.key_rounded),
            backgroundColor: AppColors.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProgramsPlaceholder() {
    return RefreshIndicator(
      onRefresh: () => context.read<ProgramProvider>().loadPrograms(),
      child: Stack(
        children: [
          ListView(), // Dummy to make it scrollable even if and allow pull-to-refresh
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_work_outlined,
                  size: 64,
                  color: AppColors.textHint.withOpacity(0.5),
                ),
                SizedBox(height: 16),
                Text(
                  'Henüz programa katılmadınız',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _joinProgramWithCode,
                  icon: Icon(Icons.vpn_key),
                  label: Text('Kod ile Katıl'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramList(List<Program> programs, {bool isOwner = false}) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProgramProvider>().loadPrograms(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: programs.length,
        itemBuilder: (context, index) {
          return _buildProgramCard(programs[index], isOwner: isOwner);
        },
      ),
    );
  }

  Widget _buildMyProgramsTab() {
    if (_myPrograms.isEmpty) {
      return _buildEmptyProgramsPlaceholder();
    }
    return _buildProgramList(_myPrograms, isOwner: true);
  }

  Widget _buildPublicProgramsTab() {
    if (_publicPrograms.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<ProgramProvider>().loadPrograms(),
        child: Stack(
          children: [
            ListView(),
            Center(child: Text('Henüz public program yok')),
          ],
        ),
      );
    }
    return _buildProgramList(_publicPrograms);
  }

  Widget _buildPendingRequestsTab() {
    if (_pendingRequests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<ProgramProvider>().loadPrograms(),
        child: Stack(
          children: [
            ListView(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.textHint.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Bekleyen istek yok',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ProgramProvider>().loadPrograms(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          final program = _pendingRequests[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.hub_rounded, color: AppColors.primaryColor),
                  ),
                  title: Text(program.name),
                  subtitle: Text(
                    '${program.pendingRequests!.length} bekleyen istek',
                  ),
                ),
                Divider(),
                ...program.pendingRequests!.map((userId) {
                  final users = context.watch<UserProvider>().users;
                  final user = users.firstWhere(
                    (u) => u.id == userId,
                    orElse: () =>
                        User(id: userId, name: 'Unknown User', email: ''),
                  );
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user.name.isNotEmpty ? user.name[0] : '?'),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _approveRequest(program, userId),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectRequest(program, userId),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _approveRequest(Program program, String userId) async {
    try {
      await context.read<ProgramProvider>().approveUser(program.id, userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İstek onaylandı'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _rejectRequest(Program program, String userId) {
    setState(() {
      program.pendingRequests!.remove(userId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('İstek reddedildi'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Widget _buildProgramCard(Program program, {bool isOwner = false}) {
    final isMember =
        program.memberIds?.contains(widget.currentUser.id) ?? false;
    final isPending =
        program.pendingRequests?.contains(widget.currentUser.id) ?? false;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isOwner
                ? AppColors.accentColor.withOpacity(0.2)
                : AppColors.primaryLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isOwner ? Icons.admin_panel_settings : Icons.hub_rounded,
            color: isOwner ? AppColors.accentColor : AppColors.primaryColor,
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(program.name)),
            if (program.isPublic == false)
              Icon(Icons.lock, size: 16, color: AppColors.textSecondary),
            if (isOwner)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _showDeleteProgramDialog(program),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(program.description),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.code, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  program.code,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(width: 4),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: program.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kod kopyalandı: ${program.code}'),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.copy,
                    size: 14,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(width: 4),
                InkWell(
                  onTap: () {
                    Share.share(
                      'Program: ${program.name}\n'
                      'Açıklama: ${program.description}\n'
                      'Katılmak için kod: ${program.code}',
                      subject: '${program.name} programına davet',
                    );
                  },
                  child: Icon(
                    Icons.share,
                    size: 14,
                    color: AppColors.primaryColor,
                  ),
                ),
                Spacer(),
                Icon(Icons.people, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text('${program.memberIds?.length ?? 0} üye'),
              ],
            ),
            if (isPending)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Onay Bekliyor',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (isMember && !isOwner)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Üye',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProgramDetailScreen(
                program: program,
                currentUser: widget.currentUser,
                onUpdate: () {
                  setState(() {});
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteProgramDialog(Program program) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Programı Sil'),
        content: Text(
          '"${program.name}" programını silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<ProgramProvider>().deleteProgram(program.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Program silindi'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hata: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Sil'),
          ),
        ],
      ),
    );
  }
}
