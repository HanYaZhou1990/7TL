//
//  HYZBarCoderVC.h
//  STA
//
//  Created by admin on 2024/7/7.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/** 二维码条形码统一扫描器*/
@interface HYZBarCoderVC : BaseViewController

@property (nonatomic, weak) IBOutlet UIView *previewV;

@property (nonatomic, copy) void (^screenSuccess) (NSString *codeString);

@end

NS_ASSUME_NONNULL_END
