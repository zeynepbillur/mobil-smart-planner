import 'package:flutter/foundation.dart';
import 'package:rashad_frontend/models/program.dart';
import 'package:rashad_frontend/models/task.dart';
import 'package:rashad_frontend/services/program_service.dart';

class ProgramProvider with ChangeNotifier {
  final ProgramService _programService = ProgramService();
  List<Program> _programs = [];
  Map<String, List<Task>> _programTasks = {};
  bool _isLoading = false;
  String? _error;

  List<Program> get programs => _programs;
  Map<String, List<Task>> get programTasks => _programTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPrograms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _programs = await _programService.getPrograms();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProgramTasks(String programId) async {
    try {
      final tasks = await _programService.getProgramTasks(programId);
      _programTasks[programId] = tasks;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Program> createProgram(Program program) async {
    try {
      final newProgram = await _programService.createProgram(program);
      _programs.add(newProgram);
      notifyListeners();
      return newProgram;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> approveUser(String programId, String userId) async {
    try {
      await _programService.approveUser(programId, userId);
      // Reload programs to get updated lists
      await loadPrograms();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProgram(Program program) async {
    try {
      final updatedProgram = await _programService.updateProgram(program);
      final index = _programs.indexWhere((p) => p.id == program.id);
      if (index != -1) {
        _programs[index] = updatedProgram;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Program> joinProgram(String code) async {
    try {
      final program = await _programService.joinProgram(code);
      // Programlar listesini yeniden yükle
      await loadPrograms();
      return program;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProgram(String id) async {
    try {
      await _programService.deleteProgram(id);
      _programs.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
