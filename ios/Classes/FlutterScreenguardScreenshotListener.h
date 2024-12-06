#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

extern NSString * const REGISTER_SCREENSHOT_EVT;
extern NSString * const ON_SCREENSHOT_EVT;
extern NSString * const UNREGISTER_SCREENSHOT_EVT;

@interface FlutterScreenguardScreenshotListener : NSObject

@property (nonatomic, strong) FlutterMethodChannel *channel;

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel getScreenshotData:(BOOL) getScreenshotData;
- (void)stopListening;

@end
