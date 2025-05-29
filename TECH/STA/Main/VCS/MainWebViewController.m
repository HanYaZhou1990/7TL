//
//  MainWebViewController.m
//  TECH
//
//  Created by 韩亚周 on 2021/6/23.
//

#import "MainWebViewController.h"
#import "WKMessageHandle.h"
#import "LoginViewController.h"
#import "YYTouchIDManager.h"
#import <CoreLocation/CoreLocation.h>
#import "YYTakePhotosViewController.h"
#import <SDWebImage/SDWebImage.h>
#import "VQPNotchScreenUtil.h"
#import "DrawRectViewController.h"
#import "HYZScanVC.h"
#import "HYZBarCoderVC.h"
#import "CustomActivityItem.h"
//#import <VLCKit/VLCKit.h>
//#import <MobileVLCKit/MobileVLCKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VLOPlayerVC.h"

//@interface MainWebViewController () <CLLocationManagerDelegate, VLCMediaPlayerDelegate>
@interface MainWebViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) LoginModel *userModel;

//@property (nonatomic, strong) VLCMediaPlayer *mediaPlayer;
//@property (nonatomic, strong) UIView *videoView;

@end

@implementation MainWebViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setShouldNavigationBarHidden:YES];
}

- (void)refreshWeb {
    NSDictionary *biologyDic = [NSDictionary dictionaryWithDictionary:YYD(@"Biology")];
    LoginModel *biologyModel = [LoginModel yy_modelWithDictionary:biologyDic];
    NSString *urlStr = [NSString stringWithFormat:@"%@admin/login.action?user.usercode=%@&user.password=%@&token=%@&clienttype=%ld",self.dataModel.url, _dataModel.username, _dataModel.password, _dataModel.token,_dataModel.clienttype];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //urlStr = [urlStr stringByReplacingOccurrencesOfString:@"cctv.7" withString:@"cctv2.7"];

    NSLog(@"%@",urlStr);
    
    
    if (biologyModel.biology && [biologyModel.biology isEqualToString:@"open"]) {
        WS(ws);
        NSString *bsUrl = (self.userModel.url && self.userModel.url.length>0) ? self.userModel.url : BASE_URL;
        //bsUrl = [bsUrl stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
        NSString *urlStr = [NSString stringWithFormat:@"%@admin/login.action?user.usercode=%@&user.password=%@&token=%@&clienttype=%ld",bsUrl, _dataModel.username, _dataModel.password,  _dataModel.token,_dataModel.clienttype];
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        //urlStr = [urlStr stringByReplacingOccurrencesOfString:@"cctv.7" withString:@"cctv2.7"];

        NSLog(@"%@",urlStr);
        [[YYTouchIDManager shareManager] openTouchId:NO block:^(BOOL isSuccess) {
            if (isSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ws.view.backgroundColor = [UIColor colorNamed:@"3B404D"];
                    NSMutableURLRequest *rqst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
                    // 创建 usercode Cookie
                    NSHTTPCookie *usercodeCookie = [NSHTTPCookie cookieWithProperties:@{
                        NSHTTPCookieName: @"usercode",
                        NSHTTPCookieValue: ws.dataModel.usercode,
                        NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
                        NSHTTPCookiePath: @"/",
                        NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 设置过期时间为1月
                    }];
                    
                    NSHTTPCookie *tokenCookie = [NSHTTPCookie cookieWithProperties:@{
                        NSHTTPCookieName: @"tempcode",
                        NSHTTPCookieValue: ws.dataModel.token,
                        NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
                        NSHTTPCookiePath: @"/",
                        NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 1 month expiration
                    }];
                    
                    // 设置 Cookie 到 WKWebView 的 httpCookieStore
                    [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
                        [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:tokenCookie completionHandler:^{
                            // 加载请求
                            [ws.webView loadRequest:rqst];
                        }];
                    }];
                });
            } else {
                [[YYTouchIDManager shareManager] openTouchId:NO block:^(BOOL isSuccess) {
                    if (isSuccess) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ws.view.backgroundColor = [UIColor colorNamed:@"3B404D"];
                            NSMutableURLRequest *rqst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
                            //[rqst addValue:[NSString stringWithFormat:@"usercode=%@",ws.dataModel.usercode] forHTTPHeaderField:@"Cookie"];
                            //[ws.webView loadRequest:rqst];
                            
                            // 创建 usercode Cookie
                            NSHTTPCookie *usercodeCookie = [NSHTTPCookie cookieWithProperties:@{
                                NSHTTPCookieName: @"usercode",
                                NSHTTPCookieValue: ws.dataModel.usercode,
                                NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
                                NSHTTPCookiePath: @"/",
                                NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 设置过期时间为1月
                            }];
                            
                            NSHTTPCookie *tokenCookie = [NSHTTPCookie cookieWithProperties:@{
                                NSHTTPCookieName: @"tempcode",
                                NSHTTPCookieValue: ws.dataModel.token,
                                NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
                                NSHTTPCookiePath: @"/",
                                NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 1 month expiration
                            }];
                            
                            // 设置 Cookie 到 WKWebView 的 httpCookieStore
                            [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
                                [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:tokenCookie completionHandler:^{
                                    // 加载请求
                                    [ws.webView loadRequest:rqst];
                                }];
                            }];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD showError:@"Verification failed"];
                            NSString *jsStr = [NSString stringWithFormat:@"failLocation()"];
                            [ws.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                                if (error) {
                                    NSLog(@"初次加载错误:%@", error.localizedDescription);
                                }
                            }];
                        });
                    }
                }];
            }
        }];
    } else {
        //[MBProgressHUD showMessage:self.dataModel.usercode];
        NSMutableURLRequest *rqst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
        //[rqst addValue:[NSString stringWithFormat:@"usercode=%@",self.dataModel.usercode] forHTTPHeaderField:@"Cookie"];
        //[self.webView loadRequest:rqst];
        // 创建 usercode Cookie
        NSHTTPCookie *usercodeCookie = [NSHTTPCookie cookieWithProperties:@{
            NSHTTPCookieName: @"usercode",
            NSHTTPCookieValue: self.dataModel.usercode,
            NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
            NSHTTPCookiePath: @"/",
            NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 设置过期时间为1月
        }];
        
        NSHTTPCookie *tokenCookie = [NSHTTPCookie cookieWithProperties:@{
            NSHTTPCookieName: @"tempcode",
            NSHTTPCookieValue: self.dataModel.token,
            NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
            NSHTTPCookiePath: @"/",
            NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 1 month expiration
        }];
        
        WS(ws);
        // 设置 Cookie 到 WKWebView 的 httpCookieStore
        [self.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
            [self.webView.configuration.websiteDataStore.httpCookieStore setCookie:tokenCookie completionHandler:^{
                // 加载请求
                [ws.webView loadRequest:rqst];
            }];
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.dataModel) {
        self.dataModel = [LoginModel new];
    }
    
    NSLog(@"最新usercode %@\n\n token: %@ \n\n", self.dataModel.usercode,self.dataModel.token);
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectZero];
    topView.backgroundColor = [UIColor colorNamed:@"FFFFFF"];
    [self.view addSubview:topView];
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[topView]|"
                               options:1.0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(topView)]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[topView(64)]"]
                               options:1.0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(topView)]];
    
    NSDictionary *firstDic = [NSDictionary dictionaryWithDictionary:YYD(@"FST")];
    LoginModel *firstModel = [LoginModel yy_modelWithDictionary:firstDic];
    if (firstModel.first && [firstModel.first isEqualToString:@"first"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@{@"biology":@"close"} forKey:@"Biology"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        
    }
    self.view.backgroundColor = [UIColor colorNamed:@"FFFFFF"];
    NSDictionary *biologyDic = [NSDictionary dictionaryWithDictionary:YYD(@"Biology")];
    LoginModel *biologyModel = [LoginModel yy_modelWithDictionary:biologyDic];
    //[MBProgressHUD showMessage:@"Loading..."];
    //self.userModel.url = [self.userModel.url stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    NSString *urlStr = [NSString stringWithFormat:@"%@admin/login.action?user.usercode=%@&user.password=%@&token=%@&clienttype=%ld",self.dataModel.url,_dataModel.username,_dataModel.password, _dataModel.token,_dataModel.clienttype];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //urlStr = [urlStr stringByReplacingOccurrencesOfString:@"cctv.7" withString:@"cctv2.7"];
    NSLog(@"%@",urlStr);
    
    
    if (biologyModel.biology && [biologyModel.biology isEqualToString:@"open"]) {
        WS(ws);
        NSString *bsUrl = (self.userModel.url && self.userModel.url.length>0) ? self.userModel.url : BASE_URL;
        //bsUrl = [bsUrl stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
        NSString *urlStr = [NSString stringWithFormat:@"%@admin/login.action?user.usercode=%@&user.password=%@&token=%@&clienttype=%ld",bsUrl,_dataModel.username,_dataModel.password,_dataModel.token,_dataModel.clienttype];
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        //urlStr = [urlStr stringByReplacingOccurrencesOfString:@"cctv.7" withString:@"cctv2.7"];
        //urlStr = @"https://cctv2.7tech.sg/admin/login.action?user.usercode=liu&user.password=111111&token=42292afd-2fed-428b-8941-a902f7634c79&clienttype=1";
        
        //urlStr = @"https://test.testswap.top";
        
        NSLog(@"%@",urlStr);
        [[YYTouchIDManager shareManager] openTouchId:NO block:^(BOOL isSuccess) {
            if (isSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ws.view.backgroundColor = [UIColor colorNamed:@"3B404D"];
                    NSMutableURLRequest *rqst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
                    //[rqst addValue:[NSString stringWithFormat:@"usercode=%@",ws.dataModel.usercode] forHTTPHeaderField:@"Cookie"];
                    //[ws.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10]];
                    //[ws.webView loadRequest:rqst];
                    // 创建 usercode Cookie
                    NSHTTPCookie *usercodeCookie = [NSHTTPCookie cookieWithProperties:@{
                        NSHTTPCookieName: @"usercode",
                        NSHTTPCookieValue: ws.dataModel.usercode,
                        NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
                        NSHTTPCookiePath: @"/",
                        NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 设置过期时间为1月
                    }];
                    
                    NSHTTPCookie *tokenCookie = [NSHTTPCookie cookieWithProperties:@{
                        NSHTTPCookieName: @"tempcode",
                        NSHTTPCookieValue: ws.dataModel.token,
                        NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
                        NSHTTPCookiePath: @"/",
                        NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 1 month expiration
                    }];
                    
                    // 设置 Cookie 到 WKWebView 的 httpCookieStore
                    [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
                        [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:tokenCookie completionHandler:^{
                            // 加载请求
                            [ws.webView loadRequest:rqst];
                        }];
                    }];
                    
                    /*
                     // 设置 Cookie 到 WKWebView 的 httpCookieStore
                     [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
                     // 加载请求
                     [ws.webView loadRequest:rqst];
                     }];
                     */
                });
            } else {
                [[YYTouchIDManager shareManager] openTouchId:NO block:^(BOOL isSuccess) {
                    if (isSuccess) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ws.view.backgroundColor = [UIColor colorNamed:@"3B404D"];
                            NSMutableURLRequest *rqst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
                            //[rqst addValue:[NSString stringWithFormat:@"usercode=%@",ws.dataModel.usercode] forHTTPHeaderField:@"Cookie"];
                            //[ws.webView loadRequest:rqst];
                            
                            // 创建 usercode Cookie
                            NSHTTPCookie *usercodeCookie = [NSHTTPCookie cookieWithProperties:@{
                                NSHTTPCookieName: @"usercode",
                                NSHTTPCookieValue: ws.dataModel.usercode,
                                NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
                                NSHTTPCookiePath: @"/",
                                NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 设置过期时间为1月
                            }];
                            
                            NSHTTPCookie *tokenCookie = [NSHTTPCookie cookieWithProperties:@{
                                NSHTTPCookieName: @"tempcode",
                                NSHTTPCookieValue: ws.dataModel.token,
                                NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
                                NSHTTPCookiePath: @"/",
                                NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 1 month expiration
                            }];
                            
                            // 设置 Cookie 到 WKWebView 的 httpCookieStore
                            [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
                                [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:tokenCookie completionHandler:^{
                                    // 加载请求
                                    [ws.webView loadRequest:rqst];
                                }];
                            }];
                            
                            // 设置 Cookie 到 WKWebView 的 httpCookieStore
                            /*[ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
                             // 加载请求
                             [ws.webView loadRequest:rqst];
                             }];
                             */
                            
                            //[ws.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10]];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD showError:@"Verification failed"];
                            NSString *jsStr = [NSString stringWithFormat:@"failLocation()"];
                            [ws.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                                if (error) {
                                    NSLog(@"初次加载错误:%@", error.localizedDescription);
                                }
                            }];
                        });
                    }
                }];
            }
        }];
    } else {
        //[MBProgressHUD showMessage:self.dataModel.usercode];
        NSMutableURLRequest *rqst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
        //[rqst addValue:[NSString stringWithFormat:@"usercode=%@",self.dataModel.usercode] forHTTPHeaderField:@"Cookie"];
        //[self.webView loadRequest:rqst];
        // 创建 usercode Cookie
        NSHTTPCookie *usercodeCookie = [NSHTTPCookie cookieWithProperties:@{
            NSHTTPCookieName: @"usercode",
            NSHTTPCookieValue: self.dataModel.usercode,
            NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
            NSHTTPCookiePath: @"/",
            NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 设置过期时间为1月
        }];
        
        NSHTTPCookie *tokenCookie = [NSHTTPCookie cookieWithProperties:@{
            NSHTTPCookieName: @"tempcode",
            NSHTTPCookieValue: self.dataModel.token,
            NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
            NSHTTPCookiePath: @"/",
            NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 1 month expiration
        }];
        
        WS(ws);
        // 设置 Cookie 到 WKWebView 的 httpCookieStore
        [self.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
            [self.webView.configuration.websiteDataStore.httpCookieStore setCookie:tokenCookie completionHandler:^{
                // 加载请求
                [ws.webView loadRequest:rqst];
            }];
        }];
        
        // 设置 Cookie 到 WKWebView 的 httpCookieStore
        /*[self.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
         // 加载请求
         [self.webView loadRequest:rqst];
         }];
         */
    }
    
//    // 初始化视频视图
//    self.videoView = [[UIView alloc] initWithFrame:self.view.bounds];
//    self.videoView.backgroundColor = [UIColor blackColor];
//    self.videoView.userInteractionEnabled = NO;
//    self.videoView.alpha = 0.8;
//    [self.view addSubview:self.videoView];
//    
//    // 初始化播放器
//    //self.mediaPlayer = [[VLCMediaPlayer alloc] init];
//    self.mediaPlayer = [[VLCMediaPlayer alloc] initWithOptions:@[
//        @"--network-caching=300",    // 全局网络缓存时间（单位：毫秒）
////        @"--rtsp-tcp",               // 强制使用 TCP 传输
////        @"--no-stats",               // 禁用统计信息（可减少性能开销）
////        @"--clock-jitter=0",         // 禁用时间抖动
////        @"--clock-synchro=0",         // 禁用时钟同步
////        @"--subsdec-encoding=GB2312", // 全局设置字幕解码编码
////        @"--network-caching=300",     // 网络缓存时间（可选）
//        //@"--no-verify-ssl=1"
//    ]];
////    self.mediaPlayer.delegate = self;
//    self.mediaPlayer.drawable = self.videoView; // 绑定视频输出

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    WS(ws);
    CLLocation *curLocation = [locations lastObject];
    // 通过location  或得到当前位置的经纬度
    CLLocationCoordinate2D curCoordinate2D = curLocation.coordinate;
    [manager stopUpdatingLocation];//定位成功后停止定位
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:curLocation
                   completionHandler:^(NSArray *placemarks, NSError *error){
        if(!error){
            for (CLPlacemark *place in placemarks) {
                //道路+门牌号 name
                //thoroughfare 道路
                //门牌号 subThoroughfare
                //城市 locality
                // 县区subLocality
                // 县区？（大陆为空）subAdministrativeArea
                // 国家地区country
                NSString *addressStr = [NSString stringWithFormat:@"%@%@%@%@%@",place.subAdministrativeArea ? place.subAdministrativeArea : (place.administrativeArea),place.locality,place.subLocality,place.thoroughfare,place.name];
                NSLog(@"%@",addressStr);
                NSString *jsStr = [NSString stringWithFormat:@"toLocation(%f,%f,'%@')",curCoordinate2D.longitude, curCoordinate2D.latitude, addressStr];
                [ws.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"定位错误:%@", error.localizedDescription);
                    }
                }];
                break;
            }
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
        NSString *jsStr = [NSString stringWithFormat:@"failLocation()"];
        [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"定位失败错误:%@", error.localizedDescription);
            }
        }];
    }
}

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuretion = [[WKWebViewConfiguration alloc] init];
        
        //禁止缓存
        configuretion.websiteDataStore = [WKWebsiteDataStore nonPersistentDataStore];
        
        // 设置偏好设置
        //WKWebViewConfiguration *configuretion = self.webView.configuration;
        configuretion.preferences = [[WKPreferences alloc]init];
        configuretion.preferences.minimumFontSize = 8;
        configuretion.preferences.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
        configuretion.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        configuretion.processPool = [[WKProcessPool alloc] init];
        // 通过js与webview内容交互配置
        configuretion.userContentController = [[WKUserContentController alloc] init];
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        //OC注册供JS调用的方法
        //WKMessageHandle *handle = [[WKMessageHandle alloc] initWithDelegate:self];
        WKMessageHandle *handle = [[WKMessageHandle alloc] init];
        WS(ws);
        handle.scriptMessageHandle = ^(WKUserContentController * _Nonnull userController, WKScriptMessage * _Nonnull message) {
            NSLog(@"回调");
            //SEL selector = NSSelectorFromString(message.name);
            //((void (*)(id, SEL))[ws methodForSelector:selector])(ws, selector);
            if ([message.name isEqualToString:@"playVideo"]) {
                NSDictionary *messageBody = (NSDictionary *)message.body;
                NSString *fileAddress = messageBody[@"body"];
                
                // 调用带参数的方法
                [ws playVideoWithUrl:fileAddress];
            } else if ([message.name isEqualToString:@"playLive"]) {
                NSDictionary *messageBody = (NSDictionary *)message.body;
                NSString *fileAddress = messageBody[@"body"];
                
                // 调用带参数的方法
                [ws playLiveWithUrl:fileAddress];
            } else if ([message.name isEqualToString:@"fileupdate"]) {
                NSDictionary *messageBody = (NSDictionary *)message.body;
                NSString *fileAddress = messageBody[@"body"];
                
                // 调用带参数的方法
                [ws fileupdateWithParams:fileAddress];
            } else if ([message.name isEqualToString:@"popBack"]) {
                NSDictionary *messageBody = (NSDictionary *)message.body;
                NSString *fileAddress = messageBody[@"body"];
                
                // 调用带参数的方法
                [ws popBack:fileAddress];
            } else {
                SEL selector = NSSelectorFromString(message.name);
                if ([ws respondsToSelector:selector]) {
                    ((void (*)(id, SEL))[ws methodForSelector:selector])(ws, selector);
                }
            }
            
        };
        //启用相机拍照
        [configuretion.userContentController addScriptMessageHandler:handle name:@"startCamera"];
        //启动定位
        [configuretion.userContentController addScriptMessageHandler:handle name:@"getLocation"];
        //开启指纹或者人脸
        [configuretion.userContentController addScriptMessageHandler:handle name:@"openBiology"];
        //关闭指纹，或者人脸。
        [configuretion.userContentController addScriptMessageHandler:handle name:@"closeBiology"];
        [configuretion.userContentController addScriptMessageHandler:handle name:@"drawRect"];
        [configuretion.userContentController addScriptMessageHandler:handle name:@"popBack"];
        [configuretion.userContentController addScriptMessageHandler:handle name:@"uploadPic"];
        [configuretion.userContentController addScriptMessageHandler:handle name:@"fileupdate"];
        //扫一扫
        [configuretion.userContentController addScriptMessageHandler:handle name:@"screen"];
        //点播
        [configuretion.userContentController addScriptMessageHandler:handle name:@"playVideo"];
        //直播
        [configuretion.userContentController addScriptMessageHandler:handle name:@"playLive"];
        
        //_webView.customUserAgent = @"Mozilla/5.0 (iPad; CPU OS 12_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Mobile/15E148 Safari/604.1";
        _webView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:configuretion];
        _webView.scrollView.bounces = NO;
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_webView];
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|[_webView]|"
                                   options:1.0
                                   metrics:nil
                                   views:NSDictionaryOfVariableBindings(_webView)]];
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[_webView]-|"]
                                   options:1.0
                                   metrics:nil
                                   views:NSDictionaryOfVariableBindings(_webView)]];
    }
    return _webView;
}

- (LAContext *)context {
    if (!_context) {
        self.context = [[LAContext alloc] init];
        self.context.localizedFallbackTitle = @"User password";
    }
    return _context;
}

- (void)fileupdateWithParams:(NSString *)params {
    NSLog(@"错误: fileupdate");
    NSArray *parames = [params componentsSeparatedByString:@","];
    if (parames.count == 2) {
        WS(ws);
        /*
        NSString *fileURLString = [NSString stringWithFormat:@"https://erp.7tech.sg%@", parames.firstObject];
        NSURL *fileURL = [NSURL URLWithString:fileURLString];
        
        // 初始化 MBProgressHUD
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeDeterminate;
        hud.label.text = @"Downloading...";
        
        NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress) {
            // 更新进度
            dispatch_async(dispatch_get_main_queue(), ^{
                printf(@"进度： %f",downloadProgress.fractionCompleted);
                hud.progress = downloadProgress.fractionCompleted;
            });
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            // 获取本地文件路径
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *filePath = [documentsPath stringByAppendingPathComponent:parames.lastObject];
            return [NSURL fileURLWithPath:filePath];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            // 在主线程中更新 UI
            dispatch_async(dispatch_get_main_queue(), ^{
                // 隐藏 HUD
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (!error) {
                    // 显示分享视图控制器
                    NSArray *itemsToShare = @[filePath];
                    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
                    [ws presentViewController:activityVC animated:YES completion:nil];
                } else {
                    NSLog(@"下载错误: %@", error.localizedDescription);
                }
            });
        }];
        
        // 启动下载任务
        [downloadTask resume];
        */
        
        [MBProgressHUD showMessage:@"Downloading..."];
        NSString *fileURLString = [NSString stringWithFormat:@"%@%@",BASE_URL_NO,parames.firstObject];
        NSURL *fileURL = [NSURL URLWithString:fileURLString];

        // 创建下载任务
        NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:fileURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (!error) {
                // 获取本地文件路径
                NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                NSString *filePath = [documentsPath stringByAppendingPathComponent:parames.lastObject];
                NSURL *localURL = [NSURL fileURLWithPath:filePath];

                // 移动文件到本地路径
                [[NSFileManager defaultManager] moveItemAtURL:location toURL:localURL error:nil];

                // 在主线程中显示分享视图控制器
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUD];
                    NSArray *itemsToShare = @[localURL];
                    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
                    [ws presentViewController:activityVC animated:YES completion:nil];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUD];
                });
                NSLog(@"下载错误: %@", error.localizedDescription);
            }
        }];

        // 启动下载任务
        [downloadTask resume];
         
        
        /*
        NSURL *fileUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://erp.7tech.sg%@",parames.firstObject]];
        NSArray *itemsToShare = @[fileUrl]; // 可以是文本、图片、URL等
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        //activityVC.excludedActivityTypes = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter];
        [self presentViewController:activityVC animated:YES completion:nil];
        activityVC.completionWithItemsHandler = ^(UIActivityType _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            if (completed) {
                NSLog(@"分享成功");
            } else {
                NSLog(@"分享取消");
            }
        };*/
        
        /*
        // 使用自定义的 Item
        NSString *fileURLString = [NSString stringWithFormat:@"https://erp.7tech.sg%@",parames.firstObject];
        NSURL *fileURL = [NSURL URLWithString:fileURLString];
        CustomActivityItem *item = [[CustomActivityItem alloc] init];
        item.fileURL = fileURL;
        item.fileName = parames.lastObject; // 自定义显示名称

        NSArray *itemsToShare = @[item];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
        activityVC.completionWithItemsHandler = ^(UIActivityType _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            if (completed) {
                NSLog(@"分享成功");
            } else {
                NSLog(@"分享取消");
            }
        };
         */
    } else {
        [MBProgressHUD showError:@"error"];
    }
         

}
/*!签名*/
- (void)drawRect {
    WS(ws);
    DrawRectViewController *signatureVC = [[DrawRectViewController alloc] init];
    signatureVC.saveSuccess = ^(NSString *pathString) {
        NSString *jsStr = [NSString stringWithFormat:@"tobacksignpath('%@')", pathString];
        [ws.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"错误:%@", error.localizedDescription);
            }
        }];
    };
    [self.navigationController pushViewController:signatureVC animated:YES];
}

/*!退出登录*/
- (void)popBack:(NSString *)params {
//- (void)popBack {
    WS(ws);
    if (![params containsString:@"expired"]) {
        [self refreshWeb];
    } else {
        [MBProgressHUD showMessage:@"login out..."];
        
        // 清空缓存的用户信息
        [[NSUserDefaults standardUserDefaults] setObject:@{@"user.usercode":@"",@"user.password":@"",@"token":@"",@"url":@"",@"usercode":@"",@"JSESSIONID":@""} forKey:@"STAUP"];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"STAUP"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        LoginModel *model = [[LoginModel alloc] init];
        BOOL hasLogin = (model.token && model.token.length > 10);
        /// 是否清理完毕
        if (hasLogin) {
            [MBProgressHUD hideHUD];
            //[self popBack];
        } else {
            [MBProgressHUD hideHUD];
            if (self.navigationController.viewControllers.count > 1) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                
                // 清除所有 Cookies
                NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                NSArray *cookies = [cookieStorage cookies];
                for (NSHTTPCookie *cookie in cookies) {
                    [cookieStorage deleteCookie:cookie];
                }
                
                LoginViewController *lgVC = [LoginViewController new];
                lgVC.modalPresentationStyle = UIModalPresentationFullScreen;
                lgVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [ws presentViewController:lgVC animated:YES completion:^{}];
                lgVC.lgSuccess = ^(LoginViewController * _Nonnull hdVC, LoginModel * _Nonnull hdModel, BOOL rlt) {
                    ws.dataModel = hdModel;
                    //根据新登录账号重新加载
                    NSString *urlStr = [NSString stringWithFormat:@"%@admin/login.action?user.usercode=%@&user.password=%@&token=%@&clienttype=%ld",ws.dataModel.url,ws.dataModel.username,ws.dataModel.password, ws.dataModel.token,ws.dataModel.clienttype];
                    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    //urlStr = [urlStr stringByReplacingOccurrencesOfString:@"cctv.7" withString:@"cctv2.7"];

                    //[ws.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10]];
                    NSMutableURLRequest *rqst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
                    //[rqst addValue:[NSString stringWithFormat:@"usercode=%@",ws.dataModel.usercode] forHTTPHeaderField:@"Cookie"];
                    //[ws.webView loadRequest:rqst];
                    // 创建 usercode Cookie
                    NSHTTPCookie *usercodeCookie = [NSHTTPCookie cookieWithProperties:@{
                        NSHTTPCookieName: @"usercode",
                        NSHTTPCookieValue: @"",
                        NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
                        NSHTTPCookiePath: @"/",
                        NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600] // 设置过期时间为1月
                    }];

                    NSHTTPCookie *tokenCookie = [NSHTTPCookie cookieWithProperties:@{
                        NSHTTPCookieName: @"tempcode",
                        NSHTTPCookieValue: ws.dataModel.token,
                        NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
                        NSHTTPCookiePath: @"/",
                        NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 1 month expiration
                    }];
                    
                    // 设置 Cookie 到 WKWebView 的 httpCookieStore
                    [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
                        [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:tokenCookie completionHandler:^{
                            // 加载请求
                            [ws.webView loadRequest:rqst];
                        }];
                    }];
                    
                    // 设置 Cookie 到 WKWebView 的 httpCookieStore
                    /*[ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
                        // 加载请求
                        [ws.webView loadRequest:rqst];
                    }];
                     */
                };
            }
        }
    }
}

/*!上传图片*/
- (void)uploadPic {
    //唤起相册或打开相机
    WS(ws);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"choose photo" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        /*拍照*/
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = ws;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [ws presentViewController:imagePickerController animated:YES completion:^{}];
    }];
    UIAlertAction *photoAblumAction = [UIAlertAction actionWithTitle:@"Photo album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        /*去相册中取图片*/
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = ws;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [ws presentViewController:imagePickerController animated:YES completion:^{}];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancle" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    /*!判断是否支持相机*/
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [alertController addAction:takePhotoAction];
    }else{
        
    }
    [alertController addAction:photoAblumAction];
    [alertController addAction:cancelAction];
    [ws presentViewController:alertController animated:YES completion:nil];
}

- (void)updataFaceImage:(UIImage *)image {
    [MBProgressHUD showMessage:@"Loading..."];
    WS(ws);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 忽略 SSL 认证
    //manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //manager.securityPolicy.allowInvalidCertificates = YES; // 允许无效证书
    //manager.securityPolicy.validatesDomainName = NO; // 不验证域名
    
    
    manager.responseSerializer.acceptableContentTypes = nil;
    [manager POST:[NSString stringWithFormat:@"%@phone/fileupload.action",self.userModel.url]
       parameters:@{}
          headers:@{}
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *fileName = [NSString stringWithFormat:@"%@_face.png",[formatter stringFromDate:[NSDate date]]];
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.8)
                                    name:@"file"
                                fileName:fileName
                                mimeType:@"image/png"];
    }
         progress:^(NSProgress * _Nonnull uploadProgress) {
        
    }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUD];
        if ([responseObject[@"ret"] boolValue]) {
            //tobackuploadpath
            //tofaceuploadpath
            NSString *jsStr = [NSString stringWithFormat:@"tofaceuploadpath('%@')", responseObject[@"filepath"]];
            [ws.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"上传头像错误:%@", error.localizedDescription);
                }
            }];
        } else {
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"Save failed"];
    }];
}

/*!打开相机*/
- (void)startCamera {
    WS(ws);
    YYTakePhotosViewController *pVC = [YYTakePhotosViewController new];
    pVC.modalPresentationStyle = UIModalPresentationFullScreen;
    pVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    pVC.picBlock = ^(YYTakePhotosViewController * _Nonnull hdVC, UIImage * _Nullable hdImg) {
        hdImg = [hdImg sd_resizedImageWithSize:CGSizeMake(320, 320) scaleMode:SDImageScaleModeFill];
        //计算图片大小
        //[ws calulateImageFileSize:hdImg];
        [ws updataFaceImage:hdImg];
    };
    [self.navigationController pushViewController:pVC animated:YES];
}

- (void)updataImage:(UIImage *)image {
    [MBProgressHUD showMessage:@"Loading..."];
    WS(ws);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 忽略 SSL 认证
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.securityPolicy.allowInvalidCertificates = YES; // 允许无效证书
    manager.securityPolicy.validatesDomainName = NO; // 不验证域名
    
    
    manager.responseSerializer.acceptableContentTypes = nil;
    [manager POST:[NSString stringWithFormat:@"%@phone/fileupload.action",self.userModel.url]
       parameters:@{}
          headers:@{}
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *fileName = [NSString stringWithFormat:@"%@_header.png",[formatter stringFromDate:[NSDate date]]];
    [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.1)
                                name:@"file"
                            fileName:fileName
                            mimeType:@"image/png"];
} progress:^(NSProgress * _Nonnull uploadProgress) {
    
} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    [MBProgressHUD hideHUD];
    if ([responseObject[@"ret"] boolValue]) {
        NSString *jsStr = [NSString stringWithFormat:@"tobackuploadpath('%@')", responseObject[@"filepath"]];
        [ws.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"上传图片错误:%@", error.localizedDescription);
            }
        }];
    } else {
        [MBProgressHUD showError:responseObject[@"msg"]];
    }
} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:@"Save failed"];
}];
    
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    WS(ws);
    [picker dismissViewControllerAnimated:YES completion:^{
        [ws updataImage:image];
    }];
}

- (void)calulateImageFileSize:(UIImage *)image {
    NSData *data = UIImagePNGRepresentation(image);
    if (!data) {
        data = UIImageJPEGRepresentation(image, 0.8);//需要改成0.5才接近原图片大小，原因请看下文
    }
    double dataLength = [data length] * 1.0;
    NSArray *typeArray = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB",@"ZB",@"YB"];
    NSInteger index = 0;
    while (dataLength > 1024) {
        dataLength /= 1024.0;
        index ++;
    }
    NSLog(@"image = %.3f %@",dataLength,typeArray[index]);
}

/*!开始定位*/
- (void)getLocation {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager requestWhenInUseAuthorization];
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
    } else {
        [_locationManager startUpdatingLocation];
    }
}
/*开启指纹或者人脸*/
- (void)openBiology {
    [[NSUserDefaults standardUserDefaults] setObject:@{@"biology":@"open"} forKey:@"Biology"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*关闭指纹或者人脸*/
- (void)closeBiology {
    [[NSUserDefaults standardUserDefaults] setObject:@{@"biology":@"close"} forKey:@"Biology"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*扫一扫*/
- (void)screen {
    WS(ws);
    /*
    HYZScanVC *scanVC = [HYZScanVC new];
    scanVC.screenSuccess = ^(NSString *codeString){
        NSString *jsStr = [NSString stringWithFormat:@"tobackbarcode('%@')", codeString];
        [ws.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"错误:%@", error.localizedDescription);
            }
        }];
    };
    [self.navigationController pushViewController:scanVC animated:YES];
    */
    HYZBarCoderVC *scanVC = [HYZBarCoderVC new];
    scanVC.screenSuccess = ^(NSString *codeString){
        NSString *jsStr = [NSString stringWithFormat:@"tobackbarcode('%@')", codeString];
        [ws.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"错误:%@", error.localizedDescription);
            }
        }];
    };
    [self.navigationController pushViewController:scanVC animated:YES];
}

/* 点播 */
- (void)playVideoWithUrl:(NSString *)url {
    NSLog(@"点播地址%@%@",BASE_URL, url);
        NSURL *streamURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL, url]];
//    VLCMediaPlayer *player = [[VLCMediaPlayer alloc] init];
//    player.drawable = self.view;
//    self.webView.hidden = YES;
//    self.view.backgroundColor = [UIColor yellowColor];
//    player.media = [VLCMedia mediaWithURL:streamURL];
//    [player play];

    //NSURL *streamURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"https://cctv2.7tech.sg/", url]];
    AVPlayer *player = [AVPlayer playerWithURL:streamURL];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = player;

    // 显示播放器
    [self presentViewController:playerViewController animated:YES completion:^{
        [player play]; // 开始播放
    }];
    
//    VLCMedia *media = [VLCMedia mediaWithURL:streamURL];
//    // 添加 FLV 特定选项
////     [media addOptions:@{
////         @"network-caching": @(5000), // 增大缓存时间
////         @"rtsp-tcp": @(YES),          // 强制使用 TCP 模式（如果适用）
////         @"no-hw-dec": @(YES),         // 禁用硬件加速
////         @"flv-live": @(NO),          // 指定 FLV 流为直播流
////         @"http-user-agent": @"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36", // 设置 User-Agent
////         @"http-referrer": @"https://cctv.7tech.sg/" // 设置 Referer 请求头
////     }];
//
//    if (self.mediaPlayer) {
//        [self.mediaPlayer pause];
//    }
//    self.mediaPlayer.media = media;
//    [self.mediaPlayer play];
}

/* 直播 */
- (void)playLiveWithUrl:(NSString *)url {
    NSLog(@"直播地址%@",url);
    //    NSURL *streamURL = [NSURL URLWithString:url];
//    //    VLCMediaPlayer *player = [[VLCMediaPlayer alloc] init];
//    //    player.drawable = self.view;
//    //    self.webView.hidden = YES;
//    //    self.view.backgroundColor = [UIColor yellowColor];
//    //    player.media = [VLCMedia mediaWithURL:streamURL];
//    //    [player play];
//    NSLog(@"视频地址：%@", url);
//    NSURL *streamURL = [NSURL URLWithString:url];
//    VLCMedia *media = [VLCMedia mediaWithURL:streamURL];
//    
//    // 添加 RTSP 特殊选项
//    //    [media addOptions:@{
//    //        @"rtsp-tcp": @(YES), // 强制使用 TCP 模式
//    //        @"network-caching": @(5000), // 增大缓存时间为 2000 毫秒
//    //        @"clock-jitter": @(0), // 禁用时钟抖动
//    //        @"clock-synchro": @(NO), // 禁用时钟同步
//    //        @"--no-ssl-verify": @(YES), // 忽略 HTTPS 证书验证
//    //        @"no-audio": @(YES) // 禁用音频流（如果不需要音频）
//    //    }];
//    
//    //    [media addOptions:@{
//    //        @"--no-ssl-verify": @(YES), // 忽略 HTTPS 证书验证
//    //        @"network-caching": @(500), // 增大缓存时间
//    //        @"rtsp-tcp": @(YES), // 强制使用 TCP 模式（如果适用）
//    //        //@"http-referrer": @"https://cctv.7tech.sg/",
//    //        //@"http-user-agent": @"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
//    //
//    //    }];
//    
//    //    [media addOptions:@{
//    //        @"network-caching": @(2000), // 增大缓存时间
//    //        @"rtsp-tcp": @(YES), // 强制使用 TCP 模式（如果适用）
//    //        @"no-hw-dec": @(YES), // 禁用硬件加速
//    //        @"http-referrer": @"https://cctv2.7tech.sg/", // 添加 Referer 请求头
//    //        @"http-user-agent": @"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
//    //    }];
//    
//    // 添加 FLV 特定选项
//    //     [media addOptions:@{
//    //         @"network-caching": @(2000), // 增大缓存时间
//    //         @"rtsp-tcp": @(YES),          // 强制使用 TCP 模式（如果适用）
//    //         //@"flv-live": @(YES),          // 指定 FLV 流为直播流
//    //         @"rtmp-live": @(YES),          // 指定 RTMP 流为直播流
//    //         @"no-hw-dec": @(YES),          // 禁用硬件加速解码。
//    //         @"http-reconnect": @(YES),    //在网络中断时自动重连
//    //         @"http-user-agent": @"Mozilla/5.0", // 设置 User-Agent
//    //         @"http-referrer": @"https://cctv2.7tech.sg/" // 设置 Referer 请求头
//    //     }];
//    
//    //    [media addOptions:@{
//    //        @"network-caching": @(5000), // 增大缓存时间
//    //        @"flv-live": @(YES),          // 指定 FLV 流为直播流
//    //        @"http-referrer": @"https://cctv2.7tech.sg/", // 设置 Referer 请求头
//    //        @"http-user-agent": @"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
//    //    }];
//    
//    // 添加直播流相关的媒体选项
//    //    [media addOptions:@{
//    //        @"network-caching": @(2000), // 设置网络缓存时间（单位：毫秒）
//    //        @"rtsp-tcp": @(1),          // 强制使用 TCP 传输（适用于 RTSP 流）
//    //        @"no-audio": @(0),          // 启用音频（如果需要禁用音频，设置为 1）
//    //        @"live-caching": @(2000),    // 设置直播缓存时间（单位：毫秒）
//    //        @"clock-jitter": @(0),      // 禁用时间抖动（适用于低延迟场景）
//    //        @"clock-synchro": @(0),      // 禁用时钟同步（适用于低延迟场景）
//    //        @"avcodec-skiploopfilter": @"nonref", // 设置值，例如 "all"、"nonref" 或 "none" 如果不设置，avcodec-skiploopfilter 的默认值是 none，即不跳过环路滤波
//    //        @"avcodec-hw": @"any",              // 启用硬件加速   ··1
//    //        @"--no-ssl-verify": @(YES), // 忽略 HTTPS 证书验证
//    //    }];
//    
////    [media addOptions:@{
////        @"--no-ssl-verify": @(YES),
////        @"--no-ignore-cert":@(YES),
////        @"--no-video-toolbox": @(YES) // 禁用硬件加速
////    }];
//    
//    [media addOptions:@{
//        @"rtsp-tcp": @(YES),          // 强制使用 TCP 传输（适用于 RTSP 流）
//        @"clock-jitter": @(0),      // 禁用时间抖动（适用于低延迟场景）
//        @"clock-synchro": @(0),      // 禁用时钟同步（适用于低延迟场景）
//        @"--no-ssl-verify": @(YES),       // 忽略 SSL 验证
//        @"--no-ignore-cert": @(YES),         // 忽略证书错误
//        @"--ignore-cert": @(YES),         // 忽略证书错误
//        @"--no-video-toolbox": @(YES),    // 禁用硬件加速
//        @"network-caching": @(1000),      // 增加网络缓存（1秒）
//        @"file-caching": @(1000),         // 文件缓存
//        @"live-caching": @(1000)          // 直播缓存
//    }];


    
//    if (self.mediaPlayer) {
//        [self.mediaPlayer pause];
//    }
//    self.mediaPlayer.media = media;
//    [self.mediaPlayer play];
    
    VLOPlayerVC *player = [[VLOPlayerVC alloc] init];
    player.modalPresentationStyle = UIModalPresentationFullScreen; // 设置为全屏
    // 显示播放器
    [self presentViewController:player animated:YES completion:^{
        [player playWithLiveUrl:url];
    }];
    
    
//    AVPlayer *player = [AVPlayer playerWithURL:streamURL];
//    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
//    playerViewController.player = player;
//
//    // 显示播放器
//    [self presentViewController:playerViewController animated:YES completion:^{
//        [player play]; // 开始播放
//    }];
}

#pragma mark - 代理方法 WKNavigationDelegate WKScriptMessageHandler

// 实现 WKNavigationDelegate 方法以忽略 SSL 认证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}


// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    self.view.backgroundColor = [UIColor colorNamed:@"3B404D"];
    [MBProgressHUD hideHUD];
    [MBProgressHUD showMessage:@"loading..."];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
    WS(ws);
    [webView.configuration.websiteDataStore.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
        NSString *usercode = @"";
        NSString *JSESSIONID = @"";
        
        for (NSHTTPCookie *cookie in cookies) {
            NSLog(@"Cookie: %@=%@", cookie.name, cookie.value);
            if ([cookie.name isEqualToString:@"usercode"]) {
                usercode = cookie.value;
            }
            
            if ([cookie.name isEqualToString:@"JSESSIONID"]) {
                JSESSIONID = cookie.value;
                NSLog(@"Found JSESSIONID: %@", JSESSIONID);
            }
        }
    }];
    
    //[[NSUserDefaults standardUserDefaults] setObject:@{@"user.usercode":ws.dataModel.username,@"user.password":ws.dataModel.password,@"token":ws.dataModel.token,@"url":ws.dataModel.url,@"usercode":usercode,@"JSESSIONID":JSESSIONID} forKey:@"STAUP"];
    //[[NSUserDefaults standardUserDefaults] synchronize];

    
    [MBProgressHUD hideHUD];
    //判断是否支持指纹或者面容
    //admin/login.action?user.usercode=
    NSDictionary *firstDic = [NSDictionary dictionaryWithDictionary:YYD(@"FST")];
    LoginModel *firstModel = [LoginModel yy_modelWithDictionary:firstDic];
    if (firstModel.first && [firstModel.first isEqualToString:@"first"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@{@"first":@"NOfirst"} forKey:@"FST"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self authorization];
    } else {
        NSDictionary *biologyDic = [NSDictionary dictionaryWithDictionary:YYD(@"Biology")];
        NSString *jsStr = @"";
        LoginModel *biologyModel = [LoginModel yy_modelWithDictionary:biologyDic];
        if (biologyModel.biology && [biologyModel.biology isEqualToString:@"open"]) {
            jsStr = [NSString stringWithFormat:@"callBiology('1')"];
        } else {
            jsStr = [NSString stringWithFormat:@"callBiology('0')"];
        }
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ws.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"加载完成错误:%@", error.localizedDescription);
                }
            }];
        //});
    }
    /*
    //获取所有的HTML
    NSString *doc = @"document.documentElement.innerHTML";
    [webView evaluateJavaScript:doc completionHandler:^(NSString *htmlStr, NSError * _Nullable error) {
        if (error) {
            NSLog(@"JSError:%@",error);
        } else {
            NSLog(@"html--:%@",htmlStr);
        }
    }];
     */
    
//    [self.view bringSubviewToFront:self.videoView];
}

//请求页面过程中的错误 服务器接收到请求，并开始返回数据给到客户端的过程中出现传输错误 传输过程中，断网了或者服务器down掉
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:error.localizedDescription];
}

//在开始加载的数据时发生错误时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"在开始加载的数据时发生错误时调用");
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:error.localizedDescription];
}

//9.0才能使用，web内容处理中断时会触发
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"web内容处理中断时会触发");
    [MBProgressHUD hideHUD];
    [webView reload];
}

//服务器开始请求的时候调用
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"sub web URl : %@",navigationAction.request.URL);

    decisionHandler(WKNavigationActionPolicyAllow);
}



////解决cookies丢失问题  收到响应后决定是否跳转 (服务器收到请求后)
//- (void)webView:(WKWebView*)webView decidePolicyForNavigationResponse:(WKNavigationResponse*)navigationResponse decisionHandler:(void(^)(WKNavigationResponsePolicy))decisionHandler{
//    if (@available(iOS 12.0, *)) {
//        //iOS11也有这种获取方式，但是我使用的时候iOS11系统可以在response里面直接获取到，只有iOS12获取不到
//        WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
//        [cookieStore getAllCookies:^(NSArray* cookies) {
//            [self setCookie:cookies];
//        }];
//    }else {
//        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
//        NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
//        [self setCookie:cookies];
//    }
//    decisionHandler(WKNavigationResponsePolicyAllow);
//}
//
//-(void)setCookie:(NSArray *)cookies {
//    NSLog(@"cookies ： %@",cookies);
//    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@" %@",obj.name);
//    }];
////    if (cookies.count > 0) {
////        for (NSHTTPCookie *cookie in cookies) {
////            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
////        }
////    }
//}

// 接收到服务器跳转请求之后调用 主机地址被重定向时调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"接收到服务器跳转请求之后调用");
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"内容开始返回");
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [MBProgressHUD hideHUD];
//    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"释放");
}

/*判断当前手机是否支持指纹解锁或者人脸识别功能*/
-(void)authorization {
    NSError *authError = nil;
    BOOL isCanEvaluatePolicy = [self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError];
    if (authError) {
        [MBProgressHUD showError:@"The device does not support biometry."];
        NSString *jsStr = [NSString stringWithFormat:@"callBiology('0')"];
        [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"是否支持指纹解锁或者人脸识别1错误:%@", error.localizedDescription);
            }
        }];
        [self closeBiology];
    } else {
        if (isCanEvaluatePolicy) {
            if (self.context.biometryType == LABiometryTypeTouchID) {
                //当前支持指纹密码
                NSLog(@"The device supports Touch ID.");
            } else if (self.context.biometryType == LABiometryTypeFaceID) {
                //当前支持指纹密码 @"人脸识别");
                NSLog(@"The device supports Face ID.");
            }else {
                //当前不支持指纹密码指纹密码"
                NSLog(@"The device does not support biometry.");
            }
            
            WS(ws);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Open Touch ID or Face ID" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [ws openBiology];
                NSString *jsStr = [NSString stringWithFormat:@"callBiology('1')"];
                [ws.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"是否支持指纹解锁或者人脸识别2错误:%@", error.localizedDescription);
                    }
                }];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancle" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [ws closeBiology];
                NSString *jsStr = [NSString stringWithFormat:@"callBiology('0')"];
                [ws.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"是否支持指纹解锁或者人脸识别3错误:%@", error.localizedDescription);
                    }
                }];
            }];
            [alertController addAction:okAction];
            [alertController addAction:cancelAction];
            [ws presentViewController:alertController animated:YES completion:nil];
        } else {
            if (authError.code == LAErrorBiometryNotEnrolled) {
                [MBProgressHUD showError:@"TouchID is not enrolled."];
                NSLog(@"TouchID is not enrolled TouchID未注册");
            } else if (authError.code == LAErrorPasscodeNotSet) {
                [MBProgressHUD showError:@"A passcode has not been set."];
                NSLog(@"A passcode has not been set 未设置密码");
            } else {
                [MBProgressHUD showError:@"TouchID not available TouchID."];
                NSLog(@"TouchID not available TouchID不可用");
            }
            NSString *jsStr = [NSString stringWithFormat:@"callBiology('0')"];
            [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"是否支持指纹解锁或者人脸识别4错误:%@", error.localizedDescription);
                }
            }];
            [self closeBiology];
        }
    }
}
- (LoginModel *)userModel {
    if (!_userModel) {
        _userModel = [[LoginModel alloc] init];
    }
    return _userModel;
}

//#pragma mark - VLCMediaPlayerDelegate
//
//- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
//    VLCMediaPlayerState state = self.mediaPlayer.state;
//    NSLog(@"当前流状态: %ld", (long)state);
//    
//    switch (state) {
//        case VLCMediaPlayerStateBuffering:
//            NSLog(@"正在缓冲");
//            break;
//        case VLCMediaPlayerStatePlaying:
//            NSLog(@"正在播放");
//            break;
//        case VLCMediaPlayerStateError:
//            NSLog(@"播放器发生错误：%@", self.mediaPlayer.media);
//        case VLCMediaPlayerStateStopped:
////        case VLCMediaPlayerStateEnded:
////            NSLog(@"播放错误或结束");
////            break;
//        default:
//            break;
//    }
//}
//
//- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
//    NSString *time = self.mediaPlayer.time.stringValue;
//    NSLog(@"当前播放时间：%@", time);
//}

/*
- (void)evaluatePolicy {
    WS(ws);
    [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Authenticate to access" reply:^(BOOL success, NSError * _Nullable error) {
                if(success) {
                    NSString *urlStr = [NSString stringWithFormat:@"%@admin/login.action?token=%@&clienttype=%ld",BASE_URL,ws.dataModel.username,ws.dataModel.password,ws.dataModel.token,ws.dataModel.clienttype];
                    NSLog(@"%@",urlStr);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ws.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
                    });
                } else {
                    NSLog(@"指纹认证失败，%@",error.description);

                    NSLog(@"%ld", (long)error.code); // 错误码 error.code
                    switch (error.code)
                    {
                        case LAErrorAuthenticationFailed: // Authentication was not successful, because user failed to provide valid credentials
                        {
                            NSLog(@"授权失败"); // -1 连续三次指纹识别错误
                        }
                            break;
                        case LAErrorUserCancel: // Authentication was canceled by user (e.g. tapped Cancel button)
                        {
                            NSLog(@"用户取消验证Touch ID"); // -2 在TouchID对话框中点击了取消按钮

                        }
                            break;
                        case LAErrorUserFallback: // Authentication was canceled, because the user tapped the fallback button (Enter Password)
                        {
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                NSLog(@"用户选择输入密码，切换主线程处理"); // -3 在TouchID对话框中点击了输入密码按钮
                            }];

                        }
                            break;
                        case LAErrorSystemCancel: // Authentication was canceled by system (e.g. another application went to foreground)
                        {
                            NSLog(@"取消授权，如其他应用切入，用户自主"); // -4 TouchID对话框被系统取消，例如按下Home或者电源键
                        }
                            break;
                        case LAErrorPasscodeNotSet: // Authentication could not start, because passcode is not set on the device.

                        {
                            NSLog(@"设备系统未设置密码"); // -5
                        }
                            break;
                        case LAErrorBiometryNotAvailable: // Authentication could not start, because Touch ID is not available on the device
                        {
                            NSLog(@"设备未设置Touch ID"); // -6
                        }
                            break;
                        case LAErrorBiometryNotEnrolled: // Authentication could not start, because Touch ID has no enrolled fingers
                        {
                            NSLog(@"用户未录入指纹"); // -7
                        }
                            break;

    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
                        case LAErrorBiometryLockout:
                            //Authentication was not successful, because there were too many failed Touch ID attempts and Touch ID is now locked. Passcode is required to unlock Touch ID, e.g. evaluating LAPolicyDeviceOwnerAuthenticationWithBiometrics will ask for passcode as a prerequisite 用户连续多次进行Touch ID验证失败，Touch ID被锁，需要用户输入密码解锁，先Touch ID验证密码
                        {
                            NSLog(@"Touch ID被锁，需要用户输入密码解锁"); // -8 连续五次指纹识别错误，TouchID功能被锁定，下一次需要输入系统密码
                        }
                            break;
                        case LAErrorAppCancel: // Authentication was canceled by application (e.g. invalidate was called while authentication was in progress) 如突然来了电话，电话应用进入前台，APP被挂起啦");
                        {
                            NSLog(@"用户不能控制情况下APP被挂起"); // -9
                        }
                            break;
                        case LAErrorInvalidContext: // LAContext passed to this call has been previously invalidated.
                        {
                            NSLog(@"LAContext传递给这个调用之前已经失效"); // -10
                        }
                            break;
    #else
    #endif
                        default:
                        {
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                NSLog(@"其他情况，切换主线程处理");
                            }];
                            break;
                        }
                    }
                }
            }];

}
 */

@end

/*
// if (self.navigationController.viewControllers.count > 1) {
//     [self.navigationController popViewControllerAnimated:YES];
// } else {
//     // 清除所有 Cookies
//     NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//     NSArray *cookies = [cookieStorage cookies];
//     for (NSHTTPCookie *cookie in cookies) {
//         [cookieStorage deleteCookie:cookie];
//     }
//     
//     LoginViewController *lgVC = [LoginViewController new];
//     lgVC.modalPresentationStyle = UIModalPresentationFullScreen;
//     lgVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//     [ws presentViewController:lgVC animated:YES completion:^{}];
//     lgVC.lgSuccess = ^(LoginViewController * _Nonnull hdVC, LoginModel * _Nonnull hdModel, BOOL rlt) {
//         ws.dataModel = hdModel;
//         //根据新登录账号重新加载
//         NSString *urlStr = [NSString stringWithFormat:@"%@admin/login.action?user.usercode=%@&user.password=%@&token=%@&clienttype=%ld",ws.dataModel.url,ws.dataModel.username,ws.dataModel.password, ws.dataModel.token,ws.dataModel.clienttype];
//         urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//         //urlStr = [urlStr stringByReplacingOccurrencesOfString:@"cctv.7" withString:@"cctv2.7"];
//
//         //[ws.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10]];
//         NSMutableURLRequest *rqst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
//         //[rqst addValue:[NSString stringWithFormat:@"usercode=%@",ws.dataModel.usercode] forHTTPHeaderField:@"Cookie"];
//         //[ws.webView loadRequest:rqst];
//         // 创建 usercode Cookie
//         NSHTTPCookie *usercodeCookie = [NSHTTPCookie cookieWithProperties:@{
//             NSHTTPCookieName: @"usercode",
//             NSHTTPCookieValue: @"",
//             NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
//             NSHTTPCookiePath: @"/",
//             NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600] // 设置过期时间为1月
//         }];
//
//         NSHTTPCookie *tokenCookie = [NSHTTPCookie cookieWithProperties:@{
//             NSHTTPCookieName: @"tempcode",
//             NSHTTPCookieValue: ws.dataModel.token,
//             NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
//             NSHTTPCookiePath: @"/",
//             NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 1 month expiration
//         }];
//         
//         // 设置 Cookie 到 WKWebView 的 httpCookieStore
//         [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
//             [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:tokenCookie completionHandler:^{
//                 // 加载请求
//                 [ws.webView loadRequest:rqst];
//             }];
//         }];
//         
//         // 设置 Cookie 到 WKWebView 的 httpCookieStore
//         /*[ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
//             // 加载请求
//             [ws.webView loadRequest:rqst];
//         }];
//          */
//     };
// }
// 
// 
// NSString *bsUrl = (self.userModel.url && self.userModel.url.length>0) ? self.userModel.url : BASE_URL;
// //bsUrl = [bsUrl stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
// NSString *urlStr = [NSString stringWithFormat:@"%@admin/login.action?user.usercode=%@&user.password=%@&token=%@&clienttype=%ld",bsUrl, _dataModel.username, _dataModel.password,  _dataModel.token,_dataModel.clienttype];
// urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
// //urlStr = [urlStr stringByReplacingOccurrencesOfString:@"cctv.7" withString:@"cctv2.7"];
// 
// [[YYTouchIDManager shareManager] openTouchId:NO block:^(BOOL isSuccess) {
//     if (isSuccess) {
//         dispatch_async(dispatch_get_main_queue(), ^{
//             ws.view.backgroundColor = [UIColor colorNamed:@"3B404D"];
//             NSMutableURLRequest *rqst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
//             //[rqst addValue:[NSString stringWithFormat:@"usercode=%@",ws.dataModel.usercode] forHTTPHeaderField:@"Cookie"];
//             //[ws.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10]];
//             //[ws.webView loadRequest:rqst];
//             // 创建 usercode Cookie
//             NSHTTPCookie *usercodeCookie = [NSHTTPCookie cookieWithProperties:@{
//                 NSHTTPCookieName: @"usercode",
//                 NSHTTPCookieValue: ws.dataModel.usercode,
//                 NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
//                 NSHTTPCookiePath: @"/",
//                 NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 设置过期时间为1月
//             }];
//             
//             NSHTTPCookie *tokenCookie = [NSHTTPCookie cookieWithProperties:@{
//                 NSHTTPCookieName: @"tempcode",
//                 NSHTTPCookieValue: ws.dataModel.token,
//                 NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
//                 NSHTTPCookiePath: @"/",
//                 NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 1 month expiration
//             }];
//             
//             // 设置 Cookie 到 WKWebView 的 httpCookieStore
//             [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
//                 [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:tokenCookie completionHandler:^{
//                     // 加载请求
//                     [ws.webView loadRequest:rqst];
//                     [ws dismissViewControllerAnimated:YES completion:^{}];
//                 }];
//             }];
//             
//             /*
//              // 设置 Cookie 到 WKWebView 的 httpCookieStore
//              [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
//              // 加载请求
//              [ws.webView loadRequest:rqst];
//              }];
//              */
//         });
//     } else {
//         [[YYTouchIDManager shareManager] openTouchId:NO block:^(BOOL isSuccess) {
//             if (isSuccess) {
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     ws.view.backgroundColor = [UIColor colorNamed:@"3B404D"];
//                     NSMutableURLRequest *rqst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
//                     //[rqst addValue:[NSString stringWithFormat:@"usercode=%@",ws.dataModel.usercode] forHTTPHeaderField:@"Cookie"];
//                     //[ws.webView loadRequest:rqst];
//                     
//                     // 创建 usercode Cookie
//                     NSHTTPCookie *usercodeCookie = [NSHTTPCookie cookieWithProperties:@{
//                         NSHTTPCookieName: @"usercode",
//                         NSHTTPCookieValue: ws.dataModel.usercode,
//                         NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
//                         NSHTTPCookiePath: @"/",
//                         NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 设置过期时间为1月
//                     }];
//                     
//                     NSHTTPCookie *tokenCookie = [NSHTTPCookie cookieWithProperties:@{
//                         NSHTTPCookieName: @"tempcode",
//                         NSHTTPCookieValue: ws.dataModel.token,
//                         NSHTTPCookieDomain: [NSURL URLWithString:urlStr].host,
//                         NSHTTPCookiePath: @"/",
//                         NSHTTPCookieExpires: [NSDate dateWithTimeIntervalSinceNow:3600*24*30] // 1 month expiration
//                     }];
//                     
//                     // 设置 Cookie 到 WKWebView 的 httpCookieStore
//                     [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
//                         [ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:tokenCookie completionHandler:^{
//                             // 加载请求
//                             [ws.webView loadRequest:rqst];
//                             [ws dismissViewControllerAnimated:YES completion:^{}];
//                         }];
//                     }];
//                     
//                     // 设置 Cookie 到 WKWebView 的 httpCookieStore
//                     /*[ws.webView.configuration.websiteDataStore.httpCookieStore setCookie:usercodeCookie completionHandler:^{
//                      // 加载请求
//                      [ws.webView loadRequest:rqst];
//                      }];
//                      */
//                     
//                     //[ws.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10]];
//                 });
//             } else {
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [MBProgressHUD showError:@"Verification failed"];
//                     NSString *jsStr = [NSString stringWithFormat:@"failLocation()"];
//                     [ws.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
//                         if (error) {
//                             NSLog(@"初次加载错误:%@", error.localizedDescription);
//                         }
//                     }];
//                 });
//             }
//         }];
//     }
// }];
// */
