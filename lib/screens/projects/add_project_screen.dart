import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/project_provider.dart';
import '../../utils/platform_dialogs.dart';
import '../../widgets/ios_button.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _projectNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Show project creation dialog immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCreateProjectDialog();
    });
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }

  void _showCreateProjectDialog() async {
    if (Platform.isIOS) {
      _showIOSProjectDialog();
    } else {
      _showAndroidProjectDialog();
    }
  }

  void _showIOSProjectDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('New Project'),
          content: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: CupertinoTextField(
              placeholder: 'Project Name',
              controller: _projectNameController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
                _handleCreateProject();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showAndroidProjectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Project'),
          content: TextField(
            controller: _projectNameController,
            decoration: InputDecoration(
              hintText: 'Project Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleCreateProject();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _handleCreateProject() async {
    final projectName = _projectNameController.text.trim();

    if (projectName.isEmpty) {
      await PlatformDialogs.showErrorDialog(
        context: context,
        title: 'Error',
        message: 'Project name is required',
        buttonText: 'OK',
      );
      _showCreateProjectDialog();
      return;
    }

    final projectProvider = context.read<ProjectProvider>();
    final success = await projectProvider.createProject(name: projectName);

    if (success && mounted) {
      // Show success message
      await PlatformDialogs.showInfoDialog(
        context: context,
        title: 'Success',
        message: 'Project "$projectName" created successfully!',
        buttonText: 'OK',
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } else if (mounted) {
      await PlatformDialogs.showErrorDialog(
        context: context,
        title: 'Error',
        message: projectProvider.errorMessage ?? 'Failed to create project',
        buttonText: 'Try Again',
      );
      _showCreateProjectDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Project'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.text,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Create a new project',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Press the button above or use the + button to create a new project',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: IOSButton(
                text: 'Create Project',
                onPressed: _showCreateProjectDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
