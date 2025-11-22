import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/platform_dialogs.dart';
import '../../widgets/ios_button.dart';
import '../../widgets/ios_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else if (mounted) {
        await PlatformDialogs.showErrorDialog(
          context: context,
          title: 'Registration Failed',
          message: authProvider.errorMessage ?? AppStrings.registerError,
          buttonText: 'Try Again',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              if (Navigator.of(context).canPop())
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.text,
                    size: 20,
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                AppStrings.registerTitle,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.registerSubtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    IOSTextField(
                      hintText: AppStrings.nameHint,
                      controller: _nameController,
                      validator: Validators.validateName,
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Icon(
                          Icons.person_outline,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    IOSTextField(
                      hintText: AppStrings.emailHint,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Icon(
                          Icons.email_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    IOSTextField(
                      hintText: AppStrings.passwordHint,
                      controller: _passwordController,
                      isPassword: true,
                      validator: Validators.validatePassword,
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Icon(
                          Icons.lock_outline,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    IOSTextField(
                      hintText: AppStrings.confirmPasswordHint,
                      controller: _confirmPasswordController,
                      isPassword: true,
                      validator: (value) {
                        return Validators.validatePasswordMatch(
                          _passwordController.text,
                          value,
                        );
                      },
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Icon(
                          Icons.lock_outline,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return IOSButton(
                          text: AppStrings.registerButton,
                          onPressed: _handleRegister,
                          isLoading: authProvider.isLoading,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.haveAccount,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        AppStrings.signIn,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
