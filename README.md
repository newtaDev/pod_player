<h1 align="center">
  <a href="https://github.com/newtaDev"><img src="https://user-images.githubusercontent.com/85326522/159757765-db86f850-fea8-4dc2-bd86-0a27648b24e5.png" alt="pod_player"></a>
</h1>

Flutter video player for web & mobile, controls similar to `YouTube player` and also supports playing video from `youtube` and `vimeo`

This is a simple and easy-to-use video player. Its video controls are similar to Youtube player (with customizable controls) and also can play videos from `Youtube` and `Vimeo` (By providing url/video_id).

This plugin built upon flutter's official [`video_player`](https://pub.dartlang.org/packages/video_player) plugin

---

| PLATFORM | AVAILABLE |
| :------: | :-------: |
| Android  |    ✅     |
|   IOS    |    ✅     |
|   WEB    |    ✅     |

## Features

- Play `youtube` videos (using video URL or ID)
- Play `vimeo` videos (using video ID)
- Video overlay similar to youtube
- `Double tap` to seek video.
- On video tap show/hide video overlay.
- Auto hide overlay
- Change `playback speed`
- Custom overlay
- Custom progress bar
- `Change video quality` (for vimeo and youtube)
- Enable/disable fullscreen player
- [TODO] support for live youtube video
- [TODO] support for video playlist

## Features on web

- Double tap on Video player to enable/disable fullscreen
- `Mute/unmute` volume
- Video player integration with keyboard

  - `SPACE` play/pause video
  - `M` mute/unMute video
  - `F` enable/disable fullscreen
  - `ESC` enable/disable fullscreen
  - `->` seek video forward
  - `<-` seek video backward

- Double tap on video (enable/diables fullscreen)

## Demo

---

- Playing videos from youtube

---

<h1 align="center">
  <a href="https://github.com/newtaDev"><img src="https://user-images.githubusercontent.com/85326522/160871693-74b468de-839d-4ae3-9ef0-581066130072.gif" alt="pod_player"></a>
</h1>

---

- Vimeo player and custom video player

---

|                                     Change quality and playback speed                                      |                                        Control video from any where                                        |
| :--------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------: |
| ![](https://user-images.githubusercontent.com/85326522/160657119-7295ef4e-851b-42a3-a792-856fb6045b11.gif) | ![](https://user-images.githubusercontent.com/85326522/160657075-a17876c1-680b-472d-b1b9-ab06ba315b96.gif) |

---

- Controls similar to youtube

---

|                                                with overlay                                                |                              without overlay `(alwaysShowProgressBar = true)`                              |
| :--------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------: |
| ![](https://user-images.githubusercontent.com/85326522/156813671-ba562deb-3607-46a6-800c-d3a731b22cdd.jpg) | ![](https://user-images.githubusercontent.com/85326522/156813681-fad9f1f9-d73c-478f-8477-b42342424b4a.jpg) |

---

- On mobile full screen

---

![](https://user-images.githubusercontent.com/85326522/156813701-aa722624-fde3-4036-9392-a0107ee863b2.jpg)

---

- Video controls

---

|                                               On Double tap                                                |                                            Custom progress bar                                             |
| :--------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------: |
| ![](https://user-images.githubusercontent.com/85326522/156813691-cd75c638-a4d3-4dda-8a22-eed3e43bd299.jpg) | ![](https://user-images.githubusercontent.com/85326522/156815812-e85bd5bc-2401-42d9-a7ba-c5ad2be494fa.jpg) |

---

- Video player on web

---

![](https://user-images.githubusercontent.com/85326522/156824569-d1ec705d-c278-4503-81fb-84e9dcb58336.jpg)

---

---


<h1 align="center">
  <a href="https://github.com/newtaDev"><img src="https://user-images.githubusercontent.com/85326522/160885274-41be06af-ae6d-41f3-8cff-21767fde8dad.gif" alt="pod_player"></a>
</h1>

## Installation

---

In your `pubspec.yaml` file within your Flutter Project:

```yaml
dependencies:
  pod_player: <latest_version>
```

### Android

---

If you are using network-based videos, ensure that the following permission is present in your Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

If you need to access videos using http (rather than https) URLs.

Located inside application tag

```xml
<application
  - - -
  - - - - - -
  android:usesCleartextTraffic="true"

```

### ios

---

Add permissions to your app's Info.plist file,

located in `<project root>/ios/Runner/Info.plist`

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

### web

---

if u are using `youtube` or `vimeo` player on web, then there will be some issue with `CORS` only in web,
so use this [`flutter_cors`](https://pub.dev/packages/flutter_cors) package

#### using [`flutter_cors`](https://pub.dev/packages/flutter_cors) package to enable or disable CORS

> To Enable CORS (run this command )

```
dart pub global activate flutter_cors
fluttercors --enable
```

> To Disable CORS (run this command )

```
fluttercors --disable
```

## How to use

---

```dart
import 'package:pod_player/pod_player.dart';
import 'package:flutter/material.dart';

class PlayVideoFromNetwork extends StatefulWidget {
  const PlayVideoFromNetwork({Key? key}) : super(key: key);

  @override
  State<PlayVideoFromNetwork> createState() => _PlayVideoFromAssetState();
}

class _PlayVideoFromNetworkState extends State<PlayVideoFromNetwork> {
  late final PodPlayerController controller;
  @override
  void initState() {
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.network(
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
      body: PodVideoPlayer(controller: controller),
    );
  }
}

```

## How to play video from youtube

---

```dart
import 'package:pod_player/pod_player.dart';
import 'package:flutter/material.dart';

class PlayVideoFromYoutube extends StatefulWidget {
  const PlayVideoFromYoutube({Key? key}) : super(key: key);

  @override
  State<PlayVideoFromYoutube> createState() => _PlayVideoFromAssetState();
}

class _PlayVideoFromYoutubeState extends State<PlayVideoFromYoutube> {
  late final PodPlayerController controller;
  @override
  void initState() {
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.youtube('https://youtu.be/A3ltMaM6noM'),
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
      body: PodVideoPlayer(controller: controller),
    );
  }
}

```

## How to play video from vimeo

---

```dart
import 'package:pod_player/pod_player.dart';
import 'package:flutter/material.dart';

class PlayVideoFromVimeo extends StatefulWidget {
  const PlayVideoFromVimeo({Key? key}) : super(key: key);

  @override
  State<PlayVideoFromVimeo> createState() => _PlayVideoFromAssetState();
}

class _PlayVideoFromVimeoState extends State<PlayVideoFromVimeo> {
  late final PodPlayerController controller;
  @override
  void initState() {
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.vimeo('518228118'),
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
      body: PodVideoPlayer(controller: controller),
    );
  }
}

```

## Options

---

- Options for mobile

---

|                                           `Normal player option`                                           |                                           `Vimeo player option`                                            |                                         `Change quality of video`                                          |
| :--------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------: |
| ![](https://user-images.githubusercontent.com/85326522/156813694-65cc70ff-f87f-4668-9ac4-7c0ee14c40cb.jpg) | ![](https://user-images.githubusercontent.com/85326522/156821283-f5470bd2-21ad-4fee-90ac-85176ccc788f.jpg) | ![](https://user-images.githubusercontent.com/85326522/156821301-7c6b1a6d-68a6-4945-8cca-d5e417042e30.jpg) |

## Example

---

Please run the app in the [`example/`](https://github.com/newtaDev/fl_video_player/tree/master/example) folder to start playing!
