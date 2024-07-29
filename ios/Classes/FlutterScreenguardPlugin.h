#import <Flutter/Flutter.h>
#import <FlutterScreenguardScreenshotListener.h>
#import <FlutterScreenguardRecordingListener.h>

typedef NS_ENUM(NSInteger, ScreenGuardImageAlignment) {
    AlignmentTopLeft,
    AlignmentTopCenter,
    AlignmentTopRight,
    AlignmentCenterLeft,
    AlignmentCenter,
    AlignmentCenterRight,
    AlignmentBottomLeft,
    AlignmentBottomCenter,
    AlignmentBottomRight
};


NSString* _Nullable NSStringFromAlignment(ScreenGuardImageAlignment alignment);

extern NSString * const REGISTER;
extern NSString * const REGISTER_BLUR_VIEW;
extern NSString * const REGISTER_IMAGE_VIEW;
extern NSString * const UNREGISTER;

@interface FlutterScreenguardPlugin : NSObject<FlutterPlugin>

@property (nonatomic, strong) FlutterScreenguardScreenshotListener * _Nullable screenShotListener;
@property (nonatomic, strong) FlutterScreenguardRecordingListener * _Nullable screenRecordingListener;

- (void)secureViewWithBackgroundColor: (NSString *_Nonnull)color;
- (void)secureViewWithBlurView: (nonnull NSNumber *)radius;
- (void)secureViewWithImage: (nonnull NSDictionary *) source
          withDefaultSource: (nullable NSDictionary *) defaultSource
                  withWidth: (nonnull NSNumber *) width
                 withHeight: (nonnull NSNumber *) height
              withAlignment: (ScreenGuardImageAlignment) alignment
        withBackgroundColor: (nonnull NSString *) backgroundColor;
- (void)removeScreenShot;
- (UIColor *_Nonnull)colorFromHexString:(NSString *_Nonnull)hexString;
- (UIImage *_Nonnull)convertViewToImage:(UIView *_Nonnull)view;
@end
