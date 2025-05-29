//
//  SignatureView.h
//  WeiDai_Native
//
//  Created by AFCA on 2017/2/24.
//  Copyright © 2017年 x9bank. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCREEN_HEIGHT  [[UIScreen mainScreen] bounds].size.height
#define IS_IPHONE_6_PLUS        SCREEN_HEIGHT > 667

@interface SignatureView : UIView
//获取图片
- (UIImage *)getSignatureImage;
//清除画板
- (void)clearSignature;
//是否已经签名
@property (nonatomic, assign) BOOL isAlreadySignture;

@end
