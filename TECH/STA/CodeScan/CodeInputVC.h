//
//  CodeInputVC.h
//  STA
//
//  Created by admin on 2024/7/11.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/** 条码、二维码输入*/
@interface CodeInputVC : BaseViewController

@property (nonatomic, copy) void (^addcode) (NSString *codeString);

@end

NS_ASSUME_NONNULL_END
