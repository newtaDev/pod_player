import '../../pod_player.dart';

class PodUrlCacheSingleton {
  static final PodUrlCacheSingleton _singleton =
      PodUrlCacheSingleton._internal();

  factory PodUrlCacheSingleton() {
    return _singleton;
  }

  PodUrlCacheSingleton._internal();

  final Map<String, List<VideoQalityUrls>> _podPreFetchMap = {};

  /// Add a list of urls to the pre-fetch list.
  void addUrls(String key, List<VideoQalityUrls> urls) {
    _podPreFetchMap[key] = urls;
  }

  /// Get the list of urls from the pre-fetch list.
  List<VideoQalityUrls> getUrls(String key) {
    final urls = _podPreFetchMap[key] ?? [];
    return urls;
  }
}
