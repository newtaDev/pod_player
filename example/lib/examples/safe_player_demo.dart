import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import '../utils/safe_pod_player.dart';

void main() {
  runApp(const SafePlayerDemo());
}

class SafePlayerDemo extends StatelessWidget {
  const SafePlayerDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Pod Player Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SafePlayerScreen(),
    );
  }
}

class SafePlayerScreen extends StatefulWidget {
  const SafePlayerScreen({Key? key}) : super(key: key);

  @override
  State<SafePlayerScreen> createState() => _SafePlayerScreenState();
}

class _SafePlayerScreenState extends State<SafePlayerScreen> {
  late PodPlayerController controller;
  
  @override
  void initState() {
    super.initState();
    // Initialize with a video that might fail
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.vimeo('518228118'),
    );
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  
  void _loadWorkingVideo() {
    controller.changeVideo(
      playVideoFrom: PlayVideoFrom.network(
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      ),
    );
  }
  
  void _loadBrokenVideo() {
    controller.changeVideo(
      playVideoFrom: PlayVideoFrom.vimeo('nonexistent123'),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Pod Player Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SafePodPlayer(
              controller: controller,
              errorBuilder: (errorMessage) {
                // Custom error UI
                return Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.videocam_off,
                          color: Colors.white54,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Video Unavailable',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  // Force rebuild to retry
                                });
                              },
                              child: const Text(
                                'RETRY',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: _loadWorkingVideo,
                              child: const Text(
                                'LOAD SAMPLE',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Test Different Scenarios:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _loadWorkingVideo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Load Working Video'),
                    ),
                    ElevatedButton(
                      onPressed: _loadBrokenVideo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Load Broken Video'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}