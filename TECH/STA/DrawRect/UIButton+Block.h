//
//  UIButton+Block.h
//  IOS-Categories
//
//  Created by Jakey on 14/12/30.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TouchedBlock)(UIButton *sender);

@interface UIButton (Block)

-(void)addActionHandler:(TouchedBlock)touchHandler;

@end
