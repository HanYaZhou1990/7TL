//
//  LoginViewController.m
//  TECH
//
//  Created by 韩亚周 on 2021/6/22.
//

#import "LoginViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "HYZScanVC.h"
#import "SceneDelegate.h"
#import "HYZBarCoderVC.h"
#import <ScanKitFrameWork/HmsDefaultScanViewController.h>
#import <ScanKitFrameWork/HmsCustomScanViewController.h>

@interface LoginViewController () <UITextFieldDelegate, DefaultScanDelegate>

/*!账号录入*/
@property (nonatomic, weak) IBOutlet UITextField *usernameTf;
/*!密码录入*/
@property (nonatomic, weak) IBOutlet UITextField *passwordTf;
/*!账号底部线*/
@property (nonatomic, weak) IBOutlet UIView *usernameLine;
/*!密码底部线*/
@property (nonatomic, weak) IBOutlet UIView *passwordLine;

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //清空浏览器缓存
    [self clearCookies];
    [self setShouldNavigationBarHidden:YES];
}

- (void)clearCookies{
    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
        for (WKWebsiteDataRecord *record  in records) {
            //清空7techsg的缓存
            if ([record.displayName containsString:@"7techsg"]) {
                [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                          forDataRecords:@[record]
                                                       completionHandler:^{
                    //NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                }];
            }
        }
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _parameters = [[LoginModel alloc] init];
    
    _usernameTf.text = (_parameters.username && _parameters.username.length > 0) ? _parameters.username : @"";
    _passwordTf.text = (_parameters.password && _parameters.password.length > 0) ? _parameters.password : @"";
    //_usernameTf.text = @"Zhouwei@7tech.sg";
    //_passwordTf.text = @"Ir0nD0g2@yi";
    //_usernameTf.text = @"ctcco";
    //_passwordTf.text = @"1qazxsw2";
    //_usernameTf.text = @"admin";
    //_passwordTf.text = @"piglet529"
    //_usernameTf.text = @"liu";
    //_passwordTf.text = @"111111";
    WS(ws);
    [_usernameTf.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"_usernameTf:%@",x);
        if (x.length) {
            ws.usernameTf.text = x;
        } else {
            ws.usernameTf.text = @"";
        }
        ws.parameters.username = ws.usernameTf.text;
    }];
    [_passwordTf.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"_passwordTf:%@",x);
        if (x.length) {
            ws.passwordTf.text = x;
        } else {
            
        }
        ws.parameters.password = ws.passwordTf.text;
    }];
}

/*!登录*/
- (IBAction)lg:(UIButton *)sender {
    
//    HYZScanVC *scanVC = [HYZScanVC new];
//    scanVC.screenSuccess = ^(NSString *codeString){
//        NSString *jsStr = [NSString stringWithFormat:@"tobackbarcode('%@')", codeString];
//        NSLog(@"错误:%@", jsStr);
//    };
//    [self.navigationController pushViewController:scanVC animated:YES];
//    return;
    
    
//    HYZBarCoderVC *scanVC = [HYZBarCoderVC new];
//    scanVC.screenSuccess = ^(NSString *codeString){
//        NSString *jsStr = [NSString stringWithFormat:@"tobackbarcode('%@')", codeString];
//        NSLog(@"扫码结果%@",jsStr);
//    };
//    [self.navigationController pushViewController:scanVC animated:YES];
//    return;
    
//    
//    // 初始化HmsDefaultScanViewController，实现代理
//    HmsDefaultScanViewController *hmsDefaultScanViewController = [[HmsDefaultScanViewController alloc] init];
//    hmsDefaultScanViewController.defaultScanDelegate = self;
//    [self.view addSubview:hmsDefaultScanViewController.view];
//    [self addChildViewController:hmsDefaultScanViewController];
//    [self didMoveToParentViewController:hmsDefaultScanViewController];
//    //[self.navigationController pushViewController:hmsDefaultScanViewController animated:YES];
//    
//    
//    HmsCustomScanViewController *customVC = [HmsCustomScanViewController new];
//    customVC.customizedScanDelegate = self;
//    customVC.backButtonHidden = YES;
//    customVC.continuouslyScan = YES;
//    [self.view addSubview:customVC.view];
//    [self addChildViewController:customVC];
//    [self didMoveToParentViewController:customVC];
//    
//    return;
    
    
    [self.view endEditing:YES];
    if (!_parameters.username || _parameters.username.length == 0) {
        [MBProgressHUD showError:@"Enter user name"];
        return ;
    }
    
    if (!_parameters.password || _parameters.password.length == 0) {
        [MBProgressHUD showError:@"Enter password"];
        return ;
    }
    //https://www.7techsg.com/phone/applogin.action
    WS(ws);
    [MBProgressHUD showMessage:@"loading..."];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 忽略 SSL 认证
    //manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //manager.securityPolicy.allowInvalidCertificates = YES; // 允许无效证书
    //manager.securityPolicy.validatesDomainName = NO; // 不验证域名
    
    
    manager.responseSerializer.acceptableContentTypes = nil;
    [manager POST:[NSString stringWithFormat:@"%@phone/applogin.action",BASE_URL]
       parameters:@{@"user.usercode":_parameters.username,@"user.password":_parameters.password,@"clienttype":@(_parameters.clienttype)}
          headers:@{}
         progress:^(NSProgress * _Nonnull uploadProgress) {
        
    }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"登录成功:%@",responseObject);
        [MBProgressHUD hideHUD];
        LoginModel *responseModel = [LoginModel yy_modelWithDictionary:responseObject];
        if (responseModel.ret == 1) {
            responseModel.username = ws.parameters.username;
            responseModel.password = ws.parameters.password;
            responseModel.clienttype = ws.parameters.clienttype;
            responseModel.url = [NSString stringWithFormat:@"%@/",responseModel.url];
            
            // 请求成功时获取服务器返回的 Cookie
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:httpResponse.allHeaderFields forURL:httpResponse.URL];
            
            NSLog(@"HTTP Response: %@", httpResponse);
            NSLog(@"Cookies: %@", cookies);
            
            for (NSHTTPCookie *cookie in cookies) {
                NSLog(@"Cookie: %@=%@", cookie.name, cookie.value);
                
                if ([cookie.name isEqualToString:@"usercode"]) {
                    responseModel.usercode = cookie.value;
                    NSLog(@"Found usercode: %@", responseModel.usercode);
                }
                
                if ([cookie.name isEqualToString:@"JSESSIONID"]) {
                    responseModel.JSESSIONID = cookie.value;
                    NSLog(@"Found JSESSIONID: %@", responseModel.JSESSIONID);
                }
            }
            
            if (responseModel.usercode.length == 0) {
                //[MBProgressHUD showError:@"从Cookie未读取到usercode"];
                //return;
            }
            
//            if (responseModel.JSESSIONID.length == 0) {
//                [MBProgressHUD showError:@"从Cookie未读取到JSESSIONID"];
//                return;
//            }
            
            // 保存账号密码
            [[NSUserDefaults standardUserDefaults] setObject:@{@"user.usercode":responseModel.username,@"user.password":responseModel.password,@"token":responseModel.token,@"url":responseModel.url,@"usercode":responseModel.usercode,@"JSESSIONID":responseModel.JSESSIONID} forKey:@"STAUP"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            NSDictionary *firstDic = [NSDictionary dictionaryWithDictionary:YYD(@"FST")];
            LoginModel *firstModel = [LoginModel yy_modelWithDictionary:firstDic];
            if (firstModel.first && [firstModel.first isEqualToString:@""]) {
                [[NSUserDefaults standardUserDefaults] setObject:@{@"first":@"first"} forKey:@"FST"];
                [[NSUserDefaults standardUserDefaults] synchronize];

            } else {
                
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.34 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                MainWebViewController *webVC = [[MainWebViewController alloc] init];
                SceneDelegate *sceneDelegate = (SceneDelegate *)[[[UIApplication sharedApplication] connectedScenes] anyObject].delegate;;
                //webVC = (MainWebViewController *)[ws getCurrentViewController];
                webVC = sceneDelegate.webVC;
                webVC.dataModel = responseModel;
                if (ws.lgSuccess) {
                    ws.lgSuccess(ws, responseModel, YES);
                    [webVC refreshWeb];
                    [ws dismissViewControllerAnimated:YES completion:^{}];
                } else {
                    [ws.navigationController pushViewController:webVC animated:YES];
                }
            });
        } else {
            [MBProgressHUD showError:responseModel.msg];
        }
    }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"login fialed"];
    }];
}

#pragma mark -
#pragma mark UITextFieldDelegate -
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        _usernameLine.backgroundColor = [UIColor colorNamed:@"125A96"];
        _passwordLine.backgroundColor = [UIColor colorNamed:@"C8E2F8"];
    } else {
        _usernameLine.backgroundColor = [UIColor colorNamed:@"C8E2F8"];
        _passwordLine.backgroundColor = [UIColor colorNamed:@"125A96"];
    }
}

- (void)defaultScanDelegateForDicResult:(NSDictionary *)resultDic {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 在主线程内处理数据
    });
    NSLog(@"扫码结果%@",resultDic);
}

- (void)customizedScanDelegateForResult:(NSDictionary *)resultDic {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 在主线程内处理数据
    });
    NSLog(@"扫码结果%@",resultDic);
}

@end
