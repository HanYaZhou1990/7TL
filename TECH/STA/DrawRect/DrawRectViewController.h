//
//  DrawRectViewController.h
//  EPlus
//
//  Created by 韩亚周 on 17/5/10.
//  Copyright © 2017年 韩亚周. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignatureView.h"
#import "UIButton+block.h"
#import "AFNetworking.h"
#import "YYHelper.h"
#import "MBProgressHUD+YY.h"

/*!签名页面*/

@interface DrawRectViewController : UIViewController
/*!手绘板*/
@property (strong, nonatomic) IBOutlet SignatureView *signatureView;
/*!重签按钮*/
@property (strong, nonatomic) IBOutlet UIButton *resignButton;
/*!保存按钮*/
@property (strong, nonatomic) IBOutlet UIButton *SaveButton;


@property (nonatomic, copy ) void (^saveSuccess) (NSString *pathString);

@end
