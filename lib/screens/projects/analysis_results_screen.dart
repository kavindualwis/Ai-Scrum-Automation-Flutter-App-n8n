import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/project_analysis_model.dart';
import '../../services/firestore_service.dart';

class AnalysisResultsScreen extends StatefulWidget {
  final ProjectAnalysis analysis;
  final VoidCallback onClose;
  final String projectId;

  const AnalysisResultsScreen({
    super.key,
    required this.analysis,
    required this.onClose,
    required this.projectId,
  });

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalDays = widget.analysis.milestones.fold<int>(
      0,
      (sum, m) => sum + m.estimatedDays,
    );
    final endDate = DateTime.now().add(Duration(days: totalDays));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Project Results'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.text,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Milestones'),
            Tab(text: 'APIs'),
            Tab(text: 'Schedule'),
            Tab(text: 'Reminders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMilestonesTabWithHeader(totalDays, endDate),
          _buildApisTab(),
          _buildScheduleTab(),
          _buildRemindersTab(),
        ],
      ),
    );
  }

  Widget _buildTimelineStatCard(int totalDays, DateTime endDate) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                'Estimated Duration',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$totalDays days',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Column(
            children: [
              const Text(
                'Target Completion',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesTabWithHeader(int totalDays, DateTime endDate) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTimelineStatCard(totalDays, endDate),
          const SizedBox(height: 16),
          ...widget.analysis.milestones.asMap().entries.map((entry) {
            int index = entry.key;
            Milestone milestone = entry.value;
            return _MilestoneCard(
              milestone: milestone,
              index: index,
              projectId: widget.projectId,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildApisTab() {
    if (widget.analysis.requiredApis.isEmpty) {
      return Center(
        child: Text(
          'No APIs required',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final apiDescriptions = _getApiDescriptions();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.analysis.requiredApis.asMap().entries.map((entry) {
          int index = entry.key;
          String api = entry.value;
          String description =
              apiDescriptions[api] ??
              'Configure and integrate this API/library into your project.';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        api,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.text,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Map<String, String> _getApiDescriptions() {
    return {
      'React':
          'Install React with npm/yarn. Set up component structure, state management (Redux/Context), and routing. Configure webpack or use Create React App for build tooling.',
      'Vue.js':
          'Install Vue via npm. Set up Vue Router for navigation and Vuex/Pinia for state management. Configure build tools and component architecture.',
      'Angular':
          'Create Angular project with CLI. Set up modules, services, and dependency injection. Configure routing and reactive forms for data binding.',
      'Node.js':
          'Install Node.js and npm. Create Express server or choose another framework. Set up routes, middleware, and server configuration on port 3000 or custom port.',
      'Express.js':
          'Install Express with npm. Configure middleware (cors, body-parser). Create route handlers and error handling. Set up server listening and app structure.',
      'Django':
          'Install Django with pip. Create Django project and apps. Configure settings.py, database, and URL routing. Set up views and models.',
      'Flask':
          'Install Flask with pip. Create app factory pattern. Configure blueprints, error handlers, and database integration. Set up routes and middleware.',
      'MongoDB':
          'Install MongoDB locally or use MongoDB Atlas (cloud). Create database and collections. Configure connection string and credentials. Set up mongoose models for Node.js.',
      'PostgreSQL':
          'Install PostgreSQL server. Create database and tables. Configure connection pooling. Set up schema with migrations and query optimization.',
      'Firebase':
          'Set up Firebase project in console. Enable authentication, Firestore, and storage. Download service account key. Configure SDK in your application.',
      'Stripe API':
          'Create Stripe account. Get API keys (publishable and secret). Install Stripe library. Implement payment forms and webhook handlers for transactions.',
      'Payment Gateway':
          'Choose payment provider (Stripe, PayPal, etc). Integrate payment forms securely. Set up webhook endpoints for payment confirmations and error handling.',
      'Authentication (OAuth/JWT)':
          'Implement JWT token generation and validation. Configure OAuth providers (Google, GitHub). Set up token refresh and secure storage mechanisms.',
      'Email Service (SendGrid/Nodemailer)':
          'Sign up and get API keys. Configure SMTP settings or API endpoints. Create email templates and set up transactional email triggers.',
      'Cloud Storage (S3/Firebase)':
          'Configure cloud storage bucket. Set up access credentials and permissions. Implement file upload/download logic with proper error handling.',
      'Docker':
          'Create Dockerfile with appropriate base image. Define build steps and dependencies. Set up docker-compose for multi-container orchestration if needed.',
      'Kubernetes':
          'Create deployment manifests (YAML files). Configure services, ingress, and persistent volumes. Set up scaling policies and health checks.',
      'Core Platform APIs':
          'Identify and document all public APIs your application will expose. Define request/response schemas and error handling protocols.',
      'REST/HTTP Services':
          'Design RESTful API endpoints following HTTP standards. Implement proper status codes, headers, and request validation.',
    };
  }

  Widget _buildScheduleTab() {
    if (widget.analysis.schedules.isEmpty) {
      return Center(
        child: Text(
          'No schedules defined',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.analysis.schedules.asMap().entries.map((entry) {
          int index = entry.key;
          String schedule = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.schedule,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Schedule ${index + 1}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    schedule,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.text,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRemindersTab() {
    if (widget.analysis.reminders.isEmpty) {
      return Center(
        child: Text(
          'No reminders set',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.analysis.reminders.asMap().entries.map((entry) {
          int index = entry.key;
          String reminder = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.notifications,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Reminder ${index + 1}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reminder,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.text,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MilestoneCard extends StatefulWidget {
  final Milestone milestone;
  final int index;
  final String projectId;

  const _MilestoneCard({
    required this.milestone,
    required this.index,
    this.projectId = '',
  });

  @override
  State<_MilestoneCard> createState() => _MilestoneCardState();
}

class _MilestoneCardState extends State<_MilestoneCard> {
  bool _isExpanded = false;
  late Map<int, bool> _subtaskStates;

  @override
  void initState() {
    super.initState();
    _subtaskStates = {
      for (int i = 0; i < widget.milestone.subtasks.length; i++)
        i: widget.milestone.subtasks[i].isCompleted,
    };
  }

  Future<void> _updateSubtaskCompletion(int subtaskIndex, bool value) async {
    setState(() {
      _subtaskStates[subtaskIndex] = value;
    });

    if (widget.projectId.isNotEmpty) {
      try {
        await FirestoreService().updateSubtaskCompletion(
          projectId: widget.projectId,
          milestoneIndex: widget.index,
          subtaskIndex: subtaskIndex,
          isCompleted: value,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving: ${e.toString()}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        // Revert on error
        setState(() {
          _subtaskStates[subtaskIndex] = !value;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.milestone.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.milestone.estimatedDays} days',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.milestone.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.text,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Subtasks',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.milestone.subtasks.asMap().entries.map((entry) {
                    int subtaskIndex = entry.key;
                    Subtask subtask = entry.value;
                    bool isChecked = _subtaskStates[subtaskIndex] ?? false;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () =>
                            _updateSubtaskCompletion(subtaskIndex, !isChecked),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => _updateSubtaskCompletion(
                                subtaskIndex,
                                !isChecked,
                              ),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isChecked
                                        ? Colors.green
                                        : AppColors.border,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  color: isChecked
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : null,
                                ),
                                child: isChecked
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.green,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subtask.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: isChecked
                                              ? AppColors.textSecondary
                                              : AppColors.text,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        size: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${subtask.estimatedHours}h',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
