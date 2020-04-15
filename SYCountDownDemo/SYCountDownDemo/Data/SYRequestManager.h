
// 请求管理类

#import <Foundation/Foundation.h>
#import "SYDataModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^RequstTaskCompletionBlock)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void(^RequstSucceedBlock)(NSHTTPURLResponse *response);
typedef void(^RequstFailedBlock)(NSError *error);

@interface SYRequestManager : NSObject
+(SYRequestManager *)shareManager;

+ (void)GET:(NSString *)URLPathString query:(NSDictionary * _Nullable)query succeed:(RequstSucceedBlock)succeed failed:(RequstFailedBlock)failed;


@property (nonatomic, strong) SYDataModel *alertModel;

@property (nonatomic, strong) NSArray *listArray;

@property (nonatomic, strong) NSArray *cycleArray;
// 生成本地假数据
+(void)loadAllData;
@end

NS_ASSUME_NONNULL_END
