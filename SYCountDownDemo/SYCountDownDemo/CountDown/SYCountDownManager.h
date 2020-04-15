
// 倒计时管理类

#import <Foundation/Foundation.h>
@class BWCountDownModel;
NS_ASSUME_NONNULL_BEGIN
typedef void (^CountDownTimerBlock)(BWCountDownModel *cdModel);

@interface SYCountDownManager : NSObject
@property (nonatomic, copy) CountDownTimerBlock timerBlock;
//- (void)countDownWithPER_SEC:(UICollectionView *)collectionView dataList:(NSArray *)dataList;
/// 创建定时器
-(void)countDownWithCDBlock:(void (^)(void))cdBlock;
/// 创建定时器
-(void)creatCountDownTimer:(NSInteger)endTime;
/// 创建倒计时数据模型
+(BWCountDownModel *)creatCountDownModelWithString:(NSInteger)endTime;
/// 倒计时字符串
+(NSString *)getNowTimeWithString:(NSInteger)endTime;
/// 倒计时字符串
+(NSString *)getNowTimeWithModel:(BWCountDownModel *)model;

/// 主动销毁定时器
-(void)destoryTimer;
@end


@interface BWCountDownModel : NSObject
@property (nonatomic, assign) BOOL isFinish;

//@property (nonatomic, assign) int days;
@property (nonatomic, assign) int hours;
@property (nonatomic, assign) int minutes;
@property (nonatomic, assign) int seconds;

//@property (nonatomic, copy) NSString *dayStr;
@property (nonatomic, copy) NSString *hoursStr;
@property (nonatomic, copy) NSString *minutesStr;
@property (nonatomic, copy) NSString *secondsStr;


@end
NS_ASSUME_NONNULL_END
