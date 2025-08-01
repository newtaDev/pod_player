import 'package:pod_player/pod_player.dart';
import 'package:flutter/material.dart';
import '../utils/video_api_handler.dart';

class PlayVideoFromVimeoId extends StatefulWidget {
  const PlayVideoFromVimeoId({Key? key}) : super(key: key);

  @override
  State<PlayVideoFromVimeoId> createState() => _PlayVideoFromVimeoIdState();
}

class _PlayVideoFromVimeoIdState extends State<PlayVideoFromVimeoId> {
  late final PodPlayerController controller;
  final videoTextFieldCtr = TextEditingController();
  final hashTextFieldCtr = TextEditingController();
  bool hasInitError = false;
  String? initErrorMessage;

  @override
  void initState() {
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.vimeo('518228118'),
    );
    _initializeController();
    super.initState();
  }
  
  Future<void> _initializeController() async {
    try {
      await controller.initialise();
    } catch (e) {
      if (mounted) {
        setState(() {
          hasInitError = true;
          initErrorMessage = VideoApiHandler.getDetailedErrorMessage(e);
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vimeo Player')),
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              if (hasInitError)
                _buildErrorWidget()
              else
                PodVideoPlayer(controller: controller),
              const SizedBox(height: 40),
              _loadVideoFromUrl()
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            'Failed to load initial video',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            initErrorMessage ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Try loading a different video below',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Row _loadVideoFromUrl() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: videoTextFieldCtr,
            decoration: const InputDecoration(
              labelText: 'Enter vimeo id',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: 'ex: 518228118',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextField(
            controller: hashTextFieldCtr,
            decoration: const InputDecoration(
              labelText: 'Enter vimeo hash',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: 'ex: ddefbc',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FocusScope(
          canRequestFocus: false,
          child: ElevatedButton(
            onPressed: () async {
              if (videoTextFieldCtr.text.isEmpty) {
                snackBar('Please enter the id');
                return;
              }
              try {
                snackBar('Loading....');
                FocusScope.of(context).unfocus();
                final vimeoHash = hashTextFieldCtr.text;
                
                // Reset error state when trying new video
                setState(() {
                  hasInitError = false;
                  initErrorMessage = null;
                });
                
                await controller.changeVideo(
                  playVideoFrom: PlayVideoFrom.vimeo(
                    videoTextFieldCtr.text,
                    hash: vimeoHash.isNotEmpty ? vimeoHash : null,
                  ),
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              } catch (e) {
                final errorMessage = VideoApiHandler.getDetailedErrorMessage(e);
                snackBar('Unable to load:\n$errorMessage');
                
                // Update error state for UI
                setState(() {
                  hasInitError = true;
                  initErrorMessage = errorMessage;
                });
              }
            },
            child: const Text('Load Video'),
          ),
        ),
      ],
    );
  }

  void snackBar(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
  }
}
