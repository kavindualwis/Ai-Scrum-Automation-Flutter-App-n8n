class ProjectAnalysis {
  final String projectId;
  final String projectName;
  final String prompt;
  final List<Milestone> milestones;
  final List<String> requiredApis;
  final List<String> schedules;
  final List<String> reminders;
  final DateTime processedAt;

  ProjectAnalysis({
    required this.projectId,
    required this.projectName,
    required this.prompt,
    required this.milestones,
    required this.requiredApis,
    required this.schedules,
    required this.reminders,
    required this.processedAt,
  });

  Map<String, dynamic> toMap() => {
    'projectId': projectId,
    'projectName': projectName,
    'prompt': prompt,
    'milestones': milestones.map((m) => m.toMap()).toList(),
    'requiredApis': requiredApis,
    'schedules': schedules,
    'reminders': reminders,
    'processedAt': processedAt.toIso8601String(),
  };

  factory ProjectAnalysis.fromMap(Map<String, dynamic> map) => ProjectAnalysis(
    projectId: map['projectId'] ?? '',
    projectName: map['projectName'] ?? '',
    prompt: map['prompt'] ?? '',
    milestones:
        (map['milestones'] as List<dynamic>?)
            ?.map((m) => Milestone.fromMap(m as Map<String, dynamic>))
            .toList() ??
        [],
    requiredApis: List<String>.from(map['requiredApis'] ?? []),
    schedules: List<String>.from(map['schedules'] ?? []),
    reminders: List<String>.from(map['reminders'] ?? []),
    processedAt: DateTime.parse(
      map['processedAt'] ?? DateTime.now().toIso8601String(),
    ),
  );
}

class Milestone {
  final String title;
  final String description;
  final int estimatedDays;
  final List<Subtask> subtasks;

  Milestone({
    required this.title,
    required this.description,
    required this.estimatedDays,
    required this.subtasks,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'estimatedDays': estimatedDays,
    'subtasks': subtasks.map((s) => s.toMap()).toList(),
  };

  factory Milestone.fromMap(Map<String, dynamic> map) => Milestone(
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    estimatedDays: map['estimatedDays'] ?? 0,
    subtasks:
        (map['subtasks'] as List<dynamic>?)
            ?.map((s) => Subtask.fromMap(s as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

class Subtask {
  final String title;
  final String description;
  final int estimatedHours;
  final bool isCompleted;

  Subtask({
    required this.title,
    required this.description,
    required this.estimatedHours,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'estimatedHours': estimatedHours,
    'isCompleted': isCompleted,
  };

  factory Subtask.fromMap(Map<String, dynamic> map) => Subtask(
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    estimatedHours: map['estimatedHours'] ?? 0,
    isCompleted: map['isCompleted'] ?? false,
  );
}
