
// 列表cell

#import <UIKit/UIKit.h>
@class SYDataModel;
NS_ASSUME_NONNULL_BEGIN

@interface ListTableViewCell : UITableViewCell
@property (nonatomic, strong) SYDataModel *model;

-(void)bindCountDownEndTime:(NSString *)endTimeStr isFinish:(BOOL)isFinish;
@end

NS_ASSUME_NONNULL_END
