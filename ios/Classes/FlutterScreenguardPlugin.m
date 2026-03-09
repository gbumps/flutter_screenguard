#import "FlutterScreenguardPlugin.h"
#import "SDWebImage/SDWebImage.h"

UITextField *textField;
UIImageView *imageView;
UIScrollView *scrollView;


FlutterScreenguardPlugin* instance;
FlutterMethodChannel* eventChannelScreenRecording;
FlutterMethodChannel* eventChannelScreenshot;

NSString * const ACTIVATE_SHIELD = @"activateShield";
NSString * const ACTIVATE_SHIELD_BLUR = @"activateShieldWithBlurView";
NSString * const ACTIVATE_SHIELD_IMAGE = @"activateShieldWithImage";
NSString * const DEACTIVATE_SHIELD = @"deactivateShield";
NSString * const GET_SCREENGUARD_LOGS = @"getScreenGuardLogs";
NSString * const INIT_SETTINGS = @"initSettings";

NSString * const kSGUserDefaultsLogs = @"screenguard_logs";
NSString * const kSGConfigTrackingLog = @"trackingLog";

NSString * const kSGConfigEnableCapture = @"enableCapture";
NSString * const kSGConfigEnableRecord = @"enableRecord";
NSString * const kSGConfigEnableMultitask = @"enableContentMultitask";
NSString * const kSGConfigDisplayOverlay = @"displayOverlay";
NSString * const kSGConfigTimeAfterResume = @"timeAfterResume";
NSString * const kSGConfigGetScreenshotPath = @"getScreenshotPath";
NSString * const kSGConfigLimitCaptureEvtCount = @"limitCaptureEvtCount";

@interface FlutterScreenguardPlugin ()
@property (nonatomic, strong) NSDictionary *config;
@property (nonatomic, strong) id screenshotObserver;
@property (nonatomic, strong) id screenRecordingObserver;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic) BOOL isMultitasking;
@property (nonatomic) NSInteger currentScreenshotCount;
@end

@implementation FlutterScreenguardPlugin

- (instancetype)init {
    self = [super init];
    if (self) {
        _isMultitasking = NO;
        _currentScreenshotCount = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    return self;
}

- (void)handleAppWillResignActive {
    _isMultitasking = YES;
    [self applySecureState];
}

- (void)handleAppDidBecomeActive {
    _isMultitasking = NO;
    [self applySecureState];
}

- (void)applySecureState {
    if (textField == nil) return;
    
    BOOL enableCapture = [_config[kSGConfigEnableCapture] boolValue];
    BOOL enableRecord = [_config[kSGConfigEnableRecord] boolValue];
    BOOL enableContentMultitask = [_config[kSGConfigEnableMultitask] boolValue];
    
    BOOL shouldSecure = YES;
    
    if (_isMultitasking) {
        shouldSecure = !enableContentMultitask;
    } else {
        BOOL isRec = [UIScreen mainScreen].isCaptured;
        
        if (enableCapture && !enableRecord) {
            shouldSecure = isRec ? YES : NO;
        } else if (!enableCapture && enableRecord) {
            shouldSecure = isRec ? NO : YES;
        } else if (enableCapture && enableRecord) {
             shouldSecure = NO;
        } else {
             shouldSecure = YES;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [textField setSecureTextEntry:shouldSecure];
    });
}

- (void)handleDeviceOrientationChange {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        
        if (textField != nil) {
            textField.frame = screenBounds;
        }
        if (self->_overlayView != nil) {
            self->_overlayView.frame = screenBounds;
        }
        if (scrollView != nil) {
            scrollView.frame = screenBounds;
        }
        if (imageView != nil) {
            // Recalculate imageView position based on current alignment
            UIView *superview = imageView.superview;
            if (superview != nil) {
                CGRect superFrame = superview.bounds;
                CGRect imgFrame = imageView.frame;
                // Center by default
                imgFrame.origin.x = (superFrame.size.width - imgFrame.size.width) / 2;
                imgFrame.origin.y = (superFrame.size.height - imgFrame.size.height) / 2;
                imageView.frame = imgFrame;
            }
        }
    });
}

- (void)logAction:(NSString *)action status:(BOOL)isProtected {
    if (_config != nil && _config[kSGConfigTrackingLog] != nil && ![_config[kSGConfigTrackingLog] boolValue]) {
        return;
    }

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableArray *logs = [[ud arrayForKey:kSGUserDefaultsLogs] mutableCopy];
    if (!logs) {
        logs = [NSMutableArray array];
    }
    
    NSDictionary *logEntry = @{
        @"timestamp": @((long)([[NSDate date] timeIntervalSince1970] * 1000)),
        @"action": action ?: @"unknown",
        @"isProtected": @(isProtected),
        @"method": @""
    };
    
    [logs addObject:logEntry];
    
    // Limit logs to last 1000
    if (logs.count > 1000) {
        [logs removeObjectAtIndex:0];
    }
    
    [ud setObject:logs forKey:kSGUserDefaultsLogs];
    [ud synchronize];
}

- (NSString *)getCurrentMethod {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *logs = [ud arrayForKey:kSGUserDefaultsLogs];
    if (logs && logs.count > 0) {
        for (NSInteger i = logs.count - 1; i >= 0; i--) {
            NSDictionary *log = logs[i];
            NSString *action = log[@"action"];
            if ([action isEqualToString:@"activate_color"]) {
                return @"color";
            } else if ([action isEqualToString:@"activate_blur"]) {
                return @"blur";
            } else if ([action isEqualToString:@"activate_image"]) {
                return @"image";
            } else if ([action isEqualToString:@"deactivate"]) {
                return @"";
            }
        }
    }
    return @"";
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_screenguard"
            binaryMessenger:[registrar messenger]];
  instance = [[FlutterScreenguardPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  eventChannelScreenshot = [FlutterMethodChannel
                                                  methodChannelWithName:@"flutter_screenguard_screenshot_event"
                                                  binaryMessenger:[registrar messenger]];
  eventChannelScreenRecording = [FlutterMethodChannel
                                      methodChannelWithName:@"flutter_screenguard_screen_recording_event"
                                 binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:eventChannelScreenRecording];
  [registrar addMethodCallDelegate:instance channel:eventChannelScreenshot];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *method = call.method;
    if ([method isEqualToString: ACTIVATE_SHIELD]) {
        NSString *color = call.arguments[@"color"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self secureViewWithBackgroundColor: color];
        });
        result(@{@"status": @"success"});
    } else if ([method isEqualToString: ACTIVATE_SHIELD_BLUR]) {
        NSNumber *radius = call.arguments[@"radius"];
        NSString *localImagePath = call.arguments[@"localImagePath"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self secureViewWithBlurView: radius imagePath: localImagePath];
        });
        result(@{@"status": @"success"});
    
    } else if ([method isEqualToString: ACTIVATE_SHIELD_IMAGE]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        NSString *source = call.arguments[@"uri"];
        NSString *defaultSource = call.arguments[@"defaultSource"];
        
        NSString *dataWidth = call.arguments[@"width"];
        NSString *dataHeight = call.arguments[@"height"];
        
        NSNumber *width = @([dataWidth floatValue]);
        NSNumber *height = @([dataHeight floatValue]);
        
        NSNumber *top = call.arguments[@"top"];
        NSNumber *left = call.arguments[@"left"];
        NSNumber *bottom = call.arguments[@"bottom"];
        NSNumber *right = call.arguments[@"right"];
        
        NSString *backgroundColor = call.arguments[@"color"];
        NSNumber *alignmentData = call.arguments[@"alignment"];
        
        if (alignmentData != nil) {
            NSInteger alignment = [alignmentData integerValue];
            ScreenGuardImageAlignment dataAlignment = (ScreenGuardImageAlignment)alignment;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self secureViewWithImageAlignment: source
                 // withDefaultSource: defaultSource
                                         withWidth: width
                                        withHeight: height
                                     withAlignment: dataAlignment
                               withBackgroundColor: backgroundColor];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self secureViewWithImagePosition: source
                 // withDefaultSource: defaultSource
                                        withWidth: width
                                       withHeight: height
                                          withTop: top
                                         withLeft: left
                                       withBottom: bottom
                                        withRight: right
                              withBackgroundColor: backgroundColor];
            });
            
            result(@{@"status": @"success"});
        }
    } else if ([method isEqualToString: DEACTIVATE_SHIELD]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeScreenShot];
            [self logAction:@"deactivate" status:NO];
        });
        result(@{@"status": @"success"});
    } else if ([method isEqualToString: GET_SCREENGUARD_LOGS]) {
        NSNumber *maxCount = call.arguments[@"maxCount"];
        [self getScreenGuardLogs:maxCount result:result];
    } else if ([method isEqualToString: INIT_SETTINGS]) {
        [self initSettings:call.arguments result:result];
    }
}

- (void)initSettings:(NSDictionary *)params result:(FlutterResult)result {
    _config = [params copy];
    _currentScreenshotCount = 0;
    
    BOOL getScreenshotPath = NO;
    if (params[kSGConfigGetScreenshotPath] != nil) {
        getScreenshotPath = [params[kSGConfigGetScreenshotPath] boolValue];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self registerScreenshotEventListener:getScreenshotPath];
        [self registerScreenRecordingEventListener:YES];
        
        [self logAction:@"init" status:NO];
        [self applySecureState];
    });
    result(nil);
}

- (void)registerScreenshotEventListener:(BOOL)getScreenshotPath {
    if (_screenshotObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_screenshotObserver];
    }
    
    _screenshotObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSInteger limitCount = 0;
        if (self->_config[kSGConfigLimitCaptureEvtCount] != nil) {
            limitCount = [self->_config[kSGConfigLimitCaptureEvtCount] integerValue];
        }
        
        NSDictionary *activationStatus = @{
            @"method": [self getCurrentMethod],
            @"isActivated": @(textField != nil && textField.isSecureTextEntry)
        };
        
        self->_currentScreenshotCount++;
        [self logAction:@"screenshot_taken" status:YES];
        
        BOOL displayOverlay = [self->_config[kSGConfigDisplayOverlay] boolValue];
        if (displayOverlay) {
            [self showOverlay:NO];
        }
        
        if (limitCount > 0 && self->_currentScreenshotCount < limitCount) {
            return;
        }
        
        if (limitCount > 0) {
            self->_currentScreenshotCount = 0;
        }
        
        if (getScreenshotPath) {
            UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            UIImage *image = [self convertViewToImage:rootViewController.view.superview];
            NSData *data = UIImagePNGRepresentation(image);
            if (!data) {
                NSDictionary *result = @{@"path": @"", @"name": @"", @"type": @"", @"activationStatus": activationStatus};
                [eventChannelScreenshot invokeMethod:@"onScreenshotCaptured" arguments:result];
                return;
            }

            NSString *tempDir = NSTemporaryDirectory();
            NSString *fileName = [[NSUUID UUID] UUIDString];
            NSString *filePath = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", fileName]];

            NSError *error = nil;
            NSDictionary *result;
            BOOL success = [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
            if (!success) {
                result = @{@"path": @"Error retrieving file", @"name": @"", @"type": @"", @"activationStatus": activationStatus};
            } else {
                result = @{@"path": filePath, @"name": fileName, @"type": @"PNG", @"activationStatus": activationStatus};
            }
            [eventChannelScreenshot invokeMethod:@"onScreenshotCaptured" arguments:result];
        } else {
            NSDictionary *result = @{@"path": @"", @"name": @"", @"type": @"", @"activationStatus": activationStatus};
            [eventChannelScreenshot invokeMethod:@"onScreenshotCaptured" arguments:result];
        }
    }];
}

- (void)registerScreenRecordingEventListener:(BOOL)getRecordingStatus {
    if (_screenRecordingObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_screenRecordingObserver];
    }
    
    _screenRecordingObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIScreenCapturedDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        BOOL isRecording = [UIScreen mainScreen].isCaptured;
        NSDictionary *activationStatus = @{
            @"method": [self getCurrentMethod],
            @"isActivated": @(textField != nil && textField.isSecureTextEntry)
        };
        NSDictionary *result = @{
            @"isRecording": @(isRecording),
            @"activationStatus": activationStatus
        };
        [eventChannelScreenRecording invokeMethod:@"onScreenRecordingCaptured" arguments:result];
        [self applySecureState];
        
        BOOL displayOverlay = [self->_config[kSGConfigDisplayOverlay] boolValue];
        BOOL enableRecord = [self->_config[kSGConfigEnableRecord] boolValue];
        if (displayOverlay && !enableRecord) {
            if (isRecording) {
                [self showOverlay:YES];
            } else {
                [self showOverlay:NO];
            }
        }
    }];
}

- (void)getScreenGuardLogs:(NSNumber *)maxCount result:(FlutterResult)result {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *logs = [ud arrayForKey:kSGUserDefaultsLogs];
    
    if (!logs) {
        result(@[]);
        return;
    }

    NSInteger count = [maxCount integerValue];
    if (count > 0 && count < logs.count) {
       NSRange range = NSMakeRange(logs.count - count, count);
       NSArray *subarray = [logs subarrayWithRange:range];
       result(subarray);
    } else {
       result(logs);
    }
}

- (void)secureViewWithBackgroundColor: (NSString *)color {
  if (@available(iOS 13.0, *)) {
    if (textField == nil) {
      [self initTextField];
    }
    [textField setSecureTextEntry: TRUE];
    [textField setBackgroundColor: [self colorFromHexString: color]];
    [self logAction:@"activate_color" status:YES];
  } else return;
}

- (void)secureViewWithBlurView: (nonnull NSNumber *)radius imagePath:(NSString *) imagePath {
  if (@available(iOS 13.0, *)) {
    if (textField == nil) {
      [self initTextField];
    }
      
    [textField setBackgroundColor: [UIColor clearColor]];
    [textField setSecureTextEntry: TRUE];
      
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
          
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:ciImage forKey:kCIInputImageKey];
    [blurFilter setValue:radius forKey:kCIInputRadiusKey];
          
    CIImage *outputCIImage = [blurFilter outputImage];
          
    CIContext *context = [CIContext contextWithOptions:nil];
          
    CGRect extent = [outputCIImage extent];
    CGImageRef cgImage = [context createCGImage:outputCIImage fromRect:extent];
          
    UIImage *blurredImage = [UIImage imageWithCGImage:cgImage];
          
    CGImageRelease(cgImage);
      
    [textField setBackground: blurredImage];
    [self logAction:@"activate_blur" status:YES];
  } else return;
}

- (void)secureViewWithImageAlignment:(nonnull NSString *)source
                          withWidth:(nonnull NSNumber *)width
                         withHeight:(nonnull NSNumber *)height
                      withAlignment:(ScreenGuardImageAlignment)alignment
                withBackgroundColor:(nonnull NSString *)backgroundColor
{
   if (@available(iOS 13.0, *)) {
    if (textField == nil) {
      [self initTextField];
    }

    [textField setSecureTextEntry: TRUE];
    [textField setContentMode: UIViewContentModeCenter];
    
    imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, [width doubleValue], [height doubleValue])];
        
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [imageView setClipsToBounds:YES];
    SDWebImageDownloaderOptions downloaderOptions = SDWebImageDownloaderScaleDownLargeImages;
    

        NSString *uriImage = source;
        
        [imageView sd_setImageWithURL: [NSURL URLWithString: uriImage]
                     placeholderImage: nil 
                              options: downloaderOptions
                            completed: ^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        }];
    
      if (scrollView == nil) {
        scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.scrollEnabled = false;
      }
      [self setImageView: alignment];
      [textField addSubview: scrollView];
      [textField sendSubviewToBack: scrollView];
      [textField setBackgroundColor: [self colorFromHexString: backgroundColor]];
      [self logAction:@"activate_image" status:YES];

  } else return;
}


- (void)secureViewWithImagePosition: (nonnull NSString *) source
//                  withDefaultSource: (nullable NSDictionary *) defaultSource
                          withWidth: (nonnull NSNumber *) width
                         withHeight: (nonnull NSNumber *) height
                            withTop: (NSNumber *) top
                           withLeft: (NSNumber *) left
                         withBottom: (NSNumber *) bottom
                          withRight: (NSNumber *) right
                withBackgroundColor: (nonnull NSString *) backgroundColor
{
 if (@available(iOS 13.0, *)) {
   if (textField == nil) {
     [self initTextField];
   }
   [textField setSecureTextEntry: TRUE];
   [textField setContentMode: UIViewContentModeCenter];
     
   if (scrollView == nil) {
     scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
     scrollView.showsHorizontalScrollIndicator = NO;
     scrollView.showsVerticalScrollIndicator = NO;
     scrollView.scrollEnabled = false;
   }
   
   imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, [width doubleValue], [height doubleValue])];
     
   imageView.translatesAutoresizingMaskIntoConstraints = NO;
     
   [imageView setClipsToBounds: TRUE];

    NSString *uriImage = source;
    SDWebImageDownloaderOptions downloaderOptions = SDWebImageDownloaderScaleDownLargeImages;
     
       [imageView sd_setImageWithURL: [NSURL URLWithString: uriImage]
                    placeholderImage: nil
                             options: downloaderOptions
                           completed: ^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
       }];
   
   [self setImageViewBasedOnPosition:[top doubleValue] left:[left doubleValue] bottom:[bottom doubleValue] right:[right doubleValue]];
     
   [textField addSubview: scrollView];
   [textField sendSubviewToBack: scrollView];
   [textField setBackgroundColor: [self colorFromHexString: backgroundColor]];
 } else return;
}

- (void)setImageView: (ScreenGuardImageAlignment)alignment {
    [scrollView addSubview:imageView];
    
    CGFloat scrollViewWidth = scrollView.bounds.size.width;
    CGFloat scrollViewHeight = scrollView.bounds.size.height;
    CGFloat imageViewWidth = imageView.bounds.size.width;
    CGFloat imageViewHeight = imageView.bounds.size.height;

    CGPoint imageViewOrigin;

    switch (alignment) {
        case AlignmentTopLeft:
            imageViewOrigin = CGPointMake(0, 0);
            break;
        case AlignmentTopCenter:
            imageViewOrigin = CGPointMake((scrollViewWidth - imageViewWidth) / 2, 0);
            break;
        case AlignmentTopRight:
            imageViewOrigin = CGPointMake(scrollViewWidth - imageViewWidth, 0);
            break;
        case AlignmentCenterLeft:
            imageViewOrigin = CGPointMake(0, (scrollViewHeight - imageViewHeight) / 2);
            break;
        case AlignmentCenter:
            imageViewOrigin = CGPointMake((scrollViewWidth - imageViewWidth) / 2, (scrollViewHeight - imageViewHeight) / 2);
            break;
        case AlignmentCenterRight:
            imageViewOrigin = CGPointMake(scrollViewWidth - imageViewWidth, (scrollViewHeight - imageViewHeight) / 2);
            break;
        case AlignmentBottomLeft:
            imageViewOrigin = CGPointMake(0, scrollViewHeight - imageViewHeight);
            break;
        case AlignmentBottomCenter:
            imageViewOrigin = CGPointMake((scrollViewWidth - imageViewWidth) / 2, scrollViewHeight - imageViewHeight);
            break;
        case AlignmentBottomRight:
            imageViewOrigin = CGPointMake(scrollViewWidth - imageViewWidth, scrollViewHeight - imageViewHeight);
            break;
        default:
            imageViewOrigin = CGPointZero;
            break;
    }

    imageView.frame = CGRectMake(imageViewOrigin.x, imageViewOrigin.y, imageViewWidth, imageViewHeight);

    CGFloat contentWidth = MAX(scrollViewWidth, imageViewOrigin.x + imageViewWidth);
    CGFloat contentHeight = MAX(scrollViewHeight, imageViewOrigin.y + imageViewHeight);
    scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)setImageViewBasedOnPosition:(double)top left:(double)left bottom:(double)bottom right:(double)right {
    [scrollView addSubview:imageView];
    
    CGFloat scrollViewWidth = scrollView.bounds.size.width;
    CGFloat scrollViewHeight = scrollView.bounds.size.height;
    CGFloat imageViewWidth = imageView.bounds.size.width;
    CGFloat imageViewHeight = imageView.bounds.size.height;

    CGFloat centerX = scrollViewWidth / 2;
    CGFloat centerY = scrollViewHeight / 2;

    CGFloat imageViewX = centerX + left - right - (imageViewWidth / 2);
    CGFloat imageViewY = centerY + top - bottom - (imageViewHeight / 2);

    imageView.frame = CGRectMake(imageViewX, imageViewY, imageViewWidth, imageViewHeight);

    CGFloat contentWidth = MAX(scrollViewWidth, fabs(left - right) + imageViewWidth);
    CGFloat contentHeight = MAX(scrollViewHeight, fabs(top - bottom) + imageViewHeight);
    scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void) initTextField {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    
    [textField setTextAlignment:NSTextAlignmentCenter];
    [textField setUserInteractionEnabled: NO];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window makeKeyAndVisible];
    [window.layer.superlayer addSublayer:textField.layer];

    if (textField.layer.sublayers.firstObject) {
      [textField.layer.sublayers.firstObject addSublayer: window.layer];
    }
}


- (void)removeScreenShot {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeOverlay];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        if (textField != nil) {
            if (imageView != nil) {
                [imageView setImage: nil];
                [imageView removeFromSuperview];
                imageView = nil;
            }
            if (scrollView != nil) {
                [scrollView removeFromSuperview];
                scrollView = nil;
            }
            [textField setSecureTextEntry: FALSE];
            [textField setBackgroundColor: [UIColor clearColor]];
            [textField setBackground: nil];
            
            CALayer *textFieldLayer = textField.layer;
            CALayer *windowSuperlayer = textFieldLayer.superlayer;
            CALayer *textFieldSecureSublayer = textFieldLayer.sublayers.firstObject;
            
            if (textFieldSecureSublayer && [textFieldSecureSublayer.sublayers containsObject:window.layer]) {
                [window.layer removeFromSuperlayer];
                if (windowSuperlayer) {
                    [windowSuperlayer addSublayer:window.layer];
                }
            }
            
            [textFieldLayer removeFromSuperlayer];
            [textField removeFromSuperview];
            
            textField = nil;
            
            [self logAction:@"deactivate" status:NO];
        }
    });
}

- (UIViewController*)topViewController:(UIViewController*)rootViewController {
  if (rootViewController.presentedViewController == nil) {
      return rootViewController;
  }

  if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
      UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
      return [self topViewController:navigationController.viewControllers.lastObject];
  }

  if ([rootViewController.presentedViewController isKindOfClass:[UITabBarController class]]) {
      UITabBarController *tabBarController = (UITabBarController *)rootViewController.presentedViewController;
      return [self topViewController:tabBarController.selectedViewController];
  }

  return [self topViewController:rootViewController.presentedViewController];
}


- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (UIImage *)convertViewToImage:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Overlay Logic

- (void)showOverlay:(BOOL)persistent {
    if (textField == nil) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeOverlay];
        
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (!keyWindow) return;
        
        self->_overlayView = [[UIView alloc] initWithFrame:keyWindow.bounds];
        self->_overlayView.backgroundColor = textField.backgroundColor;
        self->_overlayView.userInteractionEnabled = NO;
        
        if (textField.background) {
            UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self->_overlayView.bounds];
            bgImageView.image = textField.background;
            bgImageView.contentMode = UIViewContentModeScaleAspectFill;
            [self->_overlayView addSubview:bgImageView];
        }
        
        if (imageView != nil && imageView.superview != nil) {
            UIImageView *imgCopy = [[UIImageView alloc] initWithFrame:imageView.frame];
            imgCopy.image = imageView.image;
            imgCopy.contentMode = imageView.contentMode;
            imgCopy.clipsToBounds = imageView.clipsToBounds;
            [self->_overlayView addSubview:imgCopy];
        }
        
        [keyWindow addSubview:self->_overlayView];
        [keyWindow bringSubviewToFront:self->_overlayView];
        
        if (!persistent) {
            double delayInSeconds = [self->_config[kSGConfigTimeAfterResume] doubleValue] / 1000.0;
            if (delayInSeconds <= 0) delayInSeconds = 1.0;
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self removeOverlay];
            });
        }
    });
}

- (void)removeOverlay {
    if ([NSThread isMainThread]) {
        if (self->_overlayView) {
            [self->_overlayView removeFromSuperview];
            self->_overlayView = nil;
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeOverlay];
        });
    }
}

#pragma mark - FlutterStreamHandler methods

- (void)secureViewWithImage:(nonnull NSDictionary *)source withDefaultSource:(nullable NSDictionary *)defaultSource withWidth:(nonnull NSNumber *)width withHeight:(nonnull NSNumber *)height withAlignment:(ScreenGuardImageAlignment)alignment withBackgroundColor:(nonnull NSString *)backgroundColor {
}

@end
