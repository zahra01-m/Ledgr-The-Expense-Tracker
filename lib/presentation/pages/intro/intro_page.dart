import 'package:flutter/material.dart';
import '../../widgets/animations.dart';

class IntroPage extends StatelessWidget {
  final VoidCallback onGetStarted;

  const IntroPage({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      // Animated Logo
                      FadeInSlide(
                        duration: const Duration(milliseconds: 1000),
                        direction: const Offset(0, -0.1),
                        child: Center(
                          child: Hero(
                            tag: 'app_logo',
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 100,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // App Name
                      FadeInSlide(
                        delay: const Duration(milliseconds: 400),
                        child: Text(
                          'Ledgr',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tagline
                      FadeInSlide(
                        delay: const Duration(milliseconds: 600),
                        child: Text(
                          'Where every transaction tells a story...',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 64),
                      // Get Started Button
                      FadeInSlide(
                        delay: const Duration(milliseconds: 900),
                        direction: const Offset(0, 0.5),
                        child: ElevatedButton(
                          onPressed: onGetStarted,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 64),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              SizedBox(width: 12),
                              Icon(Icons.arrow_forward_rounded),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
