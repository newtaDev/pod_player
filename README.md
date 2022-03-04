# fl_video_player

Flutter video player for web & mobile, controls similar to `YouTube player` and also supports playing video from `vimeo`

This plugin uses [`video_player`](https://pub.dartlang.org/packages/video_player)

This is a Simple and easy to use video player, player controller similar to youtube player and also can play videos from vimeo / vimeo_id

## Features

- Video overlay similar to youtube
- Can play videos from vimeo id
- Double tap to seek video.
- On video tap show/hide video overlay.
- Auto hide overlay
- Custom overlay
- Custom progress bar
- Change playback speed
- Change video quality (vimeo only)
- Enable/disable fullscreen player
- [TODO] support for video playlist

---

## Features on web

- Video player integration with keyboard

  - `SPACE` play/pause video
  - `m` mute/unMute video
  - `f` enable/disable fullscreen
  - `->` seek video forward
  - `<-` seek video backward

- Double tap on video (enable/diables fullscreen)

## Preview

---

- Controls similar to youtube

---

|                                               `with overlay`                                               |                                             `without overlay`                                              |
| :--------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------: |
| ![](https://user-images.githubusercontent.com/85326522/156813671-ba562deb-3607-46a6-800c-d3a731b22cdd.jpg) | ![](https://user-images.githubusercontent.com/85326522/156813681-fad9f1f9-d73c-478f-8477-b42342424b4a.jpg) |

---

`On mobile full screen`

---

![](https://user-images.githubusercontent.com/85326522/156813701-aa722624-fde3-4036-9392-a0107ee863b2.jpg)

---

- Video controls

---

|                                              `On Double tap`                                               |                                           `Custom progress bar`                                            |
| :--------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------: |
| ![](https://user-images.githubusercontent.com/85326522/156813691-cd75c638-a4d3-4dda-8a22-eed3e43bd299.jpg) | ![](https://user-images.githubusercontent.com/85326522/156815812-e85bd5bc-2401-42d9-a7ba-c5ad2be494fa.jpg) |

---

- Video player on web

---

![](https://user-images.githubusercontent.com/85326522/156824569-d1ec705d-c278-4503-81fb-84e9dcb58336.jpg)
## Installation

In your `pubspec.yaml` file within your Flutter Project:

```yaml
dependencies:
  fl_video_player: <latest_version>
```

## How to use

```dart
import 'package:fl_video_player/fl_video_player.dart';
import 'package:flutter/material.dart';

class PlayVideoFromNetwork extends StatefulWidget {
  const PlayVideoFromNetwork({Key? key}) : super(key: key);

  @override
  State<PlayVideoFromNetwork> createState() => _PlayVideoFromAssetState();
}

class _PlayVideoFromAssetState extends State<PlayVideoFromNetwork> {
  late final FlVideoController controller;
  @override
  void initState() {
    controller = FlVideoController(
      playVideoFrom: PlayVideoFrom(
        fromNetworkUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      ),
    )..initialise();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlVideoPlayer(
        controller: controller,
      ),
    );
  }
}

```

## Options

---

- Options for mobile

---

|                                           `Normal player option`                                           |                                           `Vimeo player option`                                            | `Change quality of video` |
| :--------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------: | 
| ![](https://user-images.githubusercontent.com/85326522/156813694-65cc70ff-f87f-4668-9ac4-7c0ee14c40cb.jpg) | ![](https://user-images.githubusercontent.com/85326522/156821283-f5470bd2-21ad-4fee-90ac-85176ccc788f.jpg) | ![](https://user-images.githubusercontent.com/85326522/156821301-7c6b1a6d-68a6-4945-8cca-d5e417042e30.jpg) | 

## Example

Please run the app in the [`example/`](https://github.com/newtaDev/fl_video_player/tree/master/example) folder to start playing!

