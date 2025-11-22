import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/firestore_service.dart';

class ProjectProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ProjectModel> _projects = [];
  ProjectModel? _selectedProject;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ProjectModel> get projects => _projects;
  ProjectModel? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProjectProvider() {
    _loadProjects();
  }

  /// Load projects for current user
  void _loadProjects() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _projects = await _firestoreService.getUserProjects();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get real-time projects stream
  Stream<List<ProjectModel>> getProjectsStream() {
    return _firestoreService.getUserProjectsStream();
  }

  /// Create new project
  Future<bool> createProject({required String name}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final project = await _firestoreService.createProject(name: name);
      _projects.add(project);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Select project
  void selectProject(ProjectModel project) {
    _selectedProject = project;
    notifyListeners();
  }

  /// Update project name
  Future<bool> updateProject(String projectId, String newName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateProject(projectId, newName);
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        _projects[index] = _projects[index].copyWith(name: newName);
      }
      if (_selectedProject?.id == projectId) {
        _selectedProject = _selectedProject!.copyWith(name: newName);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete project
  Future<bool> deleteProject(String projectId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);
      if (_selectedProject?.id == projectId) {
        _selectedProject = null;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Add prompt to project
  Future<bool> addPrompt(
    String projectId,
    String prompt,
    Map<String, dynamic> n8nData,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.addProjectPrompt(projectId, prompt, n8nData);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
