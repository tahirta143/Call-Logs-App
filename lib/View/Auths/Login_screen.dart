import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infinity/Provider/login_provider.dart';
import 'package:infinity/View/Auths/Sign_up.dart';
import 'package:infinity/compoents/AppButton.dart';
import 'package:infinity/compoents/AppTextfield.dart';
import 'package:infinity/compoents/responsive_helper.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final theme = Theme.of(context);

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
                SizedBox(height: context.sh(0.08)),

                // Header Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Login',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Login to continue to your dashboard",
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.sh(0.06)),

                // Form Section
                Column(
                  children: [
                    // Email Field
                    _buildInputLabel('Email', theme),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: loginProvider.emailController,
                      label: 'Enter your email',
                      icon: Icons.email_outlined,
                      validator: (value) => value!.isEmpty ? 'Enter Email' : null,
                    ),
                    
                    SizedBox(height: context.sh(0.025)),

                    // Password Field
                    _buildInputLabel('Password', theme),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: loginProvider.passwordController,
                      label: 'Enter your password',
                      icon: Icons.lock_outline,
                      icons: Icons.visibility_off,
                      obscureText: true,
                      validator: (value) => value!.isEmpty ? 'Enter Password' : null,
                    ),
                    
                    SizedBox(height: context.sh(0.04)),

                    // Error Message
                    if (loginProvider.message.isNotEmpty)
                      _buildErrorMessage(loginProvider.message, theme),
                    
                    SizedBox(height: loginProvider.message.isNotEmpty ? 16 : 0),

                    // Login Button
                    loginProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : AppButton(
                            title: 'Login',
                            press: () => loginProvider.login(context),
                          ),
                    
                    SizedBox(height: context.sh(0.04)),

                    // Sign Up Section
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SignUp()),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
