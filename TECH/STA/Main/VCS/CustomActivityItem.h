//
//  CustomActivityItem.h
//  STA
//
//  Created by admin on 2024/12/9.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomActivityItem : NSObject <UIActivityItemSource>

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) NSString *fileName;

@end

NS_ASSUME_NONNULL_END
