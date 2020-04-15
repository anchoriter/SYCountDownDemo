

#import "ListTableViewCell.h"

@implementation ListTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = [UIColor blueColor];
        self.detailTextLabel.textColor = [UIColor redColor];
    }
    return self;
}
-(void)setModel:(SYDataModel *)model{
    _model = model;
}
-(void)bindCountDownEndTime:(NSString *)endTimeStr isFinish:(BOOL)isFinish{
    if (isFinish) {
        self.detailTextLabel.text = @"活动已结束";
        self.model = self.model;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kCountDownChangeNotification" object:nil];
        }];
    }else{
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@后结束",endTimeStr];
    }
}
@end
