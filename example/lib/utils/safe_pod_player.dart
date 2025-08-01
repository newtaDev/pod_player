import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'video_api_handler.dart';

/// A wrapper widget that safely handles PodPlayer initialization errors
class SafePodPlayer extends StatefulWidget {
  final PodPlayerController controller;
  final Widget Function(String errorMessage)? errorBuilder;
  
  const SafePodPlayer({
    Key? key,
    required this.controller,
    this.errorBuilder,
  }) : super(key: key);

  @override
  State<SafePodPlayer> createState() => _SafePodPlayerState();
}

class _SafePodPlayerState extends State<SafePodPlayer> {
  bool isInitializing = true;
  bool hasError = false;
  String? errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeController();
  }
  
  Future<void> _initializeController() async {
    try {
      // Check if already initialized
      if (!widget.controller.isInitialised) {
        await widget.controller.initialise();
      }
      if (mounted) {
        setState(() {
          isInitializing = false;
          hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isInitializing = false;
          hasError = true;
          errorMessage = VideoApiHandler.getDetailedErrorMessage(e);
        });
      }
    }
  }
  
  @override
  void didUpdateWidget(SafePodPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If controller changed, reinitialize
    if (oldWidget.controller != widget.controller) {
      setState(() {
        isInitializing = true;
        hasError = false;
        errorMessage = null;
      });
      _initializeController();
    }
  }
  
  Widget _buildDefaultError() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Video Failed to Load',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'An unknown error occurred',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                isInitializing = true;
                hasError = false;
                errorMessage = null;
              });
              _initializeController();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (isInitializing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (hasError) {
      return widget.errorBuilder?.call(errorMessage ?? 'Unknown error') ?? 
             _buildDefaultError();
    }
    
    return PodVideoPlayer(controller: widget.controller);
  }
}