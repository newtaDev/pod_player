import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/vimeo_models.dart';

String podErrorString(String val) {
  return '*\n------error------\n\n$val\n\n------end------\n*';
}

class VideoApis {
  static Future<List<VideoQalityUrls>?> getVimeoVideoQualityUrls(
    String videoId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('https://player.vimeo.com/video/$videoId/config'),
      );
      final jsonData =
          jsonDecode(response.body)['request']['files']['progressive'];
      return List.generate(
        jsonData.length,
        (index) => VideoQalityUrls(
          quality: int.parse(
            (jsonData[index]['quality'] as String?)?.split('p').first ?? '0',
          ),
          url: jsonData[index]['url'],
        ),
      );
    } catch (error) {
      if (error.toString().contains('XMLHttpRequest')) {
        log(
          podErrorString(
            '(INFO) To play vimeo video in WEB, Please enable CORS in your browser',
          ),
        );
      }
      debugPrint('===== VIMEO API ERROR: $error ==========');
      rethrow;
    }
  }

  static Future<List<VideoQalityUrls>?> getVimeoPrivateVideoQualityUrls(
    String videoId,
    Map<String, String> httpHeader,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.vimeo.com/videos/$videoId'),
        headers: httpHeader,
      );
      final jsonData = jsonDecode(response.body)['files'];

      final List<VideoQalityUrls> list = [];
      for (int i = 0; i < jsonData.length; i++) {
        final String quality =
            (jsonData[i]['rendition'] as String?)?.split('p').first ?? '0';
        final int? number = int.tryParse(quality);
        if (number != null && number != 0) {
          list.add(VideoQalityUrls(quality: number, url: jsonData[i]['link']));
        }
      }
      return list;
    } catch (error) {
      if (error.toString().contains('XMLHttpRequest')) {
        log(
          podErrorString(
            '(INFO) To play vimeo video in WEB, Please enable CORS in your browser',
          ),
        );
      }
      debugPrint('===== VIMEO API ERROR: $error ==========');
      rethrow;
    }
  }

  static Future<List<VideoQalityUrls>?> getYoutubeVideoQualityUrls(
    String youtubeIdOrUrl,
    bool live,
  ) async {
    try {
      final yt = YoutubeExplode();
      final urls = <VideoQalityUrls>[];
      if (live) {
        final url = await yt.videos.streamsClient.getHttpLiveStreamUrl(
          VideoId(youtubeIdOrUrl),
        );
        urls.add(
          VideoQalityUrls(
            quality: 360,
            url: url,
          ),
        );
      } else {
        final manifest =
            await yt.videos.streamsClient.getManifest(youtubeIdOrUrl);
        urls.addAll(
          manifest.muxed.map(
            (element) => VideoQalityUrls(
              quality: int.parse(element.qualityLabel.split('p')[0]),
              url: element.url.toString(),
            ),
          ),
        );
        urls.removeWhere((element) => element.quality == 144);
      }

      // Close the YoutubeExplode's http client.
      yt.close();
      return urls;
    } catch (error) {
      if (error.toString().contains('XMLHttpRequest')) {
        log(
          podErrorString(
            '(INFO) To play youtube video in WEB, Please enable CORS in your browser',
          ),
        );
      }
      debugPrint('===== YOUTUBE API ERROR: $error ==========');
      rethrow;
    }
  }
}
