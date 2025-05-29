//
//  HYZScanVC.h
//  iBox
//
//  Created by 韩亚周 on 2022/2/20.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYZScanVC : BaseViewController

@property (nonatomic, strong) IBOutlet UIView *scanView;

@property (nonatomic, copy) void (^screenSuccess) (NSString *codeString);

@end

NS_ASSUME_NONNULL_END
