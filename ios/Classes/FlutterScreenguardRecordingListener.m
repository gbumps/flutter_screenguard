#import "FlutterScreenguardRecordingListener.h"

NSString * const REGISTER_SCREEN_RECORD_EVT = @"registerScreenRecordingEventListener";
NSString * const ON_SCREEN_RECORDING_EVT = @"onScreenRecordingCaptured";
NSString * const UNREGISTER_SCREEN_RECORDING_EVT = @"unregisterScreenRecordingEventListener";

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
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [center removeObserver:self
                      name:UIScreenCapturedDidChangeNotification
                    object:nil];
}

@end
