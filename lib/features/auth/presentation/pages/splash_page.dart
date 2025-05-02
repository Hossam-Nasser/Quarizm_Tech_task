import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quarizmtask/core/util/routing/extensions.dart';

import '../../../../core/util/responsive/app_responsive.dart';
import '../../../../core/util/routing/routes.dart';
import '../../../../core/util/theme/app_theme.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Set up animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    // Start the animation
    _controller.forward();
    
    // Check auth status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkAuthStatus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.pushNamedAndRemoveUntil(
              Routes.specialists,
              predicate: (route) => false,
            );
          } else if (state is AuthUnauthenticated) {
            context.pushNamedAndRemoveUntil(
              Routes.login,
              predicate: (route) => false,
            );
          }
        },
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo
                      Icon(
                        Icons.calendar_month_rounded,
                        size: AppResponsive.r(100),
                        color: Theme.of(context).primaryColor,
                      ),
                      AppResponsive.verticalSpace(24),
                      
                      // App name
                      Text(
                        'Service Booking App',
                        style: TextStyle(
                          fontSize: AppResponsive.sp(AppTheme.heading1),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      
                      AppResponsive.verticalSpace(8),
                      
                      // App description
                      Text(
                        'Book appointments with specialists',
                        style: TextStyle(
                          fontSize: AppResponsive.sp(AppTheme.bodyLarge),
                          color: AppTheme.subtitleColor,
                        ),
                      ),
                      
                      AppResponsive.verticalSpace(48),
                      
                      // Loading indicator
                      SizedBox(
                        width: AppResponsive.r(24),
                        height: AppResponsive.r(24),
                        child: const CircularProgressIndicator(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
