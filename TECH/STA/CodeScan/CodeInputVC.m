//
//  CodeInputVC.m
//  STA
//
//  Created by admin on 2024/7/11.
//

#import "CodeInputVC.h"

@interface CodeInputVC ()

@property (nonatomic, weak) IBOutlet UITextField *txtInput;

@end

@implementation CodeInputVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)addTouch:(UIButton *)sender {
    [self.view endEditing:YES];
    if (self.txtInput.text && self.txtInput.text.length > 0) {
        if (self.addcode) {
            self.addcode(self.txtInput.text);
        }
    } else {
        [MBProgressHUD showError:@"Plaease enter Device ID"];
    }
    
}

@end
