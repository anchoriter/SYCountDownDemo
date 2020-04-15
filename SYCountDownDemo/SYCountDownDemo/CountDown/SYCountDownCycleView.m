
#import "SYCountDownCycleView.h"
#import "SYCountDownManager.h"
#import "MacrosDefinition.h"

NSString * const BWCountDownCycleNameKey = @"BWCountDownCycleNameKey";

@interface SYCountDownCycleView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) NSInteger totalItemsCount;

@property (nonatomic, strong) SYCountDownManager *cdManager;
@end
@implementation SYCountDownCycleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self initialization];
        [self setupMainView];
    }
    return self;
}
- (void)initialization{
    self.autoScrollTimeInterval = 2.0;
    self.totalItemsCount = 100;
    self.backgroundColor = [UIColor clearColor];
    
    [self addTimer];
}
- (void)setupMainView {
    [self addSubview:self.collectionView];
    
}
-(void)layoutSubviews{
    [super layoutSubviews];
    _flowLayout.itemSize = self.frame.size;
    _collectionView.frame = self.bounds;
    if (self.collectionView.contentOffset.x == 0 &&  _totalItemsCount) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_totalItemsCount * 0.5 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection{
    _scrollDirection = scrollDirection;
    _flowLayout.scrollDirection = scrollDirection;
}
-(void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval{
    _autoScrollTimeInterval = autoScrollTimeInterval;
    if (autoScrollTimeInterval) {
        [self addTimer];
    }
}
-(void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    if (dataArray.count>1) {
        [self addTimer];
    }else{
        [self invalidateTimer];
    }
    
    [self.collectionView reloadData];
    
    __weak typeof(self)weakSelf = self;
    [self.cdManager destoryTimer];
    
    [self.cdManager countDownWithCDBlock:^{
        [weakSelf handleCollectionViewCellCountDown];
    }];
}
-(void)handleCollectionViewCellCountDown{
    NSArray *array = [self.collectionView visibleCells];//获取的cell不完成正确
    if(array != nil && array.count > 0){
        for (BWCountDownCycleCell *tempCell in array) {
            /// 换成倒计时模型
            BWCountDownModel *cdmodel = [SYCountDownManager creatCountDownModelWithString:tempCell.model.EndTime];
            // 显示倒计时数据
            [tempCell bindCountDownEndTime:[SYCountDownManager getNowTimeWithModel:cdmodel] isFinish:cdmodel.isFinish];
        }
    }
}
-(void)bindCountDownCycleArray:(NSArray *)array{
    self.dataArray = array;
    
    self.totalItemsCount = [array count]*100;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _totalItemsCount;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    BWCountDownCycleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:BWCountDownCycleNameKey forIndexPath:indexPath];
    
    long itemIndex = [self pageControlIndexWithCurrentCellIndex:indexPath.item];
    SYDataModel *model = self.dataArray[itemIndex];
    cell.model = model;
    return cell;
}

#warning 非常重要
// 提前计算倒计时，避免倒计时刚出现时的闪动
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BWCountDownCycleCell *tempCell = (BWCountDownCycleCell *)cell;
    if (tempCell.model.EndTime>0) {
        /// 换成倒计时模型
        BWCountDownModel *cdmodel = [SYCountDownManager creatCountDownModelWithString:tempCell.model.EndTime];
        // 显示倒计时数据
        [tempCell bindCountDownEndTime:[SYCountDownManager getNowTimeWithModel:cdmodel] isFinish:cdmodel.isFinish];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (int)pageControlIndexWithCurrentCellIndex:(NSInteger)index
{
    return (int)index % self.dataArray.count;
}
#pragma mark - - - NSTimer
- (void)addTimer {
    [self invalidateTimer];

    self.timer = [NSTimer timerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
- (void)invalidateTimer {
    [_timer invalidate];
    _timer = nil;
}
- (void)automaticScroll{
    if (0 == _totalItemsCount) return;
    int currentIndex = [self currentIndex];
    int targetIndex = currentIndex + 1;
    [self scrollToIndex:targetIndex];
}
- (void)scrollToIndex:(int)targetIndex{
    if (targetIndex >= _totalItemsCount) {
        targetIndex = _totalItemsCount * 0.5;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        return;
    }
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}
- (int)currentIndex{
    if (self.collectionView.bounds.size.width == 0 || self.collectionView.bounds.size.height == 0) {
        return 0;
    }
    
    int index = 0;
    if (_flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (self.collectionView.contentOffset.x + _flowLayout.itemSize.width * 0.5) / _flowLayout.itemSize.width;
    } else {
        index = (self.collectionView.contentOffset.y + _flowLayout.itemSize.height * 0.5) / _flowLayout.itemSize.height;
    }
    
    return MAX(0, index);
}
//解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    [self invalidateTimer];
    [self.cdManager destoryTimer];
}
/** 解决viewWillAppear时出现时轮播图卡在一半的问题，在控制器viewWillAppear时调用此方法 */
- (void)adjustWhenControllerViewWillAppera{
    long targetIndex = [self currentIndex];
    if (targetIndex < _totalItemsCount) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}
#pragma mark - 懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = NO;
        _collectionView.scrollEnabled = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[BWCountDownCycleCell class] forCellWithReuseIdentifier:BWCountDownCycleNameKey];
    }
    return _collectionView;
}
-(SYCountDownManager *)cdManager{
    if (!_cdManager) {
        _cdManager = [[SYCountDownManager alloc] init];
    }
    return _cdManager;
}
@end




@interface BWCountDownCycleCell ()

@end

@implementation BWCountDownCycleCell


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.logoImageView];
        [self addSubview:self.countDownLabel];
        [self addSubview:self.moreButton];
    }
    return self;
}
-(void)bindCountDownEndTime:(NSString *)endTimeStr isFinish:(BOOL)isFinish{
    if (isFinish) {
        self.countDownLabel.text = @"倒计时已结束";
        self.model =  self.model;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kCountDownChangeNotification" object:nil];
        }];
    }else{
        
        NSMutableAttributedString *moreAttr = [[NSMutableAttributedString alloc] initWithString:@"距活动结束仅剩 "];
//        moreAttr.color = RGB(93, 51, 15);

        NSMutableAttributedString *timeAttr = [[NSMutableAttributedString alloc] initWithString:endTimeStr];
//        timeAttr.color = RGB(238, 51, 12);
        
        [moreAttr appendAttributedString:timeAttr];
        
//        moreAttr.font = [UIFont systemFontOfSize:15];
        self.countDownLabel.attributedText = moreAttr;
    }
}
-(void)setModel:(SYDataModel *)model{
    _model = model;
    
//    [self.logoImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholder:nil];
}
-(void)clickMoreBtn:(UIButton *)sender{
    
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat margin = 6;
    CGFloat logoW = height-margin*2;
    CGFloat moreW = 95;
    self.logoImageView.frame = CGRectMake(0, margin, logoW, logoW);
    self.countDownLabel.frame = CGRectMake(CGRectGetMaxX(self.logoImageView.frame)+7.5, margin, width-CGRectGetMaxX(self.logoImageView.frame)-7.5-moreW, logoW);
    self.moreButton.frame =CGRectMake(width-moreW, (height-32)*0.5, moreW, 32);
}
#pragma mark - 懒加载
-(UIImageView *)logoImageView{
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.layer.cornerRadius = 4;
        _logoImageView.layer.masksToBounds = YES;
    }
    return _logoImageView;
}
-(UILabel *)countDownLabel{
    if (!_countDownLabel) {
        _countDownLabel = [[UILabel alloc] init];
        _countDownLabel.textColor = RGB(93, 51, 15);
        _countDownLabel.font = [UIFont systemFontOfSize:15];
        _countDownLabel.numberOfLines = 1;
        _countDownLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _countDownLabel;
}
-(UIButton *)moreButton{
    if (!_moreButton) {
        _moreButton = [[UIButton alloc] init];
//        [_moreButton setImage:[UIImage imageNamed:@"my_countdown_btn_more"] forState:UIControlStateNormal];
        _moreButton.backgroundColor = [UIColor redColor];
        [_moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_moreButton setTitle:@"更多" forState:UIControlStateNormal];
        
        
        [_moreButton addTarget:self action:@selector(clickMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

@end
