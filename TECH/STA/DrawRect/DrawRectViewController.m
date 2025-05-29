//
//  DrawRectViewController.m
//  EPlus
//
//  Created by 韩亚周 on 17/5/10.
//  Copyright © 2017年 韩亚周. All rights reserved.
//

#import "DrawRectViewController.h"
#import "DashedBorderView.h"

@interface DrawRectViewController ()

/*!手绘板*/
@property (strong, nonatomic) IBOutlet DashedBorderView *subBgView;

@end

@implementation DrawRectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
    UIButton *navigationBackgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    navigationBackgroundButton.backgroundColor = Color(@"64CCDC");
    navigationBackgroundButton.frame = CGRectMake(0, 0, Main_Screen_Width, 64.0f);
    [self.view addSubview:navigationBackgroundButton];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor = Color(@"64CCDC");
    [backButton setImage:[UIImage imageNamed:@"navbtnleftarrow.png"] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 20.0f, 88.0f, 44.0f);
    backButton.contentEdgeInsets = UIEdgeInsetsMake(10, 12, 10, 52.0f);
    
    __weak DrawRectViewController *ws = self;
    [backButton addActionHandler:^(UIButton *sender) {
        [ws.navigationController popViewControllerAnimated:YES];
    }];
    [navigationBackgroundButton addSubview:backButton];
    
    _resignButton.layer.borderColor = Color(@"8C8C8C").CGColor;
    _SaveButton.layer.borderColor = Color(@"8C8C8C").CGColor;
    _resignButton.layer.borderWidth = 0.44f;
    _SaveButton.layer.borderWidth = 0.44f;
     */
    
    WS(ws);
    [_resignButton addActionHandler:^(UIButton *sender) {
       /*重签*/
        [ws.signatureView clearSignature];
    }];
    [_SaveButton addActionHandler:^(UIButton *sender) {
        /*保存*/
        if (ws.signatureView.isAlreadySignture) {
            UIImage *image = [ws.signatureView getSignatureImage];
            [ws updataImage:image];
        } else {
            [MBProgressHUD showError:@"Invalid signature"];
        }
    }];
    
}

- (IBAction)clsPage:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updataImage:(UIImage *)image {
    [MBProgressHUD showMessage:@"Loading..."];
    __weak DrawRectViewController *ws = self;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 忽略 SSL 认证
    //manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //manager.securityPolicy.allowInvalidCertificates = YES; // 允许无效证书
    //manager.securityPolicy.validatesDomainName = NO; // 不验证域名
    
    manager.responseSerializer.acceptableContentTypes = nil;
    [manager POST:[NSString stringWithFormat:@"%@phone/fileupload.action",BASE_URL]
       parameters:@{}
          headers:@{}
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *fileName = [NSString stringWithFormat:@"%@_header.png",[formatter stringFromDate:[NSDate date]]];
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.5)
                                    name:@"file"
                                fileName:fileName
                                mimeType:@"image/png"];
    }
         progress:^(NSProgress * _Nonnull uploadProgress) {
        
    }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUD];
        if ([responseObject[@"ret"] boolValue]) {
            ws.saveSuccess(responseObject[@"filepath"]);
            [ws.signatureView clearSignature];
            [ws.navigationController popViewControllerAnimated:YES];
        } else {
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"Save failed"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
