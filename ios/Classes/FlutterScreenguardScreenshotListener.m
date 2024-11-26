#import "FlutterScreenguardScreenshotListener.h"

NSString * const REGISTER_SCREENSHOT_EVT = @"registerScreenshotEventListener";
NSString * const ON_SCREENSHOT_EVT = @"onScreenshotCaptured";
NSString * const UNREGISTER_SCREENSHOT_EVT = @"unregisterScreenshotEventListener";

@implementation FlutterScreenguardScreenshotListener

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [center removeObserver:self
                          name:UIApplicationUserDidTakeScreenshotNotification
                        object:nil];
        [center addObserverForName:UIApplicationUserDidTakeScreenshotNotification
                                object:nil
                                 queue:mainQueue
                            usingBlock:^(NSNotification *notification) {
            if (true) {
              UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
              UIImage *image = [self convertViewToImage:rootViewController.view.superview];
              NSData *data = UIImagePNGRepresentation(image);
              if (!data) {
                  [self.channel invokeMethod:ON_SCREENSHOT_EVT arguments:nil];
                return;
              }

              NSString *tempDir = NSTemporaryDirectory();
              NSString *fileName = [[NSUUID UUID] UUIDString];
              NSString *filePath = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", fileName]];

              NSError *error = nil;
              NSDictionary *result;
              BOOL success = [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
              if (!success) {
                  result = @{@"path": @"Error retrieving file", @"name": @"", @"type": @""};
              } else {
                result = @{@"path": filePath, @"name": fileName, @"type": @"PNG"};
              }
                [self.channel invokeMethod:ON_SCREENSHOT_EVT arguments:result];

            } else {
                [self.channel invokeMethod:ON_SCREENSHOT_EVT arguments:nil];
            }
            }];
    }
    return self;
}

- (void)stopListening {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:UIApplicationUserDidTakeScreenshotNotification
                    object:nil];
}

- (UIImage *)convertViewToImage:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
