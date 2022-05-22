import 'dart:developer';

import '../../pod_player.dart';

void podLog(String message) =>
    PodVideoPlayer.enableLogs ? log(message, name: 'POD') : null;
