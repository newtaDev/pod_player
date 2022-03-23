import 'dart:developer';

import '../../pod_player.dart';

void podLog(String message) =>
    enableDevLogs ? log(message, name: 'POD_PLAYER:') : null;
