
#import "SYAlertView.h"
#import "MacrosDefinition.h"



@interface SYAlertView ()
/** 背景 */
@property (nonatomic, strong) UIView *alertView;
/** 关闭 */
@property (nonatomic, strong) UIButton *closeButton;
/** 背景图 */
@property (nonatomic, strong) UIImageView *coverImageView;
@end
@implementation SYAlertView
+(SYAlertView *)shareAlertView{
    static SYAlertView *object = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [[SYAlertView alloc] init];
    });
    return object;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBA(0, 0, 0, 0.4);
    }
    return self;
}

+(void)presentCountDownAlertViewWithTitle:(NSString *)title countDownView:(UIView *)countDownView superView:(nullable UIView *)superView closeAction:(AlertViewCloseClick)closeAction{
    
    [SYAlertView cleanAlertView];
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SYAlertView presentCountDownAlertViewWithTitle:title countDownView:countDownView superView:superView closeAction:closeAction];
        });
    }
    if (!superView) {
        superView = [SYAlertView getFrontWindow];
    }
    
    [superView addSubview:[SYAlertView shareAlertView]];
    [SYAlertView shareAlertView].userInteractionEnabled = NO;
    superView.userInteractionEnabled = NO;

    [[SYAlertView shareAlertView] addSubview:[SYAlertView shareAlertView].alertView];
    
    [SYAlertView shareAlertView].coverImageView.backgroundColor = RGB(240, 67, 37);
    [[SYAlertView shareAlertView].alertView addSubview:[SYAlertView shareAlertView].coverImageView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    titleLabel.textColor = RGB(253, 224, 93);
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.text = title;
    [[SYAlertView shareAlertView].alertView addSubview:titleLabel];
    
    [[SYAlertView shareAlertView].alertView addSubview:countDownView];
    
    [[SYAlertView shareAlertView].alertView addSubview:[SYAlertView shareAlertView].closeButton];
    
    CGRect supboundsRect = superView.bounds;
    if (CGSizeEqualToSize(supboundsRect.size, CGSizeZero)) {
        supboundsRect  = [[UIScreen mainScreen] bounds];
    }
    [SYAlertView shareAlertView].frame = supboundsRect;
    CGFloat viewW = CGRectGetWidth(supboundsRect);
    CGFloat viewH = CGRectGetHeight(supboundsRect);
    CGFloat bgWidth = 250;
    CGFloat bgHeight = 150+10+28;
    
    [SYAlertView shareAlertView].alertView.frame = CGRectMake((viewW-bgWidth)*0.5, viewH, bgWidth, bgHeight);
    [SYAlertView shareAlertView].coverImageView.frame = CGRectMake(0, 0, bgWidth, bgHeight-28-10);
        
    [SYAlertView shareAlertView].closeButton.frame = CGRectMake((CGRectGetWidth([SYAlertView shareAlertView].alertView.bounds)-28)*0.5, bgHeight-28, 28, 28);
    titleLabel.frame = CGRectMake(0, 20, bgWidth, 28);
    
    countDownView.frame = CGRectMake((bgWidth-127)*0.5, CGRectGetMaxY(titleLabel.frame)+30, 127, 21);
    
    [SYAlertView shareAlertView].closeBlock = closeAction;
    
    CGRect rect = [SYAlertView shareAlertView].alertView.frame;
    rect.origin.y = (viewH-bgHeight)*0.5;
    [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:0.8 initialSpringVelocity:0.0f options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        [SYAlertView shareAlertView].alertView.frame = rect;
    } completion:^(BOOL finished) {
        [SYAlertView shareAlertView].userInteractionEnabled = YES;
        superView.userInteractionEnabled = YES;
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (didShowBlock) {
//                didShowBlock();
//            }
//        });
    }];
}

/// 关闭弹窗
-(void)clickCloseBtn:(UIButton *)button{
    [SYAlertView removeAlertView];
}

+(void)cleanAlertView{
    for (UIView *view in [SYAlertView shareAlertView].alertView.subviews) {
        [view removeFromSuperview];
    }
    [[SYAlertView shareAlertView].alertView removeFromSuperview];
    [[SYAlertView shareAlertView] removeFromSuperview];
}
/// 移除弹窗
+(void)removeAlertView{
    [SYAlertView shareAlertView].userInteractionEnabled = NO;
    CGRect rect = [SYAlertView shareAlertView].alertView.frame;
    rect.origin.y = CGRectGetHeight([SYAlertView shareAlertView].bounds);
    [UIView animateWithDuration:0.25 animations:^{
        [SYAlertView shareAlertView].alertView.frame = rect;
    } completion:^(BOOL finished) {
        for (UIView *view in [SYAlertView shareAlertView].alertView.subviews) {
            [view removeFromSuperview];
        }
        [[SYAlertView shareAlertView].alertView removeFromSuperview];
        [[SYAlertView shareAlertView] removeFromSuperview];
        
        if ([SYAlertView shareAlertView].closeBlock) {
            [SYAlertView shareAlertView].closeBlock();
        }
    }];
}

-(UIView *)alertView{
    if (!_alertView) {
        _alertView = [[UIView alloc] init];
        _alertView.backgroundColor = [UIColor clearColor];
    }
    return _alertView;
}
-(UIImageView *)coverImageView{
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        _coverImageView.layer.masksToBounds = YES;
        _coverImageView.layer.cornerRadius = 10.0f;
    }
    return _coverImageView;
}
-(UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"Login_alert_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(clickCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}
+(UIWindow *)getFrontWindow{
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal);
        BOOL windowKeyWindow = window.isKeyWindow;
        if(windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow) {
            return window;
        }
    }
    return nil;
}


@end
