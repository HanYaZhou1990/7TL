//
//  HYZScanVC.m
//  iBox
//
//  Created by 韩亚周 on 2022/2/20.
//

#import "HYZScanVC.h"
#import "LBXScanZXingViewController.h"
#import "StyleDIY.h"

@interface HYZScanVC ()

@property (nonatomic, strong)LBXScanZXingViewController *zxBarScan;
@property (nonatomic, strong)LBXScanZXingViewController *zxScan;

@end

@implementation HYZScanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.title = @"Qcode Scan";
    
    self.zxBarScan = [LBXScanZXingViewController new];
    self.zxBarScan.style = [StyleDIY notSquare];
    self.zxBarScan.view.frame = self.scanView.bounds;
    
    self.zxScan = [LBXScanZXingViewController new];
    self.zxScan.style = [StyleDIY OnStyle];
    
    [self addChildViewController:self.zxBarScan];
    [self addChildViewController:self.zxScan];
    
    [self.scanView addSubview:self.zxBarScan.view];
}

- (IBAction)switchVC:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self replaceController:self.zxBarScan newController:self.zxScan];
    } else {
        [self replaceController:self.zxScan newController:self.zxBarScan];
    }
}

/*切换各个标签内容*/
- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)nowController{
    nowController.view.frame = self.scanView.bounds;
    [oldController willMoveToParentViewController:nil];
    [self transitionFromViewController:oldController toViewController:nowController duration:0.3 options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
        if (finished) {
            [nowController didMoveToParentViewController:self];
        }else{
            
        }
    }];
}

@end
