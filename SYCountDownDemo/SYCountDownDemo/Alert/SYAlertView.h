
// 弹窗

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^AlertViewCloseClick)(void);


@interface SYAlertView : UIView
@property (nonatomic, copy) AlertViewCloseClick closeBlock;


+(void)presentCountDownAlertViewWithTitle:(NSString *)title countDownView:(UIView *)countDownView superView:(nullable UIView *)superView closeAction:(AlertViewCloseClick)closeAction;
@end

NS_ASSUME_NONNULL_END
