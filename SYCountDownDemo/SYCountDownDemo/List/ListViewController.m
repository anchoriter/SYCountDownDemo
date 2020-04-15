

#import "ListViewController.h"
#import "SYRequestManager.h"
#import "NSDate+InternetDateTime.h"
#import "MacrosDefinition.h"
#import "SYCountDownManager.h"
#import "SYDataModel.h"
#import "ListTableViewCell.h"

@interface ListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *dataTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) SYCountDownManager *cdManager;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 在应用的请求管理类中，记录每一次的服务器时间，在需要取时间的时候能保证服务器时间戳的准确性
    // 这里这是模拟了一次请求
    [SYRequestManager GET:@"https:www.baidu.com" query:nil succeed:^(NSHTTPURLResponse * _Nonnull response) {
        NSLog(@"响应头信息%@",response.allHeaderFields);
    } failed:^(NSError * _Nonnull error) {

    }];
    
    
    [self.view addSubview:self.dataTableView];
    
    [self loadData];
    
    
    [self.cdManager destoryTimer];
    __weak typeof(self)weakSelf = self;
    [self.cdManager countDownWithCDBlock:^{
        [weakSelf handleOrderCollectionViewCellCountDown];
    }];
}
-(void)loadData{
    [self.dataArray addObjectsFromArray:[SYRequestManager shareManager].listArray];
    [self.dataTableView reloadData];
}

-(void)handleOrderCollectionViewCellCountDown{
    NSArray *array = [self.dataTableView visibleCells];//获取的cell不完成正确
    if(array != nil && array.count > 0){
        for (ListTableViewCell *tempCell in array) {
//            tempCell.model.HelpEndTime = 1585021147000;
            
            if (tempCell.model.EndTime>0) {
                /// 换成倒计时模型
                BWCountDownModel *cdmodel = [SYCountDownManager creatCountDownModelWithString:tempCell.model.EndTime];
                // 显示倒计时数据
                [tempCell bindCountDownEndTime:[SYCountDownManager getNowTimeWithModel:cdmodel] isFinish:cdmodel.isFinish];
            }
        }
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ListTableViewCell.class)];
    if (!cell) {
        cell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass(ListTableViewCell.class)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"第%@行",@(indexPath.row)];

    cell.model = [self.dataArray objectAtIndex:indexPath.row];
    
    return cell;
}

#warning 非常重要
// 提前计算倒计时，避免倒计时刚出现时的闪动
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    ListTableViewCell *tempCell = (ListTableViewCell *)cell;
    if (tempCell.model.EndTime>0) {
        BWCountDownModel *cdmodel = [SYCountDownManager creatCountDownModelWithString:tempCell.model.EndTime];
        [tempCell bindCountDownEndTime:[SYCountDownManager getNowTimeWithModel:cdmodel] isFinish:cdmodel.isFinish];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.dataTableView.frame = self.view.bounds;
}
-(void)dealloc{
    [self.cdManager destoryTimer];
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
-(SYCountDownManager *)cdManager{
    if (!_cdManager) {
        _cdManager = [[SYCountDownManager alloc] init];
    }
    return _cdManager;
}
@end
