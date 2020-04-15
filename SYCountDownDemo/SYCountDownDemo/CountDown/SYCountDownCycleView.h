
// 倒计时滚动轮播

#import <UIKit/UIKit.h>
#import "SYDataModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface SYCountDownCycleView : UIView
//////////////////////  滚动控制API //////////////////////
/** 自动滚动间隔时间,默认5s */
@property (nonatomic, assign) CGFloat autoScrollTimeInterval;
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

/** 解决viewWillAppear时出现时轮播图卡在一半的问题，在控制器viewWillAppear时调用此方法 */
- (void)adjustWhenControllerViewWillAppera;

-(void)bindCountDownCycleArray:(NSArray *)array;
@end

@interface BWCountDownCycleCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *countDownLabel;
@property (nonatomic, strong) UIButton *moreButton;

@property (nonatomic, strong) SYDataModel *model;

-(void)bindCountDownEndTime:(NSString *)endTimeStr isFinish:(BOOL)isFinish;
@end
NS_ASSUME_NONNULL_END
