## 0.1.0

- Breaking change:

  - In `PodPlayerConfig` `initialVideoQuality` changed to `videoQualityPriority` to support priority of video qualities

  ```dart
  controller = PodPlayerController(
  podPlayerConfig: const PodPlayerConfig(
    videoQualityPriority: [1080, 720, 360],
  ),
  )..initialise()
  ```

- Features

  - Support for youtube live videos By [`(@vodino)`](https://github.com/vodino)
  - Added: `videoQualityPriority` to `PodPlayerConfig` By [`(@emersonsiega)`](https://github.com/emersonsiega)
  - Added: callback `onToggleFullScreen` when changes in fullscreen mode [#48](https://github.com/newtaDev/pod_player/issues/48)
  - Added: `hideOverlay` and `showOverlay` functions to controller

- Bug Fixes
  - Merged PR #54 By [`(@emersonsiega)`](https://github.com/emersonsiega)
    - Fix unhandled exception on initialization [#49](https://github.com/newtaDev/pod_player/issues/49)
    - Add video quality priority list
    - Changes in `onToggleFullScreen`

## 0.0.8

- Merged PR #37 & #38, By [`(@Jeferson505)`](https://github.com/Jeferson505)
  - Added `PodPlayerLabels` param to `PodVideoPlayer` widget
  - Added PodPlayerLabels usage example in `from_asset` file
  - Seted `normal` playback speed to `1x`
- bug fix and added example for playing videos in list

## 0.0.7

- dependencies upgraded
  - video_player: ^2.4.5
- code refactor

## 0.0.6

- Upgraded to Dart 2.17.0
- Bug fixes
- Added some examples

## 0.0.5

- Features
  - Added support for thumbnails
  - Added `isFullScreen` getter to controller
- Updated docs

## 0.0.4

- Features
  - support for RTL (by @karbalaidev)
  - initialVideoQuality added
- Bug fixes

## 0.0.3

- Bug fix #4

## 0.0.2

- Ignored .mp4 video file in pub

## 0.0.1

- Initial release
