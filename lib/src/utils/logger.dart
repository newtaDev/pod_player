import 'dart:developer';

import '../../pod_player.dart';

void podLog(String message) =>
    enableDevLogs ? log(message, name: 'FL_VIDEO_PLAYER:') : null;
