import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pod_player/pod_player.dart';
import 'vimeo_410_exception.dart';

class VideoApiHandler {
  static Future<void> handleVimeoApiResponse(http.Response response, String videoId, String? hash) async {
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
  }
  
  static String getDetailedErrorMessage(dynamic error, {String? responseBody}) {
    if (error is Vimeo410Exception) {
      return 'The video links have expired. Please refresh the video to get new links.';
    } else if (error is FormatException && error.message.contains('HTML instead of JSON')) {
      return 'Vimeo returned an unexpected HTML response. This usually indicates a server issue or that the video is unavailable.';
    } else if (error is FormatException && error.toString().contains('Unexpected character')) {
      // Enhanced logging for HTML response errors
      debugPrint('===== VIMEO API ERROR: FormatException: Unexpected character (at character 1)');
      debugPrint('<!DOCTYPE html>');
      debugPrint('^');
      debugPrint(' ==========');
      debugPrint('Error Details: $error');
      
      // Print the full HTML response if available
      if (responseBody != null) {
        debugPrint('===== FULL HTML RESPONSE =====');
        if (responseBody.length > 2000) {
          debugPrint('HTML Response (first 2000 chars): ${responseBody.substring(0, 2000)}...');
        } else {
          debugPrint('HTML Response: $responseBody');
        }
        debugPrint('===== END OF HTML RESPONSE =====');
      }
      
      debugPrint('===== End of Error Details =====');
      return 'Vimeo API returned HTML instead of JSON. This usually means the video is unavailable or there\'s a server issue.';
    } else if (error.toString().contains('403 Forbidden')) {
      return 'Access denied. The video may be private or restricted.';
    } else if (error.toString().contains('XMLHttpRequest')) {
      return 'CORS error: To play Vimeo videos in web, please enable CORS in your browser.';
    }
    return error.toString();
  }
}