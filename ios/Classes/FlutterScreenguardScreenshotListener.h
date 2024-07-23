#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

extern NSString * const ON_SCREENSHOT_EVT;
extern NSString * const REGISTER_SCREENSHOT_EVT;
extern NSString * const DEACTIVATE_SCREENSHOT_EVT;

@interface FlutterScreenguardScreenshotListener : NSObject

@property (nonatomic, strong) FlutterMethodChannel *channel;

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel;
- (void)stopListening;

@end
