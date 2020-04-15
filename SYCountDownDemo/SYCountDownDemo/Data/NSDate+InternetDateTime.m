
#import "NSDate+InternetDateTime.h"

// Always keep the formatter around as they're expensive to instantiate
static NSDateFormatter *_internetDateTimeFormatter = nil;

// Good info on internet dates here:

@implementation NSDate (InternetDateTime)

// Instantiate single date formatter
+ (NSDateFormatter *)internetDateTimeFormatter {
    @synchronized(self) {
        if (!_internetDateTimeFormatter) {
            NSLocale *en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            _internetDateTimeFormatter = [[NSDateFormatter alloc] init];
            [_internetDateTimeFormatter setLocale:en_US_POSIX];
            [_internetDateTimeFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        }
    }
    return _internetDateTimeFormatter;
}

// Get a date from a string - hint can be used to speed up
+ (NSDate *)dateFromInternetDateTimeString:(NSString *)dateString formatHint:(DateFormatHint)hint {
    // Keep dateString around a while (for thread-safety)
    NSDate *date = nil;
    if (dateString) {
        if (hint != DateFormatHintRFC3339) {
            // Try RFC822 first
            date = [NSDate dateFromRFC822String:dateString];
            if (!date) date = [NSDate dateFromRFC3339String:dateString];
        } else {
            // Try RFC3339 first
            date = [NSDate dateFromRFC3339String:dateString];
            if (!date) date = [NSDate dateFromRFC822String:dateString];
        }
    }
    // Finished with date string
    return date;
}


+ (NSDate *)dateFromRFC822String:(NSString *)dateString {
    // Keep dateString around a while (for thread-safety)
    NSDate *date = nil;
    if (dateString) {
        NSDateFormatter *dateFormatter = [NSDate internetDateTimeFormatter];
        @synchronized(dateFormatter) {
            
            // Process
            NSString *RFC822String = [[NSString stringWithString:dateString] uppercaseString];
            if ([RFC822String rangeOfString:@","].location != NSNotFound) {
                if (!date) { // Sun, 19 May 2002 15:21:36 GMT
                    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzz"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // Sun, 19 May 2002 15:21 GMT
                    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm zzz"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // Sun, 19 May 2002 15:21:36
                    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // Sun, 19 May 2002 15:21
                    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
            } else {
                if (!date) { // 19 May 2002 15:21:36 GMT
                    [dateFormatter setDateFormat:@"d MMM yyyy HH:mm:ss zzz"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // 19 May 2002 15:21 GMT
                    [dateFormatter setDateFormat:@"d MMM yyyy HH:mm zzz"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // 19 May 2002 15:21:36
                    [dateFormatter setDateFormat:@"d MMM yyyy HH:mm:ss"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
                if (!date) { // 19 May 2002 15:21
                    [dateFormatter setDateFormat:@"d MMM yyyy HH:mm"];
                    date = [dateFormatter dateFromString:RFC822String];
                }
            }
            if (!date) NSLog(@"Could not parse RFC822 date: \"%@\" Possible invalid format.", dateString);
            
        }
    }
    // Finished with date string
    return date;
}


+ (NSDate *)dateFromRFC3339String:(NSString *)dateString {
    // Keep dateString around a while (for thread-safety)
    NSDate *date = nil;
    if (dateString) {
        NSDateFormatter *dateFormatter = [NSDate internetDateTimeFormatter];
        @synchronized(dateFormatter) {
            
            // Process date
            NSString *RFC3339String = [[NSString stringWithString:dateString] uppercaseString];
            RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@"Z" withString:@"-0000"];
            // Remove colon in timezone as it breaks NSDateFormatter in iOS 4+.
            
            if (RFC3339String.length > 20) {
                RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@":"
                                                                         withString:@""
                                                                            options:0
                                                                              range:NSMakeRange(20, RFC3339String.length-20)];
            }
            if (!date) { // 1996-12-19T16:39:57-0800
                [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"];
                date = [dateFormatter dateFromString:RFC3339String];
            }
            if (!date) { // 1937-01-01T12:00:27.87+0020
                [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"];
                date = [dateFormatter dateFromString:RFC3339String];
            }
            if (!date) { // 1937-01-01T12:00:27
                [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
                date = [dateFormatter dateFromString:RFC3339String];
            }
            if (!date) NSLog(@"Could not parse RFC3339 date: \"%@\" Possible invalid format.", dateString);
            
        }
    }
    // Finished with date string
    return date;
}

// 服务器当前时间戳（精确到毫秒）
+ (double)serverCurrentTimeStamp{
    // 最后保存的服务器时间戳
    double lastSaveServerTimeStamp = [[NSUserDefaults standardUserDefaults] doubleForKey:kLastSaveServerTimeStamp];
    // 最后保存服务器时间戳时的本地时间戳
    double lastSaveLocalTimeStamp = [[NSUserDefaults standardUserDefaults] doubleForKey:kLastSaveLocalTimeStamp];
    // 当前本地时间戳
    double currentLocalTimeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    
    if (lastSaveLocalTimeStamp != 0 || lastSaveServerTimeStamp != 0) {
        currentLocalTimeStamp = lastSaveServerTimeStamp + (currentLocalTimeStamp - lastSaveLocalTimeStamp);
    }
    
    return currentLocalTimeStamp;
}
/// 服务器当前时间
+ (NSDate *)serverCurrentDate{
    double serverTimeStamp = [NSDate serverCurrentTimeStamp] / 1000;
    NSDate *serverDateZone = [NSDate dateWithTimeIntervalSince1970:(serverTimeStamp)];
    return serverDateZone;
}
/// 获取服务器时间并保持至本地
+(void)saveServerTime:(NSDate *)serverTimeStamp{
    NSInteger interval = [serverTimeStamp timeIntervalSince1970]*1000;
    // 服务器
    [[NSUserDefaults standardUserDefaults] setDouble:interval forKey:kLastSaveServerTimeStamp];
    // 本地
    double currentLocalTimeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    [[NSUserDefaults standardUserDefaults] setDouble:currentLocalTimeStamp forKey:kLastSaveLocalTimeStamp];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/// 按时间戳获得该天零点对应的时间戳
+(double)getZeroWithTimeInterverl:(NSTimeInterval)timeInterval{
    NSDate *originalDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFomater = [[NSDateFormatter alloc]init];
    dateFomater.dateFormat = @"yyyy年MM月dd日";
    NSString *original = [dateFomater stringFromDate:originalDate];
    NSDate *ZeroDate = [dateFomater dateFromString:original];
    return [ZeroDate timeIntervalSince1970];
}

/// 判断是不是新的一天
+(BOOL)happyNewDay{
    // 当前服务器时间戳
    NSInteger serverTime = floor([NSDate serverCurrentTimeStamp]);// 13位时间戳 向下取整
    // 当前服务器时间该天零点(时间戳减去)
    NSInteger serverZeroTime = [NSDate getZeroWithTimeInterverl:serverTime/1000];
    // 上次存储时间戳
    NSInteger lastTime = [[[NSUserDefaults standardUserDefaults] objectForKey:@"kLastNewDayServerTimeStamp"] integerValue];
    if (lastTime==0) {
        lastTime = serverTime;
    }
    // 上次存时间该天零点
    NSInteger lastZeroTime = [NSDate getZeroWithTimeInterverl:lastTime/1000];
    [[NSUserDefaults standardUserDefaults] setObject:@(serverTime) forKey:@"kLastNewDayServerTimeStamp"];
    NSLog(@"happyNewDay-new:==%@  last:==%@",@(serverZeroTime),@(lastZeroTime));
    // 超过一天
    return (serverZeroTime>lastZeroTime);
}


    
@end
