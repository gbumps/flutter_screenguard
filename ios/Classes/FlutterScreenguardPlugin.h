#import <Flutter/Flutter.h>

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

@interface FlutterScreenguardPlugin : NSObject<FlutterPlugin>
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
