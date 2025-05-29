//
//  CustomActivityItem.m
//  STA
//
//  Created by admin on 2024/12/9.
//

#import "CustomActivityItem.h"

@implementation CustomActivityItem

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return self.fileURL;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(UIActivityType)activityType {
    return self.fileURL;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(UIActivityType)activityType {
    return self.fileName;  // 设置文件名
}


@end
