import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quarizmtask/core/util/routing/extensions.dart';
import 'package:quarizmtask/core/util/routing/routes.dart';

import '../../../../core/util/responsive/app_responsive.dart';
import '../../../../core/util/theme/app_theme.dart';
import '../../../../core/util/widget/common_widgets.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    _emailController.text = 'test@example.com';
    _passwordController.text = 'password';

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.pushNamedAndRemoveUntil(
              Routes.specialists,
              predicate: (route) => false,
            );
          } else if (state is AuthError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppResponsive.padding(all: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo and title
                      Icon(
                        Icons.calendar_month_rounded,
                        size: AppResponsive.r(80),
                        color: Theme.of(context).primaryColor,
                      ),
                      AppResponsive.verticalSpace(16),
                      Text(
                        'Service Booking App',
                        style: TextStyle(
                          fontSize: AppResponsive.sp(AppTheme.heading1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppResponsive.verticalSpace(8),
                      Text(
                        'Book appointments with specialists',
                        style: TextStyle(
                          fontSize: AppResponsive.sp(AppTheme.bodyLarge),
                          color: AppTheme.subtitleColor,
                        ),
                      ),
                      AppResponsive.verticalSpace(48),
                      
                      // Email field
                      AppTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      
                      // Password field
                      AppTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                        suffix: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      
                      AppResponsive.verticalSpace(24),
                      
                      // Login button
                      AppButton(
                        text: 'Login',
                        isLoading: state is AuthLoading,
                        onPressed: _login,
                      ),
                      
                      AppResponsive.verticalSpace(16),
                      
                      // Register link
                      TextButton(
                        onPressed: () {
                          context.pushNamed(Routes.register);
                        },
                        child: Text(
                          "Don't have an account? Register",
                          style: TextStyle(
                            fontSize: AppResponsive.sp(AppTheme.bodyMedium),
                          ),
                        ),
                      ),
                      

                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
