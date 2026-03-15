## 2.0.1

Republished due to video demo README not loading correctly.

## 2.0.0

- New initSettings() API - Required initialization before using any other API
- Separate screenshot and screen recording through initSettings()
- new way to listen event using `onScreenshotCaptured` and `onScreenRecordingCaptured` Streams
- New getScreenGuardLogs() API - Retrieve activity logs for debugging
- Fixed Android keyboard issue - Text input no longer disabled when screenguard is active
- Removed deprecated APIs - registerScreenshotEventListener, registerScreenRecordingEventListener, removeScreenshotEventListener, removeRecordingEventListener

## 1.0.0

* Init 1st version of package
