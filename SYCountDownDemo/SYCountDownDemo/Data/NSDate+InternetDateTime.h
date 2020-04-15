// 服务器时间戳

#import <Foundation/Foundation.h>

#define kLastSaveServerTimeStamp @"LastSaveServerTimeStamp"
#define kLastSaveLocalTimeStamp @"LastSaveLocalTimeStamp"

// Formatting hints
typedef enum {
    DateFormatHintNone,
    DateFormatHintRFC822,
    DateFormatHintRFC3339
} DateFormatHint;

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (InternetDateTime)
// Get date from RFC3339 or RFC822 string
// - A format/specification hint can be used to speed up,
//   otherwise both will be attempted in order to get a date
+ (NSDate *)dateFromInternetDateTimeString:(NSString *)dateString
                                formatHint:(DateFormatHint)hint;

// Get date from a string using a specific date specification
+ (NSDate *)dateFromRFC3339String:(NSString *)dateString;
+ (NSDate *)dateFromRFC822String:(NSString *)dateString;

/// 获取服务器当前时间戳（精确到毫秒）
+ (double)serverCurrentTimeStamp;
/// 获取服务器当前时间
+ (NSDate *)serverCurrentDate;
/// 获取服务器时间并保持至本地
+(void)saveServerTime:(NSDate *)serverTimeStamp;
//+(NSString *)serverCurrentGMT;

/// 按时间戳获得该天零点对应的时间戳
+(double)getZeroWithTimeInterverl:(NSTimeInterval)timeInterval;
/// 判断是不是新的一天
+(BOOL)happyNewDay;

@end

NS_ASSUME_NONNULL_END
