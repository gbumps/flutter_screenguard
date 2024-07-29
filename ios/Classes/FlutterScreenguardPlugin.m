#import "FlutterScreenguardPlugin.h"
#import "FlutterScreenguardScreenshotListener.h"
#import "FlutterScreenguardRecordingListener.h"
#import "SDWebImage/SDWebImage.h"

UITextField *textField;
UIImageView *imageView;
UIScrollView *scrollView;


FlutterScreenguardPlugin* instance;
FlutterMethodChannel* eventChannelScreenRecording;
FlutterMethodChannel* eventChannelScreenshot;

NSString * const REGISTER = @"register";
NSString * const REGISTER_BLUR_VIEW = @"registerWithBlurView";
NSString * const REGISTER_IMAGE_VIEW = @"registerWithImage";
NSString * const UNREGISTER = @"unregister";

@implementation FlutterScreenguardPlugin
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
    if ([method isEqualToString: REGISTER]) {
        NSString *color = call.arguments[@"color"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self secureViewWithBackgroundColor: color];
        });
        result(@{@"status": @"success"});
    } else if ([method isEqualToString: REGISTER_BLUR_VIEW]) {
        NSNumber *radius = call.arguments[@"radius"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self secureViewWithBlurView: radius];
        });
        result(@{@"status": @"success"});
    
    } else if ([method isEqualToString: REGISTER_IMAGE_VIEW]) {
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
    }
     else if ([method isEqualToString: REGISTER_SCREEN_RECORDING_EVT]) {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (instance.screenRecordingListener == nil) {
                 instance.screenRecordingListener = [[FlutterScreenguardRecordingListener alloc] initWithChannel: eventChannelScreenRecording];
             }
         });
        result(@{@"status": @"success"});
    } else if ([method isEqualToString: UNREGISTER]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeScreenShot];
        });
        result(@{@"status": @"success"});
    } else if ([method isEqualToString: DEACTIVATE_SCREEN_RECORDING_EVT]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (instance.screenRecordingListener != nil) {
                [instance.screenRecordingListener stopListening];
                instance.screenRecordingListener = nil;
            }
        });
        result(@"disposed screen recording");
    } else if ([method isEqualToString: REGISTER_SCREENSHOT_EVT]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (instance.screenShotListener == nil) {
                instance.screenShotListener = [[FlutterScreenguardScreenshotListener alloc] initWithChannel: eventChannelScreenshot];
            }
        });
        result(@{@"status": @"success"});
    } else if ([method isEqualToString: DEACTIVATE_SCREENSHOT_EVT]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (instance.screenShotListener != nil) {
                [instance.screenShotListener stopListening];
                instance.screenShotListener = nil;
            }
        });
        result(@"disposed screenshot");
    }
}

- (void)secureViewWithBackgroundColor: (NSString *)color {
  if (@available(iOS 13.0, *)) {
    if (textField == nil) {
      [self initTextField];
    }
    [textField setSecureTextEntry: TRUE];
    [textField setBackgroundColor: [self colorFromHexString: color]];
  } else return;
}

- (void)secureViewWithBlurView: (nonnull NSNumber *)radius {
  if (@available(iOS 13.0, *)) {
    if (textField == nil) {
      [self initTextField];
    }
      
    [textField setBackgroundColor: [UIColor clearColor]];
    [textField setSecureTextEntry: TRUE];
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
//    UIViewController *presentedViewController = [self topViewController:rootViewController];
    UIImage *imageView = [self convertViewToImage:rootViewController.view.superview];
    CIImage *inputImage = [CIImage imageWithCGImage:imageView.CGImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:inputImage forKey:kCIInputImageKey];
    [blurFilter setValue:radius forKey:kCIInputRadiusKey];
          
    CIImage *outputImage = [blurFilter valueForKey:kCIOutputImageKey];
          
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *blurredImage = [UIImage imageWithCGImage:cgImage];
          
    CGImageRelease(cgImage);
      
    [textField setBackground: blurredImage];
    
  } else return;
}

- (void)secureViewWithImageAlignment:(nonnull NSString *)source
//                  withDefaultSource:(nullable NSDictionary *)defaultSource
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
  UIWindow *window = [UIApplication sharedApplication].keyWindow;
  if (textField != nil) {
      if (imageView != nil) {
          [imageView setImage: nil];
          [imageView removeFromSuperview];
      }
      if (scrollView != nil) {
          [scrollView removeFromSuperview];
      }
    [textField setSecureTextEntry: FALSE];
    [textField setBackgroundColor: [UIColor clearColor]];
    [textField setBackground: nil];
    CALayer *textFieldLayer = textField.layer.sublayers.firstObject;
    if ([window.layer.superlayer.sublayers containsObject:textFieldLayer]) {
       [textFieldLayer removeFromSuperlayer];
    }
  }
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

#pragma mark - FlutterStreamHandler methods

- (void)secureViewWithImage:(nonnull NSDictionary *)source withDefaultSource:(nullable NSDictionary *)defaultSource withWidth:(nonnull NSNumber *)width withHeight:(nonnull NSNumber *)height withAlignment:(ScreenGuardImageAlignment)alignment withBackgroundColor:(nonnull NSString *)backgroundColor {
}

@end
