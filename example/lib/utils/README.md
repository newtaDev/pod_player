# Vimeo Error Handling Utilities

This directory contains utilities for robust error handling when working with Vimeo APIs in the example application.

## Files

### vimeo_410_exception.dart
Custom exception class for handling Vimeo 410 Gone errors, which occur when progressive links have expired.

### video_api_handler.dart
Main utility class that provides:
- `handleVimeoApiResponse()`: Validates Vimeo API responses and throws appropriate exceptions
- `getDetailedErrorMessage()`: Converts exceptions into user-friendly error messages

### safe_pod_player.dart
A wrapper widget that safely handles PodPlayer initialization errors:
- Automatically catches and displays initialization errors
- Provides retry functionality
- Supports custom error UI via `errorBuilder` parameter
- Shows loading state during initialization

## Error Types Handled

1. **410 Gone**: Progressive links have expired
   - User message: "The video links have expired. Please refresh the video to get new links."
   
2. **403 Forbidden**: Access denied to private/restricted videos
   - User message: "Access denied. The video may be private or restricted."
   
3. **HTML Response**: Server returns HTML instead of expected JSON
   - User message: "Vimeo returned an unexpected HTML response. This usually indicates a server issue or that the video is unavailable."
   
4. **CORS Errors**: Browser security restrictions
   - User message: "CORS error: To play Vimeo videos in web, please enable CORS in your browser."

## Usage Example

```dart
import '../utils/video_api_handler.dart';

try {
  await controller.changeVideo(
    playVideoFrom: PlayVideoFrom.vimeo(videoId, hash: hash),
  );
} catch (e) {
  final errorMessage = VideoApiHandler.getDetailedErrorMessage(e);
  // Show errorMessage to user
}
```

## Implementation Notes

- All error responses are logged with detailed debug information
- HTML responses show the first 500 characters for debugging
- Custom error messages provide actionable guidance to users
- The error handling matches the implementation in the main pod_player package

## Handling Initialization Errors

Since the pod_player package throws exceptions during initialization, you need to wrap the `initialise()` call in a try-catch:

```dart
try {
  await controller.initialise();
} catch (e) {
  final errorMessage = VideoApiHandler.getDetailedErrorMessage(e);
  // Handle error appropriately
}
```

Or use the `SafePodPlayer` widget which handles this automatically:

```dart
SafePodPlayer(
  controller: controller,
  errorBuilder: (errorMessage) {
    // Custom error UI (optional)
    return MyCustomErrorWidget(message: errorMessage);
  },
)
```