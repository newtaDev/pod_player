import 'package:flutter/foundation.dart';

final isWebMobile = kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

final isWebDesktop = kIsWeb && !isWebMobile;
