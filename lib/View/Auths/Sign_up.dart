import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infinity/View/Auths/Login_screen.dart';
import 'package:infinity/compoents/AppButton.dart';
import 'package:infinity/compoents/AppTextfield.dart';
import 'package:infinity/compoents/responsive_helper.dart';
import 'package:provider/provider.dart';
import '../../Provider/SignUpProvider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => SignUpProvider(),
      builder: (context, _) {
        final provider = Provider.of<SignUpProvider>(context);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: context.sw(0.06), vertical: context.sh(0.02)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new, size: 20, color: theme.colorScheme.onSurface),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(height: context.sh(0.02)),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Fill in your details to get started",
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: context.sh(0.04)),
                    _buildFieldWithLabel(
                      label: 'Full Name',
                      theme: theme,
                      child: AppTextField(
                        controller: provider.fullnameController,
                        label: 'Enter name',
                        icon: Icons.person_outline,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldWithLabel(
                      label: 'Username',
                      theme: theme,
                      child: AppTextField(
                        controller: provider.usernameController,
                        label: 'Enter username',
                        icon: Icons.alternate_email,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldWithLabel(
                      label: 'Email Address',
                      theme: theme,
                      child: AppTextField(
                        controller: provider.emailController,
                        label: 'Enter email',
                        icon: Icons.email_outlined,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldWithLabel(
                      label: 'Password',
                      theme: theme,
                      child: AppTextField(
                        controller: provider.passwordController,
                        label: "Create a password",
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldWithLabel(
                      label: 'Confirm Password',
                      theme: theme,
                      child: AppTextField(
                        controller: provider.cpasswordController,
                        label: 'Re-enter password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    SizedBox(height: context.sh(0.04)),
                    provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : AppButton(
                            title: 'Create Account',
                            press: () async {
                              final result = await provider.signUp(context);
                              if (provider.message.isNotEmpty && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(provider.message),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: provider.message.contains('success') ? Colors.green : Colors.red,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                );
                              }
                            },
                          ),
                    SizedBox(height: context.sh(0.04)),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFieldWithLabel({required String label, required ThemeData theme, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}