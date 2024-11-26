#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

extern NSString * const REGISTER_SCREEN_RECORD_EVT;
extern NSString * const ON_SCREEN_RECORDING_EVT;
extern NSString * const UNREGISTER_SCREEN_RECORDING_EVT;

@interface FlutterScreenguardRecordingListener : NSObject

@property (nonatomic, strong) FlutterMethodChannel *channel;

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel;
- (void)startListening;
- (void)stopListening;

@end
