import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import '../utils/video_api_handler.dart';

void main(List<String> args) {
  runApp(const VimeoApp());
}

class VimeoApp extends StatelessWidget {
  const VimeoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Load vimeo video from quality urls')),
        body: const VimeoVideoViewer(),
      ),
    );
  }
}

class VimeoVideoViewer extends StatefulWidget {
  const VimeoVideoViewer({Key? key}) : super(key: key);

  @override
  State<VimeoVideoViewer> createState() => VimeoVideoViewerState();
}

class VimeoVideoViewerState extends State<VimeoVideoViewer> {
  late final PodPlayerController controller;
  bool isLoading = true;
  String? errorMessage;
  
  @override
  void initState() {
    loadVideo();
    super.initState();
  }

  void loadVideo() async {
    try {
      final urls = await PodPlayerController.getVimeoUrls('518228118');
      setState(() => isLoading = false);
      controller = PodPlayerController(
        playVideoFrom: PlayVideoFrom.networkQualityUrls(videoUrls: urls!),
        podPlayerConfig: const PodPlayerConfig(
          videoQualityPriority: [360],
        ),
      )..initialise();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = VideoApiHandler.getDetailedErrorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Video',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  loadVideo();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Center(child: PodVideoPlayer(controller: controller));
  }
}
