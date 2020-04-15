
//

#ifndef MacrosDefinition_h
#define MacrosDefinition_h


#define statusBarHidden [UIApplication sharedApplication].isStatusBarHidden

#define kStatusBarMin_Width MIN(CGRectGetWidth([UIApplication sharedApplication].statusBarFrame),CGRectGetHeight([UIApplication sharedApplication].statusBarFrame))

#define statusBarH (statusBarHidden ? 0.0f : kStatusBarMin_Width)

#define kNavBarHeight  (44.0f)
#define kNavWithStatusBarH (statusBarH+kNavBarHeight)

#define RGBA(r,g,b,al) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(al)]
#define RGB(A,B,C) [UIColor colorWithRed:((float)A)/255.0 green:((float)B)/255.0 blue:((float)C)/255.0 alpha:1.0]

#endif /* MacrosDefinition_h */
