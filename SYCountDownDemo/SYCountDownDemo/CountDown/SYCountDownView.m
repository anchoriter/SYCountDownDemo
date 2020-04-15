

#import "SYCountDownView.h"
#import "MacrosDefinition.h"

@interface SYCountDownView ()
@property (nonatomic, strong) UILabel *hourLabel;
@property (nonatomic, strong) UILabel *minuteLabel;
@property (nonatomic, strong) UILabel *secondLabel;

@property (nonatomic, strong) UILabel *colonLabel1;
@property (nonatomic, strong) UILabel *colonLabel2;

@property (nonatomic, strong) UILabel *lastLabel;

@end
@implementation SYCountDownView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.hourLabel = [self creatTimeLabel];
        self.minuteLabel = [self creatTimeLabel];
        self.secondLabel = [self creatTimeLabel];
        self.colonLabel1 = [self creatColonLabel];
        self.colonLabel2 = [self creatColonLabel];
        self.lastLabel = [self creatColonLabel];
        self.lastLabel.textAlignment = NSTextAlignmentLeft;
        
        
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat w = 20;
    CGFloat h = 20;
    CGFloat y = (height-h)*0.5;
    
    CGFloat wc = 10;
    
    self.hourLabel.frame = CGRectMake(0, y, w, h);
    self.colonLabel1.frame = CGRectMake(CGRectGetMaxX(self.hourLabel.frame), y, wc, h);
    self.minuteLabel.frame = CGRectMake(CGRectGetMaxX(self.colonLabel1.frame), y, w, h);
    self.colonLabel2.frame = CGRectMake(CGRectGetMaxX(self.minuteLabel.frame), y, wc, h);
    self.secondLabel.frame = CGRectMake(CGRectGetMaxX(self.colonLabel2.frame), y, w, h);
    self.lastLabel.frame = CGRectMake(CGRectGetMaxX(self.secondLabel.frame), y, width-CGRectGetMaxX(self.secondLabel.frame), h);
}
-(void)bindCountDownEndTime:(NSInteger)endTime{
    SYCountDownManager *cdManager = [[SYCountDownManager alloc] init];
    self.cdManager = cdManager;
    [cdManager creatCountDownTimer:endTime];
    __weak typeof(self)weakSelf = self;
    cdManager.timerBlock = ^(BWCountDownModel * _Nonnull cdModel) {
        [weakSelf fillTimeCardWith:cdModel];
    };
}
-(void)fillTimeCardWith:(BWCountDownModel *)model{
    self.hourLabel.text = model.hoursStr;
    self.minuteLabel.text = model.minutesStr;
    self.secondLabel.text = model.secondsStr;

    self.lastLabel.text = @"后结束";
}

-(void)dealloc{
    [self.cdManager destoryTimer];
}
-(UILabel *)creatTimeLabel{
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.adjustsFontSizeToFitWidth = YES;
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.textColor = RGB(255, 223, 155);
    timeLabel.font = [UIFont systemFontOfSize:15];
    timeLabel.backgroundColor = RGB(158, 0, 0);
    timeLabel.layer.cornerRadius = 2;
    timeLabel.layer.masksToBounds = YES;
    [self addSubview:timeLabel];
    return timeLabel;
}
-(UILabel *)creatColonLabel{
    UILabel *colonLab = [[UILabel alloc] init];
    colonLab.adjustsFontSizeToFitWidth = YES;
    colonLab.textAlignment = NSTextAlignmentCenter;
    colonLab.textColor = RGB(255, 223, 155);
    colonLab.font = [UIFont systemFontOfSize:15];
    colonLab.backgroundColor = [UIColor clearColor];
    colonLab.text = @":";
    [self addSubview:colonLab];
    return colonLab;
}
@end
