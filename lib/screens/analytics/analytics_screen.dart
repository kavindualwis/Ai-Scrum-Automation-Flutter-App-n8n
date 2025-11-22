import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/project_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/project_analysis_model.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.text,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time & Productivity Metrics
              _buildSectionHeader(context, 'Time & Productivity'),
              const SizedBox(height: 16),
              _buildTimeMetrics(context),
              const SizedBox(height: 24),

              // Project Breakdown
              _buildSectionHeader(context, 'Time Breakdown by Project'),
              const SizedBox(height: 12),
              _buildProjectBreakdown(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildTimeMetrics(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, _) {
        final projects = projectProvider.projects;

        if (projects.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'No projects yet',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          );
        }

        return FutureBuilder<List<int>>(
          future: _calculateTotalHours(projects),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              );
            }

            final totals = snapshot.data!;
            final totalEstimated = totals[0];
            final totalCompleted = totals[1];
            final completionRate = totalEstimated > 0
                ? ((totalCompleted / totalEstimated) * 100).toStringAsFixed(1)
                : '0';
            final avgTimePerProject = projects.isNotEmpty
                ? (totalEstimated / projects.length).toStringAsFixed(1)
                : '0';

            return Column(
              children: [
                // Total Estimated Hours
                _buildMetricCard(
                  title: 'Total Estimated Hours',
                  value: totalEstimated.toString(),
                  subtitle: 'Across all projects',
                  icon: Icons.schedule,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                // Total Completed Hours
                _buildMetricCard(
                  title: 'Completed Hours',
                  value: totalCompleted.toString(),
                  subtitle: 'Tasks finished',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                // Remaining Hours
                _buildMetricCard(
                  title: 'Remaining Hours',
                  value: (totalEstimated - totalCompleted).toString(),
                  subtitle: 'To be completed',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                // Completion Rate
                _buildMetricCard(
                  title: 'Completion Rate',
                  value: '$completionRate%',
                  subtitle: 'Overall progress',
                  icon: Icons.trending_up,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                // Average Time per Project
                _buildMetricCard(
                  title: 'Avg Hours/Project',
                  value: avgTimePerProject,
                  subtitle: 'Average per project',
                  icon: Icons.assessment,
                  color: Colors.purple,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectBreakdown(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, _) {
        final projects = projectProvider.projects;

        if (projects.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'No projects',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          );
        }

        return Column(
          children: List.generate(projects.length, (index) {
            final project = projects[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StreamBuilder<ProjectAnalysis?>(
                stream: FirestoreService().watchLatestAnalysis(project.id),
                builder: (context, snapshot) {
                  int estimatedHours = 0;
                  int completedHours = 0;

                  if (snapshot.hasData && snapshot.data != null) {
                    final analysis = snapshot.data!;
                    for (final milestone in analysis.milestones) {
                      for (final subtask in milestone.subtasks) {
                        estimatedHours += subtask.estimatedHours;
                        if (subtask.isCompleted) {
                          completedHours += subtask.estimatedHours;
                        }
                      }
                    }
                  }

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                project.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$estimatedHours hrs',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Progress',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: estimatedHours > 0
                                          ? completedHours / estimatedHours
                                          : 0.0,
                                      minHeight: 6,
                                      backgroundColor: Colors.grey[200],
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            AppColors.primary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$completedHours/$estimatedHours',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  'hours done',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        );
      },
    );
  }

  Future<List<int>> _calculateTotalHours(List<dynamic> projects) async {
    int totalEstimated = 0;
    int totalCompleted = 0;

    for (final project in projects) {
      final analysis = await FirestoreService()
          .watchLatestAnalysis(project.id)
          .first;
      if (analysis != null) {
        for (final milestone in analysis.milestones) {
          for (final subtask in milestone.subtasks) {
            totalEstimated += subtask.estimatedHours;
            if (subtask.isCompleted) {
              totalCompleted += subtask.estimatedHours;
            }
          }
        }
      }
    }

    return [totalEstimated, totalCompleted];
  }
}
