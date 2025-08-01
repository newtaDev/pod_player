import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/vimeo_models.dart';
import 'vimeo_410_exception.dart';

String podErrorString(String val) {
  return '*\n------error------\n\n$val\n\n------end------\n*';
}

class VideoApis {
  static Future<Response> _makeRequestHash(String videoId, String? hash) {
    if (hash == null) {
      return http.get(
        Uri.parse('https://player.vimeo.com/video/$videoId/config'),
      );
    } else {
      return http.get(
        Uri.parse('https://player.vimeo.com/video/$videoId/config?h=$hash'),
      );
    }
  }

  static Future<List<VideoQalityUrls>?> getVimeoVideoQualityUrls(
    String videoId,
    String? hash,
  ) async {
    try {
      final response = await _makeRequestHash(videoId, hash);
      
      // Check for 410 Gone status
      if (response.statusCode == 410) {
        debugPrint('===== VIMEO API: Received 410 Gone status =====');
        debugPrint('Video ID: $videoId');
        debugPrint('This indicates the progressive links have expired and need to be refreshed.');
        throw Vimeo410Exception(
          message: 'Progressive links expired',
          videoId: videoId,
          hash: hash,
        );
      }
      
      // Check for 403 Forbidden status
      if (response.statusCode == 403) {
        debugPrint('===== VIMEO API: Received 403 Forbidden status =====');
        debugPrint('Video ID: $videoId');
        debugPrint('This video may be private, restricted, or authentication is invalid.');
        if (response.body.contains('Sorry')) {
          debugPrint('Vimeo returned a "Sorry" page - video access denied.');
        }
        throw Exception('Vimeo API returned 403 Forbidden - video access denied (Video ID: $videoId)');
      }
      
      // Check for HTML response instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE html') ||
          response.body.trim().startsWith('<html')) {
        debugPrint('===== VIMEO API: Received HTML instead of JSON =====');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Video ID: $videoId');
        if (response.body.length > 500) {
          debugPrint('HTML Response (first 500 chars): ${response.body.substring(0, 500)}...');
        } else {
          debugPrint('HTML Response: ${response.body}');
        }
        debugPrint('===== End of HTML Response =====');
        throw FormatException('Vimeo API returned HTML instead of JSON (Status: ${response.statusCode})');
      }
      
      final jsonData = jsonDecode(response.body)['request']['files'];
      final dashData = jsonData['dash'];
      final hlsData = jsonData['hls'];
      final defaultCDN = hlsData['default_cdn'];
      final cdnVideoUrl = (hlsData['cdns'][defaultCDN]['url'] as String?) ?? '';
      final List<dynamic> rawStreamUrls =
          (dashData['streams'] as List<dynamic>?) ?? <dynamic>[];

      final List<VideoQalityUrls> vimeoQualityUrls = [];

      for (final item in rawStreamUrls) {
        final sepList = cdnVideoUrl.split('/sep/video/');
        final firstUrlPiece = sepList.firstOrNull ?? '';
        final lastUrlPiece =
            ((sepList.lastOrNull ?? '').split('/').lastOrNull) ??
                (sepList.lastOrNull ?? '');
        final String urlId =
            ((item['id'] ?? '') as String).split('-').firstOrNull ?? '';
        vimeoQualityUrls.add(
          VideoQalityUrls(
            quality: int.parse(
              (item['quality'] as String?)?.split('p').first ?? '0',
            ),
            url: '$firstUrlPiece/sep/video/$urlId/$lastUrlPiece',
          ),
        );
      }
      if (vimeoQualityUrls.isEmpty) {
        vimeoQualityUrls.add(
          VideoQalityUrls(
            quality: 720,
            url: cdnVideoUrl,
          ),
        );
      }

      return vimeoQualityUrls;
    } catch (error) {
      if (error.toString().contains('XMLHttpRequest')) {
        log(
          podErrorString(
            '(INFO) To play vimeo video in WEB, Please enable CORS in your browser',
          ),
        );
      }
      debugPrint('===== VIMEO API ERROR =====');
      debugPrint('Error Type: ${error.runtimeType}');
      debugPrint('Error Message: $error');
      debugPrint('===== End of Error =====');
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
      
      // Check for 410 Gone status
      if (response.statusCode == 410) {
        debugPrint('===== VIMEO PRIVATE API: Received 410 Gone status =====');
        debugPrint('Video ID: $videoId');
        debugPrint('This indicates the progressive links have expired and need to be refreshed.');
        throw Vimeo410Exception(
          message: 'Progressive links expired',
          videoId: videoId,
        );
      }
      
      // Check for 403 Forbidden status
      if (response.statusCode == 403) {
        debugPrint('===== VIMEO PRIVATE API: Received 403 Forbidden status =====');
        debugPrint('Video ID: $videoId');
        debugPrint('This video may be private, restricted, or authentication is invalid.');
        if (response.body.contains('Sorry')) {
          debugPrint('Vimeo returned a "Sorry" page - video access denied.');
        }
        throw Exception('Vimeo Private API returned 403 Forbidden - video access denied (Video ID: $videoId)');
      }
      
      // Check for HTML response instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE html') ||
          response.body.trim().startsWith('<html')) {
        debugPrint('===== VIMEO PRIVATE API: Received HTML instead of JSON =====');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Video ID: $videoId');
        if (response.body.length > 500) {
          debugPrint('HTML Response (first 500 chars): ${response.body.substring(0, 500)}...');
        } else {
          debugPrint('HTML Response: ${response.body}');
        }
        debugPrint('===== End of HTML Response =====');
        throw FormatException('Vimeo Private API returned HTML instead of JSON (Status: ${response.statusCode})');
      }
      
      final jsonData =
          (jsonDecode(response.body)['files'] as List<dynamic>?) ?? [];

      final List<VideoQalityUrls> list = [];
      for (int i = 0; i < jsonData.length; i++) {
        final String quality =
            (jsonData[i]['rendition'] as String?)?.split('p').first ?? '0';
        final int? number = int.tryParse(quality);
        if (number != null && number != 0) {
          list.add(
            VideoQalityUrls(
              quality: number,
              url: jsonData[i]['link'] as String,
            ),
          );
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
      debugPrint('===== VIMEO PRIVATE API ERROR =====');
      debugPrint('Error Type: ${error.runtimeType}');
      debugPrint('Error Message: $error');
      debugPrint('===== End of Error =====');
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
