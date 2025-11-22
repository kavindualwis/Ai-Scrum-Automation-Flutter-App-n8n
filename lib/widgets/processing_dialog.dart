import 'package:flutter/material.dart';
import 'dart:ui';

class ProcessingDialog extends StatefulWidget {
  const ProcessingDialog({super.key});

  @override
  State<ProcessingDialog> createState() => _ProcessingDialogState();
}

class _ProcessingDialogState extends State<ProcessingDialog>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Rotation animation for main spinner
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Scale animation for secondary spinner
    _scaleController = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    // Pulse animation for dots
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated container with multiple spinning rings
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating ring
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                      ),
                    ),

                    // Middle scaling ring
                    ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.8,
                        end: 1.0,
                      ).animate(_scaleController),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    // Inner rotating ring (counter rotation)
                    RotationTransition(
                      turns: Tween<double>(
                        begin: 1,
                        end: 0,
                      ).animate(_rotationController),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                      ),
                    ),

                    // Center pulsing dot
                    ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.5,
                        end: 1.0,
                      ).animate(_pulseController),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Animated rotating status messages
              _RotatingStatusMessages(),

              const SizedBox(height: 16),

              // Text with animated dots
              _AnimatedText(),

              const SizedBox(height: 24),

              // Processing steps indicator
              _ProcessingSteps(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedText extends StatefulWidget {
  const _AnimatedText();

  @override
  State<_AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<_AnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        int dots = (_controller.value * 3).toInt();
        String dotString = '.' * (dots + 1);

        return Text(
          'Processing$dotString',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}

class _RotatingStatusMessages extends StatefulWidget {
  const _RotatingStatusMessages();

  @override
  State<_RotatingStatusMessages> createState() =>
      _RotatingStatusMessagesState();
}

class _RotatingStatusMessagesState extends State<_RotatingStatusMessages>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<String> messages = [
    '🧠 Analyzing your project...',
    '📋 Creating milestones...',
    '⚙️  Identifying APIs...',
    '📅 Planning timeline...',
    '✅ Finalizing results...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        int messageIndex =
            (_controller.value * messages.length).toInt() % messages.length;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            messages[messageIndex],
            key: ValueKey(messageIndex),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        );
      },
    );
  }
}

class _ProcessingSteps extends StatefulWidget {
  const _ProcessingSteps();

  @override
  State<_ProcessingSteps> createState() => _ProcessingStepsState();
}

class _ProcessingStepsState extends State<_ProcessingSteps>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<String> steps = [
    'Initializing',
    'Analyzing',
    'Processing',
    'Generating',
    'Saving',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        int currentStep =
            (_controller.value * steps.length).toInt() % steps.length;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(steps.length, (index) {
            bool isActive = index <= currentStep;
            bool isCurrent = index == currentStep;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? Colors.blue
                      : Colors.blue.withValues(alpha: 0.2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
