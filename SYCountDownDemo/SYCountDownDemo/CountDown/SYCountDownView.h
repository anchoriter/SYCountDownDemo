
// 时分秒卡片倒计时

#import <UIKit/UIKit.h>
#import "SYCountDownManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYCountDownView : UIView
@property (nonatomic, strong) SYCountDownManager *cdManager;
/// 截止时间
-(void)bindCountDownEndTime:(NSInteger)endTime;
@end

NS_ASSUME_NONNULL_END
