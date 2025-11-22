// ignore_for_file: avoid_print, unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project_model.dart';
import '../models/project_analysis_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Collection reference - user-scoped projects
  CollectionReference get _projectsCollection =>
      _db.collection('users').doc(_userId).collection('projects');

  // ==================== Projects ====================

  /// Create a new project
  Future<ProjectModel> createProject({required String name}) async {
    try {
      final projectData = {
        'userId': _userId,
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'status': 'active',
      };

      final docRef = await _projectsCollection.add(projectData);

      return ProjectModel(
        id: docRef.id,
        userId: _userId,
        name: name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'active',
      );
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  /// Get all projects for current user
  Future<List<ProjectModel>> getUserProjects() async {
    try {
      final snapshot = await _projectsCollection
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map(
            (doc) => ProjectModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  /// Get projects stream (real-time updates)
  Stream<List<ProjectModel>> getUserProjectsStream() {
    return _projectsCollection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => ProjectModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
        });
  }

  /// Get single project
  Future<ProjectModel?> getProject(String projectId) async {
    try {
      final doc = await _projectsCollection.doc(projectId).get();
      if (doc.exists) {
        return ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch project: $e');
    }
  }

  /// Update project name
  Future<void> updateProject(String projectId, String newName) async {
    try {
      await _projectsCollection.doc(projectId).update({
        'name': newName,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  /// Delete project
  Future<void> deleteProject(String projectId) async {
    try {
      await _projectsCollection.doc(projectId).delete();
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  /// Add prompt/task to project
  Future<void> addProjectPrompt(
    String projectId,
    String prompt,
    Map<String, dynamic> n8nData,
  ) async {
    try {
      await _projectsCollection.doc(projectId).update({
        'lastPrompt': prompt,
        'n8nData': n8nData,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add prompt: $e');
    }
  }

  // ==================== Analysis ====================

  /// Stream latest analysis for a project (emits null if none)
  Stream<ProjectAnalysis?> watchLatestAnalysis(String projectId) {
    final analysisCol = _projectsCollection
        .doc(projectId)
        .collection('analysis');

    return analysisCol
        .orderBy('processedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final data = snapshot.docs.first.data();

          // Normalize processedAt to string for ProjectAnalysis.fromMap
          final processedAt = data['processedAt'];
          String processedAtIso;
          if (processedAt is Timestamp) {
            processedAtIso = processedAt.toDate().toIso8601String();
          } else if (processedAt is DateTime) {
            processedAtIso = processedAt.toIso8601String();
          } else if (processedAt is String) {
            processedAtIso = processedAt;
          } else {
            processedAtIso = DateTime.now().toIso8601String();
          }

          return ProjectAnalysis.fromMap({
            'projectId': data['projectId'] ?? projectId,
            'projectName': data['projectName'] ?? '',
            'prompt': data['prompt'] ?? '',
            'milestones': data['milestones'] ?? [],
            'requiredApis': data['requiredApis'] ?? [],
            'schedules': data['schedules'] ?? [],
            'reminders': data['reminders'] ?? [],
            'processedAt': processedAtIso,
          });
        });
  }

  /// Collection group fallback: watches any 'analysis' doc with matching projectId.
  /// Useful if backend wrote under an unexpected user path.
  Stream<ProjectAnalysis?> watchLatestAnalysisByGroup(String projectId) {
    return _db
        .collectionGroup('analysis')
        .where('projectId', isEqualTo: projectId)
        .orderBy('processedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final data = snapshot.docs.first.data();

          String processedAtIso;
          final processedAt = data['processedAt'];
          if (processedAt is Timestamp) {
            processedAtIso = processedAt.toDate().toIso8601String();
          } else if (processedAt is DateTime) {
            processedAtIso = processedAt.toIso8601String();
          } else if (processedAt is String) {
            processedAtIso = processedAt;
          } else {
            processedAtIso = DateTime.now().toIso8601String();
          }

          return ProjectAnalysis.fromMap({
            'projectId': data['projectId'] ?? projectId,
            'projectName': data['projectName'] ?? '',
            'prompt': data['prompt'] ?? '',
            'milestones': data['milestones'] ?? [],
            'requiredApis': data['requiredApis'] ?? [],
            'schedules': data['schedules'] ?? [],
            'reminders': data['reminders'] ?? [],
            'processedAt': processedAtIso,
          });
        });
  }

  /// Update subtask completion status
  Future<void> updateSubtaskCompletion({
    required String projectId,
    required int milestoneIndex,
    required int subtaskIndex,
    required bool isCompleted,
  }) async {
    try {
      final analysisSnapshot = await _projectsCollection
          .doc(projectId)
          .collection('analysis')
          .orderBy('processedAt', descending: true)
          .limit(1)
          .get();

      if (analysisSnapshot.docs.isEmpty) {
        throw Exception('No analysis found for project');
      }

      final analysisDoc = analysisSnapshot.docs.first;
      final data = analysisDoc.data();
      final milestones = List<Map<String, dynamic>>.from(
        data['milestones'] ?? [],
      );

      if (milestoneIndex < 0 || milestoneIndex >= milestones.length) {
        throw Exception('Invalid milestone index');
      }

      final subtasks = List<Map<String, dynamic>>.from(
        milestones[milestoneIndex]['subtasks'] ?? [],
      );

      if (subtaskIndex < 0 || subtaskIndex >= subtasks.length) {
        throw Exception('Invalid subtask index');
      }

      subtasks[subtaskIndex]['isCompleted'] = isCompleted;
      milestones[milestoneIndex]['subtasks'] = subtasks;

      // Update milestones AND processedAt to trigger stream updates
      await analysisDoc.reference.update({
        'milestones': milestones,
        'processedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Subtask updated - Progress should refresh');
    } catch (e) {
      print('❌ Error updating subtask: $e');
      throw Exception('Failed to update subtask: $e');
    }
  }

  /// Print all user's analysis results to console for debugging
  Future<void> printAllUserResults() async {
    try {
      print('📊 ==================== ALL USER RESULTS ====================');
      print('👤 User ID: $_userId');
      print('');

      final projectsSnapshot = await _projectsCollection.get();
      print('📁 Total Projects: ${projectsSnapshot.docs.length}');
      print('');

      for (var projectDoc in projectsSnapshot.docs) {
        final project = ProjectModel.fromMap(
          projectDoc.data() as Map<String, dynamic>,
          projectDoc.id,
        );

        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📌 PROJECT: ${project.name}');
        print('   ID: ${project.id}');
        print('   Status: ${project.status}');
        print('   Created: ${project.createdAt}');
        print('');

        try {
          final analysisSnapshot = await projectDoc.reference
              .collection('analysis')
              .orderBy('processedAt', descending: true)
              .get();

          if (analysisSnapshot.docs.isEmpty) {
            print('   ❌ No analysis results yet');
          } else {
            print('   ✅ Analysis Results: ${analysisSnapshot.docs.length}');
            print('');

            for (var (index, analysisDoc) in analysisSnapshot.docs.indexed) {
              final analysisData = analysisDoc.data();
              print('   📋 ANALYSIS #${index + 1}');
              print('      Date: ${analysisData['processedAt']}');
              print('      Prompt: ${analysisData['prompt']}');
              print('');

              // Milestones
              final milestones = analysisData['milestones'] as List? ?? [];
              print('      🎯 Milestones: ${milestones.length}');
              for (var (mIndex, m) in (milestones as List).indexed) {
                final milestone = m as Map<String, dynamic>;
                print(
                  '         ${mIndex + 1}. ${milestone['title']} (${milestone['estimatedDays']} days)',
                );
                final subtasks = milestone['subtasks'] as List? ?? [];
                for (var (sIndex, s) in (subtasks as List).indexed) {
                  final subtask = s as Map<String, dynamic>;
                  print(
                    '            ${sIndex + 1}. ${subtask['title']} (${subtask['estimatedHours']}h)',
                  );
                }
              }
              print('');

              // APIs
              final apis = analysisData['requiredApis'] as List? ?? [];
              print('      🔌 Required APIs: ${apis.join(', ')}');
              print('');

              // Schedules
              final schedules = analysisData['schedules'] as List? ?? [];
              print('      📅 Schedules:');
              for (var (sIndex, s) in (schedules as List).indexed) {
                print('         ${sIndex + 1}. $s');
              }
              print('');

              // Reminders
              final reminders = analysisData['reminders'] as List? ?? [];
              print('      🔔 Reminders:');
              for (var (rIndex, r) in (reminders as List).indexed) {
                print('         ${rIndex + 1}. $r');
              }
              print('');
            }
          }
        } catch (e) {
          print('   ⚠️ Error fetching analysis: $e');
        }

        print('');
      }

      print('📊 ================ END OF RESULTS ================');
    } catch (e) {
      print('❌ Error printing user results: $e');
    }
  }

  /// Calculate project progress from completed subtasks (0-100)
  Future<int> getProjectProgress(String projectId) async {
    try {
      final analysisDoc = await _projectsCollection
          .doc(projectId)
          .collection('analysis')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (analysisDoc.docs.isEmpty) {
        return 0; // No analysis yet
      }

      final analysisData =
          analysisDoc.docs.first.data() as Map<String, dynamic>;
      final milestones = analysisData['milestones'] as List<dynamic>? ?? [];

      if (milestones.isEmpty) {
        return 0;
      }

      int totalSubtasks = 0;
      int completedSubtasks = 0;

      for (final milestone in milestones) {
        final subtasks =
            (milestone as Map<String, dynamic>)['subtasks'] as List<dynamic>? ??
            [];
        for (final subtask in subtasks) {
          totalSubtasks++;
          if ((subtask as Map<String, dynamic>)['isCompleted'] == true) {
            completedSubtasks++;
          }
        }
      }

      if (totalSubtasks == 0) {
        return 0;
      }

      return ((completedSubtasks / totalSubtasks) * 100).toInt();
    } catch (e) {
      print('Error calculating progress: $e');
      return 0;
    }
  }

  /// Stream of project progress
  Stream<int> getProjectProgressStream(String projectId) {
    return _projectsCollection
        .doc(projectId)
        .collection('analysis')
        .orderBy('processedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            print('📊 No analysis docs found for $projectId');
            return 0;
          }

          final analysisData =
              snapshot.docs.first.data() as Map<String, dynamic>;
          final milestones = analysisData['milestones'] as List<dynamic>? ?? [];

          if (milestones.isEmpty) {
            print('📊 No milestones found for $projectId');
            return 0;
          }

          int totalSubtasks = 0;
          int completedSubtasks = 0;

          for (final milestone in milestones) {
            final subtasks =
                (milestone as Map<String, dynamic>)['subtasks']
                    as List<dynamic>? ??
                [];
            for (final subtask in subtasks) {
              totalSubtasks++;
              if ((subtask as Map<String, dynamic>)['isCompleted'] == true) {
                completedSubtasks++;
              }
            }
          }

          if (totalSubtasks == 0) {
            print('📊 No subtasks found for $projectId');
            return 0;
          }

          final progress = ((completedSubtasks / totalSubtasks) * 100).toInt();
          print(
            '📊 Project $projectId: $completedSubtasks/$totalSubtasks = $progress%',
          );
          return progress;
        });
  }
}
