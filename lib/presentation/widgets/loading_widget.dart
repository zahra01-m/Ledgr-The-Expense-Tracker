import 'dart:async';
import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  
  int _messageIndex = 0;
  Timer? _messageTimer;

  final List<String> _loadingMessages = [
    "Syncing your ledger...",
    "Securing your data...",
    "Almost ready...",
    "Thank you for your patience...",
    "Finalizing details...",
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Only cycle messages if no specific message is provided
    if (widget.message == null) {
      _messageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted) {
          setState(() {
            _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentMessage = widget.message ?? _loadingMessages[_messageIndex];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsing Branded Icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 48),
          
          // Smoothly switching messages
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              currentMessage,
              key: ValueKey<String>(currentMessage),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Subtle progress bar
          SizedBox(
            width: 140,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                color: theme.colorScheme.primary,
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
