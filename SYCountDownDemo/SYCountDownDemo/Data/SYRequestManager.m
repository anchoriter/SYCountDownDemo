
#import "SYRequestManager.h"
#import "NSDate+InternetDateTime.h"

#define ApiTimeOut 15.0f

@interface SYRequestManager ()
@property (nonatomic, strong) NSURLSessionConfiguration *configuration;
@property (nonatomic, strong) NSURLSession *session;
@end
@implementation SYRequestManager
+(SYRequestManager *)shareManager{
    static SYRequestManager *object = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [[SYRequestManager alloc] init];
    });
    return object;
}

+ (void)GET:(NSString *)URLPathString query:(NSDictionary * _Nullable)query succeed:(RequstSucceedBlock)succeed failed:(RequstFailedBlock)failed {
    
//    NSString *urlstring = [NSString stringWithFormat:@"%@%@/%@?%@&%@",HomePageUrl,URLPathString,APPID,fixedQueryString,customQueryString];
    
    NSString *urlstring = URLPathString;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:(NSURLRequestUseProtocolCachePolicy) timeoutInterval:ApiTimeOut];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json;charset=utf-8" forHTTPHeaderField: @"Content-Type"];
    
    [SYRequestManager requstManagerWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
                
        if (error) {
            failed(error);
            return ;
        }
        
        if (resp.statusCode < 200 || resp.statusCode >= 300) {
            failed(error);
            return;
        }
        // 处理一些拦截异常情况
//        return;
        
        // 成功的情况
        succeed(resp);
    }];
}

/// 请求任务（记录每个请求的Header中服务器响应时间戳）
+(void)requstManagerWithRequest:(NSURLRequest *)request completionHandler:(RequstTaskCompletionBlock)completionHandler{
    NSURLSessionDataTask *task = [[SYRequestManager shareManager].session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 获取HTTP Header
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
            NSDictionary *allHeaders = resp.allHeaderFields;
            NSString *dateServer = [allHeaders objectForKey:@"Date"];
            if (dateServer.length>0) {
                // 记录服务器时间
                NSDate *inputDate = [NSDate dateFromInternetDateTimeString:dateServer formatHint:DateFormatHintRFC822];
                if (inputDate) {
                    [NSDate saveServerTime:inputDate];
                }
            }
            
            completionHandler(data,response,error);
        });
    }];
    [task resume];
}


-(NSURLSessionConfiguration *)configuration{
    if(!_configuration){
        _configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _configuration.timeoutIntervalForRequest = ApiTimeOut;
        _configuration.timeoutIntervalForResource = ApiTimeOut;
    }
    return _configuration;
}
-(NSURLSession *)session{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:self.configuration];
    }
    return _session;
}






// 生成列表本地假数据
+(void)loadAllData{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i<40; i++) {
        SYDataModel *model = [[SYDataModel alloc] init];
        double currentLocalTimeStamp = [[NSDate date] timeIntervalSince1970];
        
        // 随机小时
        currentLocalTimeStamp = currentLocalTimeStamp+[SYRequestManager getRandomNum:24]*3600;
        // 随机分
        currentLocalTimeStamp = currentLocalTimeStamp+[SYRequestManager getRandomNum:60]*60;
        // 随机秒
        currentLocalTimeStamp = currentLocalTimeStamp+[SYRequestManager getRandomNum:60];
        
        model.EndTime = currentLocalTimeStamp*1000;
        [array addObject:model];
    }
    
    [SYRequestManager shareManager].alertModel = array.firstObject;
    [SYRequestManager shareManager].listArray  = array;
    [SYRequestManager shareManager].cycleArray  = array;
}

/// 生成随机数
+(int)getRandomNum:(int)num{
    int result = arc4random() % num;
    return result;
}
@end
