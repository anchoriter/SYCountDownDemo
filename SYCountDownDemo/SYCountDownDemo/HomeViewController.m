
#import "HomeViewController.h"
#import "SYRequestManager.h"
#import "NSDate+InternetDateTime.h"
#import "MacrosDefinition.h"

#import "ListViewController.h"

#import "SYCountDownView.h"
#import "SYAlertView.h"

#import "SYCountDownCycleView.h"

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *dataTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) BOOL showCycleView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 在自己的应用请求管理类中，记录每一次的服务器时间，在需要取时间的时候能保证服务器时间戳的准确性
    // 这里这是模拟了一次请求
    [SYRequestManager GET:@"https:www.baidu.com" query:nil succeed:^(NSHTTPURLResponse * _Nonnull response) {
        NSLog(@"响应头信息%@",response.allHeaderFields);
    } failed:^(NSError * _Nonnull error) {

    }];
    
    
    [self.view addSubview:self.dataTableView];
    
    [self.dataArray addObjectsFromArray:@[@"弹窗",@"列表",@"上下滚动轮播"]];
    [self.dataTableView reloadData];
    
    
    // 模拟启动请求到的数据，可忽略
    [SYRequestManager loadAllData];
}



#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.showCycleView) {
      return 90;
    }else{
        return 0.01;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CountDownCellFooter"];
    if (!footerView) {
        footerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"CountDownCellFooter"];
        footerView.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    SYCountDownCycleView *cycleView = [footerView viewWithTag:20302];
    if (self.showCycleView) {
        cycleView.hidden = NO;
      if (!cycleView) {
          cycleView = [[SYCountDownCycleView alloc] init];
          cycleView.tag = 20302;
          cycleView.layer.cornerRadius = 10;
          cycleView.layer.masksToBounds = YES;
          cycleView.frame = CGRectMake(20, 10, CGRectGetWidth(tableView.bounds)-20*2, 90-10*2);
          [footerView addSubview:cycleView];
          cycleView.backgroundColor = RGB(255, 245, 233);
      }
      [cycleView bindCountDownCycleArray:[SYRequestManager shareManager].cycleArray];
    }else{
       cycleView.hidden = YES;
    }
    
    
    
    return footerView;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(UITableViewCell.class)];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            // 弹窗
            SYCountDownView *ctDView = [[SYCountDownView alloc] init];
           
            [ctDView bindCountDownEndTime:[SYRequestManager shareManager].alertModel.EndTime];
            
            [SYAlertView presentCountDownAlertViewWithTitle:@"活动倒计时弹窗" countDownView:ctDView superView:self.navigationController.view closeAction:^{
                
            }];
            
        }
            break;
        case 1:
        {
            // 列表
            ListViewController *listVC = [[ListViewController alloc] init];
            [self.navigationController pushViewController:listVC animated:YES];
        }
            break;
        case 2:
        {
            // 上下滚动轮播
            self.showCycleView = !self.showCycleView;
            [self.dataTableView reloadData];
        }
            break;
        default:
            break;
    }
}


-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.dataTableView.frame = self.view.bounds;
}

#pragma mark - lazy
-(UITableView *)dataTableView{
    if (!_dataTableView) {
        _dataTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _dataTableView.delegate = self;
        _dataTableView.dataSource = self;
        _dataTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _dataTableView.estimatedRowHeight = 0;
        _dataTableView.estimatedSectionHeaderHeight = 0;
        _dataTableView.estimatedSectionFooterHeight = 0;
        _dataTableView.backgroundView = nil;
        _dataTableView.backgroundColor = [UIColor clearColor];
        //        _dataTableView.bounces = NO;
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            _dataTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
#endif
    }
    return _dataTableView;
}
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
@end
