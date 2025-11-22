// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/project_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/platform_dialogs.dart';
import '../projects/project_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestoreService = FirestoreService();

  void _showCreateProjectDialog() async {
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'New Project',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a new project to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Text field
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Project name',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(bottomSheetContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final projectName = nameController.text.trim();
                        if (projectName.isEmpty) {
                          Navigator.pop(bottomSheetContext);
                          if (mounted) {
                            await PlatformDialogs.showErrorDialog(
                              context: context,
                              title: 'Error',
                              message: 'Project name is required',
                            );
                          }
                          return;
                        }

                        Navigator.pop(bottomSheetContext);

                        if (mounted) {
                          final projectProvider = context
                              .read<ProjectProvider>();
                          final success = await projectProvider.createProject(
                            name: projectName,
                          );

                          if (success && mounted) {
                            await PlatformDialogs.showInfoDialog(
                              context: context,
                              title: 'Success',
                              message:
                                  'Project "$projectName" created successfully!',
                            );
                          } else if (mounted) {
                            await PlatformDialogs.showErrorDialog(
                              context: context,
                              title: 'Error',
                              message:
                                  projectProvider.errorMessage ??
                                  'Failed to create project',
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Scrum Master'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.text,
      ),
      body: SafeArea(
        child: Consumer<ProjectProvider>(
          builder: (context, projectProvider, _) {
            if (projectProvider.isLoading) {
              return Center(
                child: Platform.isIOS
                    ? const CupertinoActivityIndicator(radius: 16)
                    : CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
              );
            }

            if (projectProvider.projects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Projects Yet',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap the + button to create your first project',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Projects List Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    child: Text(
                      'Your Projects',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: projectProvider.projects.length,
                    itemBuilder: (context, index) {
                      final project = projectProvider.projects[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProjectDetailScreen(project: project),
                                ),
                              );
                            },
                            onLongPress: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  if (Platform.isIOS) {
                                    return CupertinoAlertDialog(
                                      title: const Text('Delete Project'),
                                      content: Text(
                                        'Are you sure you want to delete "${project.name}"? This cannot be undone.',
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            false,
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        CupertinoDialogAction(
                                          isDestructiveAction: true,
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            true,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return AlertDialog(
                                      title: const Text('Delete Project'),
                                      content: Text(
                                        'Are you sure you want to delete "${project.name}"? This cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            false,
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            true,
                                          ),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              );

                              if (confirmed == true && mounted) {
                                try {
                                  await projectProvider.deleteProject(
                                    project.id,
                                  );
                                  if (mounted && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Project deleted successfully',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error deleting project: $e',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title and Status Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          project.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Status Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: project.status == 'active'
                                                ? [
                                                    Colors.green.withValues(
                                                      alpha: 0.1,
                                                    ),
                                                    Colors.green.withValues(
                                                      alpha: 0.05,
                                                    ),
                                                  ]
                                                : [
                                                    Colors.orange.withValues(
                                                      alpha: 0.1,
                                                    ),
                                                    Colors.orange.withValues(
                                                      alpha: 0.05,
                                                    ),
                                                  ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: project.status == 'active'
                                                ? Colors.green.withValues(
                                                    alpha: 0.3,
                                                  )
                                                : Colors.orange.withValues(
                                                    alpha: 0.3,
                                                  ),
                                            width: 1,
                                          ),
                                        ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      project.status == 'active'
                                                      ? Colors.green
                                                      : Colors.orange,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                project.status == 'active'
                                                    ? 'Active'
                                                    : 'Pending',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      project.status == 'active'
                                                      ? Colors.green.shade700
                                                      : Colors.orange.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Divider
                                  Container(height: 1, color: AppColors.border),
                                  const SizedBox(height: 14),

                                  // Created Date - Date only
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Created: ${project.createdAt.toString().split(' ')[0]}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Progress Section

                                  // Progress Section
                                  StreamBuilder<int>(
                                    stream: _firestoreService
                                        .getProjectProgressStream(project.id),
                                    builder: (context, snapshot) {
                                      final progress = snapshot.data ?? 0;
                                      final isCompleted = progress == 100;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    isCompleted
                                                        ? Icons
                                                              .check_circle_outline
                                                        : Icons
                                                              .trending_up_outlined,
                                                    size: 16,
                                                    color: isCompleted
                                                        ? Colors.green
                                                        : AppColors
                                                              .textSecondary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'Progress',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: progress < 30
                                                      ? Colors.red.withValues(
                                                          alpha: 0.15,
                                                        )
                                                      : progress < 60
                                                      ? Colors.orange
                                                            .withValues(
                                                              alpha: 0.15,
                                                            )
                                                      : progress < 100
                                                      ? Colors.blue.withValues(
                                                          alpha: 0.15,
                                                        )
                                                      : Colors.green.withValues(
                                                          alpha: 0.15,
                                                        ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  '$progress%',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: progress < 30
                                                        ? Colors.red.shade700
                                                        : progress < 60
                                                        ? Colors.orange.shade700
                                                        : progress < 100
                                                        ? Colors.blue.shade700
                                                        : Colors.green.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: progress / 100,
                                              minHeight: 10,
                                              backgroundColor: AppColors.border,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    progress < 30
                                                        ? Colors.red
                                                        : progress < 60
                                                        ? Colors.orange
                                                        : progress < 100
                                                        ? Colors.blue
                                                        : Colors.green,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProjectDialog,
        backgroundColor: AppColors.primary,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28, color: AppColors.white),
      ),
    );
  }
}
