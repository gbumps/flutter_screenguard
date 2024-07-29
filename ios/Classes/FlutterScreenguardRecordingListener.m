#import "FlutterScreenguardRecordingListener.h"

NSString * const ON_SCREEN_RECORDING_EVT = @"onScreenRecordingCaptured";
NSString * const REGISTER_SCREEN_RECORDING_EVT = @"registerScreenshotEventListener";
NSString * const DEACTIVATE_SCREEN_RECORDING_EVT = @"deactivateScreenRecordingEventListener";

@implementation FlutterScreenguardRecordingListener

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
            [center removeObserver:self
                              name:UIScreenCapturedDidChangeNotification
                            object:nil];
            [center addObserverForName:UIScreenCapturedDidChangeNotification
                                object:nil
                                 queue:mainQueue
                            usingBlock:^(NSNotification *notification) {
                [self.channel invokeMethod:ON_SCREEN_RECORDING_EVT arguments:nil];
            }];
        
    }
    return self;
}

- (void)stopListening {
    // Stop listening to events
}

@end
