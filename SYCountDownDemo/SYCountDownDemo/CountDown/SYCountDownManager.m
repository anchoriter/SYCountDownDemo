

#import "SYCountDownManager.h"
#import "NSDate+InternetDateTime.h"
#import "SYCountDownCycleView.h"

@interface SYCountDownManager (){
    dispatch_source_t _disTimer;
    NSInteger _endTime;
}

@end
@implementation SYCountDownManager

-(instancetype)init{
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)countDownWithCDBlock:(void (^)(void))cdBlock{
    if (!_disTimer) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _disTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_disTimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
        //每秒执行
        dispatch_source_set_event_handler(_disTimer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                cdBlock();
            });
        });
        // 启动定时器
        dispatch_resume(_disTimer);
    }
}
-(void)creatCountDownTimer:(NSInteger)endTime{
    _endTime = endTime;
    if (!_disTimer) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _disTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_disTimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
        //每秒执行
        dispatch_source_set_event_handler(_disTimer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                BWCountDownModel *model = [SYCountDownManager creatCountDownModelWithString:endTime];
                if (self.timerBlock) {
                    self.timerBlock(model);
                }
            });
        });
        // 启动定时器
        dispatch_resume(_disTimer);
    }
}
/// 创建倒计时数据模型
+(BWCountDownModel *)creatCountDownModelWithString:(NSInteger)endTime{
    // 13位时间戳 向下取整
    NSInteger currentTime = floor([NSDate serverCurrentTimeStamp]);
    BWCountDownModel *model = [BWCountDownModel new];
    NSTimeInterval timeInterval = (endTime - currentTime)/1000;
    int days = (int)(timeInterval/(3600*24));
    int hours = (int)((timeInterval-days*24*3600)/3600)+days*24;
    int minutes = (int)(timeInterval-hours*3600)/60;// -days*24*3600
    int seconds = timeInterval-days*24*3600-hours*3600-minutes*60;
    if (endTime>0 && endTime < currentTime) {
        model.isFinish = YES;
        days = 0;
        hours = 0;
        minutes = 0;
        seconds = 0;
    }
    
    model.hours = hours;
    model.minutes = minutes;
    model.seconds = seconds;
    //天
//    model.dayStr = [NSString stringWithFormat:@"%d",days];
    //小时
    model.hoursStr = [NSString stringWithFormat:@"%d",model.hours];
    //分钟
    if(model.minutes<10){
        model.minutesStr = [NSString stringWithFormat:@"0%d",model.minutes];
    }else{
        model.minutesStr = [NSString stringWithFormat:@"%d",model.minutes];
    }
    //秒
    if(model.seconds < 10){
        model.secondsStr = [NSString stringWithFormat:@"0%d", model.seconds];
    }else{
        model.secondsStr = [NSString stringWithFormat:@"%d",model.seconds];
    }

    return model;
}
/// 倒计时字符串
+(NSString *)getNowTimeWithString:(NSInteger)endTime{
    BWCountDownModel *model = [SYCountDownManager creatCountDownModelWithString:endTime];
    NSString *countText = [SYCountDownManager getNowTimeWithModel:model];
    return countText;
}
/// 倒计时字符串
+(NSString *)getNowTimeWithModel:(BWCountDownModel *)model{
//    if (model.hours<=0 && model.minutes<=0 && model.seconds<=0) {
//        return @"活动已经结束！";
//    }
    NSString *countText = [NSString stringWithFormat:@"%@:%@:%@",model.hoursStr,model.minutesStr,model.secondsStr];
//    DLog(@"倒计时====%@",countText);
    return countText;
}


/// 主动销毁定时器
-(void)destoryTimer{
    if (_disTimer) {
        dispatch_source_cancel(_disTimer);
        _disTimer = nil;
    }
}
-(void)dealloc{
    NSLog(@"%s dealloc",object_getClassName(self));
    
}
@end



@implementation BWCountDownModel


@end
