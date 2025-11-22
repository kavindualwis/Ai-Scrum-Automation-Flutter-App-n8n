// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/project_model.dart';
import '../../models/project_analysis_model.dart';
import '../../providers/project_provider.dart';
import '../../utils/platform_dialogs.dart';
import '../../widgets/ios_button.dart';
import '../../services/n8n_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/processing_dialog.dart';
import 'analysis_results_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late final TextEditingController _promptController;
  late ProjectModel _project;
  StreamSubscription<ProjectAnalysis?>? _analysisSub;
  bool _fallbackSubscribed = false;
  bool _waitingForAnalysis = false;
  bool _navigated = false;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
    _project = widget.project;
    // Primary listener: user-scoped path
    _analysisSub = FirestoreService()
        .watchLatestAnalysis(_project.id)
        .listen(
          (ProjectAnalysis? analysis) {
            if (analysis != null &&
                mounted &&
                (_waitingForAnalysis || !_navigated)) {
              debugPrint(
                '[Project Analysis] ✅ Results received: ${analysis.milestones.length} milestones, ${analysis.requiredApis.length} APIs',
              );
              if (_dialogOpen) {
                Navigator.of(context, rootNavigator: true).pop();
                _dialogOpen = false;
              }
              _waitingForAnalysis = false;
              _navigated = true;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => AnalysisResultsScreen(
                    analysis: analysis,
                    onClose: () => Navigator.pop(context),
                    projectId: _project.id,
                  ),
                ),
              );
            }
            setState(() {});
          },
          onError: (e) {
            if (_dialogOpen) {
              Navigator.of(context, rootNavigator: true).pop();
              _dialogOpen = false;
            }
          },
        );

    // Fallback after 8s: collectionGroup listener if primary did not navigate yet
    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted || _fallbackSubscribed || _navigated) return;
      _fallbackSubscribed = true;
      debugPrint(
        '[Project Analysis] ⏱️ Fallback listener activated (collectionGroup)',
      );
      FirestoreService().watchLatestAnalysisByGroup(_project.id).listen((
        ProjectAnalysis? analysis,
      ) {
        if (analysis != null &&
            mounted &&
            (_waitingForAnalysis || !_navigated)) {
          debugPrint(
            '[Project Analysis] ✅ Fallback results received: ${analysis.milestones.length} milestones, ${analysis.requiredApis.length} APIs',
          );
          if (_dialogOpen) {
            Navigator.of(context, rootNavigator: true).pop();
            _dialogOpen = false;
          }
          _waitingForAnalysis = false;
          _navigated = true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AnalysisResultsScreen(
                analysis: analysis,
                onClose: () => Navigator.pop(context),
                projectId: _project.id,
              ),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _analysisSub?.cancel();
    super.dispose();
  }

  void _handleGenerateFromPrompt() async {
    final prompt = _promptController.text.trim();

    if (prompt.isEmpty) {
      await PlatformDialogs.showErrorDialog(
        context: context,
        title: 'Error',
        message: 'Please enter a prompt',
        buttonText: 'OK',
      );
      return;
    }

    // Show processing dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const ProcessingDialog(),
        );
      },
    ).then((_) {
      // When dialog is closed by any means
      _dialogOpen = false;
    });
    _dialogOpen = true;

    try {
      _waitingForAnalysis = true;
      // Kick off n8n analysis (we rely on Firestore listener for results)
      final n8nService = N8nService();
      final userId = _project.userId;
      await n8nService.analyzeProjectPrompt(
        projectId: _project.id,
        projectName: _project.name,
        prompt: prompt,
        userId: userId,
      );

      // Record request info to project doc (optional log)
      final projectProvider = context.read<ProjectProvider>();
      await projectProvider.addPrompt(_project.id, prompt, {
        'status': 'requested',
        'prompt': prompt,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Keep dialog open; listener will navigate when analysis arrives
      // Add timeout fallback (e.g., 2 minutes)
      Future.delayed(const Duration(minutes: 2), () async {
        if (!mounted) return;
        if (_waitingForAnalysis) {
          _waitingForAnalysis = false;
          if (_dialogOpen) {
            Navigator.of(context, rootNavigator: true).pop();
            _dialogOpen = false;
          }
          await PlatformDialogs.showErrorDialog(
            context: context,
            title: 'Timeout',
            message:
                'Processing is taking longer than expected. Please check your internet or try again.',
            buttonText: 'OK',
          );
        }
      });
    } catch (e) {
      final msg = e.toString();
      // If webhook responded early or timed out, keep waiting for Firestore
      final isEarlyWebhook = msg.contains('Webhook returned too early');
      final isTimeout = msg.contains('n8n request timeout');
      final isParseEarly = msg.contains('Failed to parse n8n response');

      if (isEarlyWebhook || isTimeout || isParseEarly) {
        // Do not close dialog; rely on Firestore listener to navigate
        _waitingForAnalysis = true;
        debugPrint('[Project Analysis] ⏳ Waiting for Firestore results...');
      } else if (mounted) {
        // Real error - close and show dialog
        if (_dialogOpen) {
          Navigator.of(context, rootNavigator: true).pop();
          _dialogOpen = false;
        }
        await PlatformDialogs.showErrorDialog(
          context: context,
          title: 'Error',
          message: 'Failed to analyze prompt: ${e.toString()}',
          buttonText: 'Try Again',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _project.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        foregroundColor: AppColors.text,
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              if (value == 'delete') {
                _showDeleteDialog();
              } else if (value == 'rename') {
                _showRenameDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'rename', child: Text('Rename')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Scrum Master Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Scrum Master',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Generate your project roadmap instantly',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Feature Pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FeaturePill('📋 Milestones'),
                        _FeaturePill('✓ Subtasks'),
                        _FeaturePill('⏱️ Timeline'),
                        _FeaturePill('🔌 APIs'),
                        _FeaturePill('📅 Schedule'),
                        _FeaturePill('🔔 Reminders'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // AI Prompt Section
              Text(
                'AI Scrum Master',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Describe your project goals and let AI generate a complete roadmap:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),

              // Prompt Input
              Text(
                'Describe Your Project',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tell AI what you want to build. The more details, the better the analysis.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _promptController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText:
                      'Example: Build a mobile app with Flutter for task management...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: const TextStyle(color: AppColors.text, fontSize: 16),
              ),
              const SizedBox(height: 24),

              Consumer<ProjectProvider>(
                builder: (context, projectProvider, _) {
                  return IOSButton(
                    text: 'Generate with AI',
                    onPressed: _handleGenerateFromPrompt,
                    isLoading: projectProvider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() async {
    final confirmed = await PlatformDialogs.showConfirmDialog(
      context: context,
      title: 'Delete Project',
      message: 'Are you sure you want to delete "${_project.name}"?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: AppColors.error,
    );

    if (confirmed == true && mounted) {
      final projectProvider = context.read<ProjectProvider>();
      final success = await projectProvider.deleteProject(_project.id);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showRenameDialog() async {
    final nameController = TextEditingController(text: _project.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Project'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'New project name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final projectProvider = context.read<ProjectProvider>();
      final success = await projectProvider.updateProject(
        _project.id,
        nameController.text.trim(),
      );
      if (success && mounted) {
        setState(() {
          _project = _project.copyWith(name: nameController.text.trim());
        });
      }
    }
    nameController.dispose();
  }
}

class _FeaturePill extends StatelessWidget {
  final String label;

  const _FeaturePill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}
