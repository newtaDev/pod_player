/// Custom exception for Vimeo 410 Gone errors
class Vimeo410Exception implements Exception {
  final String message;
  final String videoId;
  final String? hash;
  
  Vimeo410Exception({
    required this.message,
    required this.videoId,
    this.hash,
  });
  
  @override
  String toString() => 'Vimeo410Exception: $message (videoId: $videoId)';
}