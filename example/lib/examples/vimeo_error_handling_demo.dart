import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import '../utils/video_api_handler.dart';
import '../utils/vimeo_410_exception.dart';

void main() {
  runApp(const VimeoErrorHandlingDemo());
}

class VimeoErrorHandlingDemo extends StatelessWidget {
  const VimeoErrorHandlingDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vimeo Error Handling Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VimeoErrorHandlingScreen(),
    );
  }
}

class VimeoErrorHandlingScreen extends StatefulWidget {
  const VimeoErrorHandlingScreen({Key? key}) : super(key: key);

  @override
  State<VimeoErrorHandlingScreen> createState() => _VimeoErrorHandlingScreenState();
}

class _VimeoErrorHandlingScreenState extends State<VimeoErrorHandlingScreen> {
  final videoIdController = TextEditingController();
  final hashController = TextEditingController();
  PodPlayerController? podController;
  bool isLoading = false;
  String? errorMessage;
  String? errorType;
  
  @override
  void dispose() {
    videoIdController.dispose();
    hashController.dispose();
    podController?.dispose();
    super.dispose();
  }
  
  Future<void> loadVideo() async {
    if (videoIdController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a Vimeo video ID';
        errorType = 'validation';
      });
      return;
    }
    
    setState(() {
      isLoading = true;
      errorMessage = null;
      errorType = null;
    });
    
    // Dispose of previous controller
    podController?.dispose();
    
    try {
      final hash = hashController.text.isEmpty ? null : hashController.text;
      
      podController = PodPlayerController(
        playVideoFrom: PlayVideoFrom.vimeo(
          videoIdController.text,
          hash: hash,
        ),
      );
      
      await podController!.initialise();
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = VideoApiHandler.getDetailedErrorMessage(e);
        
        // Determine error type for better UI
        if (e is Vimeo410Exception) {
          errorType = '410';
        } else if (e is FormatException && e.toString().contains('HTML')) {
          errorType = 'html';
        } else if (e.toString().contains('403')) {
          errorType = '403';
        } else {
          errorType = 'generic';
        }
      });
      
      // Log detailed error for debugging
      debugPrint('Error loading video: $e');
    }
  }
  
  Widget buildErrorWidget() {
    IconData icon;
    Color color;
    String title;
    
    switch (errorType) {
      case '410':
        icon = Icons.access_time;
        color = Colors.orange;
        title = 'Links Expired';
        break;
      case '403':
        icon = Icons.lock;
        color = Colors.red;
        title = 'Access Denied';
        break;
      case 'html':
        icon = Icons.code_off;
        color = Colors.purple;
        title = 'Invalid Response';
        break;
      default:
        icon = Icons.error_outline;
        color = Colors.red;
        title = 'Error';
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: loadVideo,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                if (errorType == '410')
                  ElevatedButton.icon(
                    onPressed: () {
                      // Clear hash for 410 errors
                      hashController.clear();
                      loadVideo();
                    },
                    icon: const Icon(Icons.link_off),
                    label: const Text('Try Without Hash'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vimeo Error Handling Demo'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: videoIdController,
                    decoration: const InputDecoration(
                      labelText: 'Vimeo Video ID',
                      hintText: 'e.g., 518228118',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: hashController,
                    decoration: const InputDecoration(
                      labelText: 'Hash (optional)',
                      hintText: 'e.g., abcdef123456',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : loadVideo,
                      icon: isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.play_arrow),
                      label: Text(isLoading ? 'Loading...' : 'Load Video'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: errorMessage != null
                  ? buildErrorWidget()
                  : podController != null
                      ? PodVideoPlayer(controller: podController!)
                      : const Center(
                          child: Text(
                            'Enter a Vimeo video ID and press Load Video',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}