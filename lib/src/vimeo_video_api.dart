import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'vimeo_models.dart';

class VimeoVideoApi {
  static Future<List<VimeoVideoQalityUrls>?> getvideoQualityLink(
      String videoId) async {
    try {
      final response = await http.get(
        Uri.parse('https://player.vimeo.com/video/$videoId/config'),
      );
      final jsonData =
          jsonDecode(response.body)['request']['files']['progressive'];
      return List.generate(
          jsonData.length,
          (index) => VimeoVideoQalityUrls(
                quality: jsonData[index]['quality'],
                urls: jsonData[index]['url'],
              ));
    } catch (error) {
      debugPrint('=====> REQUEST ERROR: $error');
      return null;
    }
  }
}
