//
//  HYZBarCoderVC.m
//  STA
//
//  Created by admin on 2024/7/7.
//

#import "HYZBarCoderVC.h"
//#import "BarcodeScanner.h"
#import "LBXScanZXingViewController.h"
#import "StyleDIY.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "CodeInputVC.h"
#import "ResultPointModel.h"
#import <ScanKitFrameWork/HmsCustomScanViewController.h>

@interface HYZBarCoderVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CustomizedScanDelegate>

@property (nonatomic, strong) HmsCustomScanViewController *customVC;

@property (nonatomic, strong) CodeInputVC *inputVc;

@property (nonatomic, weak) IBOutlet UIView *albumView;
@property (nonatomic, weak) IBOutlet UIView *flashView;

@property (nonatomic, weak) IBOutlet UIImageView *scanIcon;
@property (nonatomic, weak) IBOutlet UIImageView *inputIcon;
@property (nonatomic, weak) IBOutlet UILabel *scanLab;
@property (nonatomic, weak) IBOutlet UILabel *inputLab;
// 闪光灯状态
@property (nonatomic, assign) BOOL isFlashlightOn;

@end

@implementation HYZBarCoderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Scan to Add";
    
    self.isFlashlightOn = NO;
    
//    self.zxScan = [LBXScanZXingViewController new];
//    //self.zxScan.style = [StyleDIY OnStyle];
//    self.zxScan.style = [self defaultStyle];
//    WS(ws);
//    self.zxScan.screenSuccess = ^(NSString *codeString) {
//        NSLog(@"扫描结果: %@", codeString);
//        if (ws.screenSuccess) {
//            ws.screenSuccess(codeString);
//        }
//        [ws.navigationController popViewControllerAnimated:YES];
//    };
    
    self.customVC = [HmsCustomScanViewController new];
    self.customVC.customizedScanDelegate = self;
    self.customVC.cutArea = CGRectMake(44, 108, Main_Screen_Width - 44*2, Main_Screen_Width - 44*2);
    self.customVC.backButtonHidden = YES;
    self.customVC.continuouslyScan = YES;
    //[self.view addSubview:customVC.view];
    //[self addChildViewController:customVC];
    //[self didMoveToParentViewController:customVC];
    
    self.inputVc = [CodeInputVC new];
    [self addChildViewController:self.inputVc];
    
    WS(ws);
    // 回调到web页
    self.inputVc.addcode = ^(NSString * _Nonnull codeString) {
        if (ws.screenSuccess) {
            ws.screenSuccess(codeString);
        }
        [ws.navigationController popViewControllerAnimated:YES];
    };
    
    [self addChildViewController:self.customVC];
    [self.previewV addSubview:self.customVC.view];
    
    self.customVC.view.frame = self.previewV.bounds;
    [self.customVC didMoveToParentViewController:self];
    
    
    /*UIView *scanFrame = [[UIView alloc] initWithFrame:CGRectMake(88, 88, Main_Screen_Width - 88*2, Main_Screen_Width - 88*2)];
    scanFrame.layer.borderColor = [UIColor greenColor].CGColor;
    scanFrame.layer.borderWidth = 2.0;
    scanFrame.backgroundColor = [UIColor clearColor];
    [self.customVC.view addSubview:scanFrame];*/
    
    // 扫描框的尺寸
    CGRect scanFrameRect = CGRectMake(44, 108, Main_Screen_Width - 44*2, Main_Screen_Width - 44*2);
//
//    // 添加模糊效果
//    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
//    blurEffectView.frame = [UIScreen mainScreen].bounds; // 使用屏幕的完整尺寸
//    [self.view addSubview:blurEffectView];
//
//    // 创建遮罩层，挖空扫描框区域
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:blurEffectView.bounds]; // 背景路径
//    [path appendPath:[UIBezierPath bezierPathWithRect:scanFrameRect]]; // 扫描框路径
//    maskLayer.path = path.CGPath;
//    maskLayer.fillRule = kCAFillRuleEvenOdd; // 使用 Even-Odd 填充规则
//    blurEffectView.layer.mask = maskLayer;

    // 添加扫描框的四个角
    CGFloat cornerLength = 20.0;
    CGFloat lineWidth = 4.0;
    UIColor *cornerColor = [UIColor greenColor];

    // 左上角
    CAShapeLayer *topLeftCorner = [CAShapeLayer layer];
    UIBezierPath *topLeftPath = [UIBezierPath bezierPath];
    // 水平线
    [topLeftPath moveToPoint:CGPointMake(CGRectGetMinX(scanFrameRect), CGRectGetMinY(scanFrameRect))];
    [topLeftPath addLineToPoint:CGPointMake(CGRectGetMinX(scanFrameRect) + cornerLength, CGRectGetMinY(scanFrameRect))];
    // 垂直线
    [topLeftPath moveToPoint:CGPointMake(CGRectGetMinX(scanFrameRect), CGRectGetMinY(scanFrameRect))];
    [topLeftPath addLineToPoint:CGPointMake(CGRectGetMinX(scanFrameRect), CGRectGetMinY(scanFrameRect) + cornerLength)];
    topLeftCorner.path = topLeftPath.CGPath;
    topLeftCorner.strokeColor = cornerColor.CGColor;
    topLeftCorner.lineWidth = lineWidth;
    [self.view.layer addSublayer:topLeftCorner];

    // 右上角
    CAShapeLayer *topRightCorner = [CAShapeLayer layer];
    UIBezierPath *topRightPath = [UIBezierPath bezierPath];
    // 水平线
    [topRightPath moveToPoint:CGPointMake(CGRectGetMaxX(scanFrameRect) - cornerLength, CGRectGetMinY(scanFrameRect))];
    [topRightPath addLineToPoint:CGPointMake(CGRectGetMaxX(scanFrameRect), CGRectGetMinY(scanFrameRect))];
    // 垂直线
    [topRightPath moveToPoint:CGPointMake(CGRectGetMaxX(scanFrameRect), CGRectGetMinY(scanFrameRect))];
    [topRightPath addLineToPoint:CGPointMake(CGRectGetMaxX(scanFrameRect), CGRectGetMinY(scanFrameRect) + cornerLength)];
    topRightCorner.path = topRightPath.CGPath;
    topRightCorner.strokeColor = cornerColor.CGColor;
    topRightCorner.lineWidth = lineWidth;
    [self.view.layer addSublayer:topRightCorner];

    // 左下角
    CAShapeLayer *bottomLeftCorner = [CAShapeLayer layer];
    UIBezierPath *bottomLeftPath = [UIBezierPath bezierPath];
    // 水平线
    [bottomLeftPath moveToPoint:CGPointMake(CGRectGetMinX(scanFrameRect), CGRectGetMaxY(scanFrameRect))];
    [bottomLeftPath addLineToPoint:CGPointMake(CGRectGetMinX(scanFrameRect) + cornerLength, CGRectGetMaxY(scanFrameRect))];
    // 垂直线
    [bottomLeftPath moveToPoint:CGPointMake(CGRectGetMinX(scanFrameRect), CGRectGetMaxY(scanFrameRect))];
    [bottomLeftPath addLineToPoint:CGPointMake(CGRectGetMinX(scanFrameRect), CGRectGetMaxY(scanFrameRect) - cornerLength)];
    bottomLeftCorner.path = bottomLeftPath.CGPath;
    bottomLeftCorner.strokeColor = cornerColor.CGColor;
    bottomLeftCorner.lineWidth = lineWidth;
    [self.view.layer addSublayer:bottomLeftCorner];

    // 右下角
    CAShapeLayer *bottomRightCorner = [CAShapeLayer layer];
    UIBezierPath *bottomRightPath = [UIBezierPath bezierPath];
    // 水平线
    [bottomRightPath moveToPoint:CGPointMake(CGRectGetMaxX(scanFrameRect) - cornerLength, CGRectGetMaxY(scanFrameRect))];
    [bottomRightPath addLineToPoint:CGPointMake(CGRectGetMaxX(scanFrameRect), CGRectGetMaxY(scanFrameRect))];
    // 垂直线
    [bottomRightPath moveToPoint:CGPointMake(CGRectGetMaxX(scanFrameRect), CGRectGetMaxY(scanFrameRect))];
    [bottomRightPath addLineToPoint:CGPointMake(CGRectGetMaxX(scanFrameRect), CGRectGetMaxY(scanFrameRect) - cornerLength)];
    bottomRightCorner.path = bottomRightPath.CGPath;
    bottomRightCorner.strokeColor = cornerColor.CGColor;
    bottomRightCorner.lineWidth = lineWidth;
    [self.view.layer addSublayer:bottomRightCorner];
}

/*切换各个标签内容*/
- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)nowController{
    nowController.view.frame = self.previewV.bounds;
    [oldController willMoveToParentViewController:nil];
    [self transitionFromViewController:oldController toViewController:nowController duration:0.3 options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
        if (finished) {
            [nowController didMoveToParentViewController:self];
        }else{
            
        }
    }];
}

/** 切换扫码*/
- (IBAction)scanning:(UIButton *)sender {
    self.scanIcon.image = [UIImage imageNamed:@"manuallyEnter"];
    self.inputIcon.image = [UIImage imageNamed:@"scanAdd"];
    self.scanLab.textColor = [UIColor colorNamed:@"333333"];
    self.inputLab.textColor = [UIColor colorNamed:@"8C8C8C"];
    
    self.albumView.hidden = NO;
    self.flashView.hidden = NO;
    
    [self replaceController:self.inputVc newController:self.customVC];
}

/** 切换输入码*/
- (IBAction)inputting:(UIButton *)sender {
    self.scanIcon.image = [UIImage imageNamed:@"manuallyEnterSlt"];
    self.inputIcon.image = [UIImage imageNamed:@"scanAddSlt"];
    self.scanLab.textColor = [UIColor colorNamed:@"8C8C8C"];
    self.inputLab.textColor = [UIColor colorNamed:@"333333"];
    
    self.albumView.hidden = YES;
    self.flashView.hidden = YES;
    
    [self replaceController:self.customVC newController:self.inputVc];
}

- (void)openPhotoLibrary {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

//开关闪光灯
- (IBAction)openOrCloseFlash:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    } else {
        [sender setBackgroundImage:[UIImage imageNamed:@"cover"] forState:UIControlStateNormal];
    }
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && [device hasTorch]) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            if (self.isFlashlightOn) {
                device.torchMode = AVCaptureTorchModeOff;
                self.isFlashlightOn = NO;
            } else {
                device.torchMode = AVCaptureTorchModeOn;
                self.isFlashlightOn = YES;
            }
            [device unlockForConfiguration];
        } else {
            NSLog(@"无法切换闪光灯状态: %@", error.localizedDescription);
        }
    } else {
        NSLog(@"设备不支持闪光灯");
    }
}

- (IBAction)scanFromPhotoLibrary:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    } else {
        [sender setBackgroundImage:[UIImage imageNamed:@"cover"] forState:UIControlStateNormal];
    }
    
    // 请求相册权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    [self openPhotoLibrary];
                } else {
                    [MBProgressHUD showError:@"Please allow access to the album in the settings"];
                }
            });
            
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        [self openPhotoLibrary];
    } else {
        [MBProgressHUD showError:@"Please allow access to the album in the settings"];
    }
}

- (IBAction)popBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // 使用 LBXScanZXingViewController 处理选中的图片
    //[self.zxScan setScanImage:selectedImage];
    //[self.zxScan scanImage];
    WS(ws);
    [ZXingWrapper recognizeImage:selectedImage block:^(ZXBarcodeFormat barcodeFormat, NSString *str) {
        NSLog(@"扫描结果 %@",str);
        if (str) {
            if (ws.screenSuccess) {
                ws.screenSuccess(str);
            }
            [ws.navigationController popViewControllerAnimated:YES];
        } else {
            NSLog(@"无法识别条形码");
            [MBProgressHUD showError:@"Barcode and QR code not recognized"];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)customizedScanDelegateForResult:(NSDictionary *)resultDic {
    WS(ws);
    dispatch_async(dispatch_get_main_queue(), ^{
        // 在主线程内处理数据
        NSLog(@"扫描结果: %@", resultDic);
        ResultPointModel *rltModel = [ResultPointModel yy_modelWithDictionary:resultDic];
        if (ws.screenSuccess && rltModel.parserDic.result && rltModel.parserDic.result.length > 0) {
            ws.screenSuccess(rltModel.parserDic.result);
            [ws.customVC pauseContinuouslyScan];
            [ws.navigationController popViewControllerAnimated:YES];
        }
    });
}

// 配置扫描样式
- (LBXScanViewStyle*)defaultStyle {
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    //扫码框中心位置与View中心位置上移偏移像素(一般扫码框在视图中心位置上方一点)
    style.centerUpOffset = 44;
    //扫码框周围4个角的类型设置为在框的上面,可自行修改查看效果
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_On;
    //扫码框周围4个角绘制线段宽度
    style.photoframeLineW = 2;
    //扫码框周围4个角水平长度
    style.photoframeAngleW = 38;
    //扫码框周围4个角垂直高度
    style.photoframeAngleH = 44;
    //动画类型：网格形式，模仿支付宝
    style.anmiationStyle = LBXScanViewAnimationStyle_NetGrid;
    //动画图片:网格图片
    style.animationImage = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_part_net"];
    //style.animationImage = [UIImage imageNamed:@"qrcode_scan_part_net"];
    //扫码框周围4个角的颜色
    //style.colorAngle = [UIColor colorWithRed:65./255. green:174./255. blue:57./255. alpha:1.0];
    style.colorAngle = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1.0];
    //是否显示扫码框
    style.isNeedShowRetangle = YES;
    //扫码框颜色
    style.colorRetangleLine = [UIColor colorWithRed:247/255. green:202./255. blue:15./255. alpha:0.0];
    //非扫码框区域颜色(扫码框周围颜色，一般颜色略暗)
    //必须通过[UIColor colorWithRed: green: blue: alpha:]来创建，内部需要解析成RGBA
    style.notRecoginitonArea = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    return style;
}

@end





















//@interface HYZBarCoderVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
//
//@property (nonatomic, strong) LBXScanZXingViewController *zxScan;
//
//@property (nonatomic, strong) CodeInputVC *inputVc;
//
//@property (nonatomic, weak) IBOutlet UIView *albumView;
//@property (nonatomic, weak) IBOutlet UIView *flashView;
//
//@property (nonatomic, weak) IBOutlet UIImageView *scanIcon;
//@property (nonatomic, weak) IBOutlet UIImageView *inputIcon;
//@property (nonatomic, weak) IBOutlet UILabel *scanLab;
//@property (nonatomic, weak) IBOutlet UILabel *inputLab;
//
//@end
//
//@implementation HYZBarCoderVC
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    self.navigationItem.title = @"Scan to Add";
//    
//    self.zxScan = [LBXScanZXingViewController new];
//    //self.zxScan.style = [StyleDIY OnStyle];
//    self.zxScan.style = [self defaultStyle];
//    WS(ws);
//    self.zxScan.screenSuccess = ^(NSString *codeString) {
//        NSLog(@"扫描结果: %@", codeString);
//        if (ws.screenSuccess) {
//            ws.screenSuccess(codeString);
//        }
//        [ws.navigationController popViewControllerAnimated:YES];
//    };
//    
//    self.inputVc = [CodeInputVC new];
//    [self addChildViewController:self.inputVc];
//    // 回调到web页
//    self.inputVc.addcode = ^(NSString * _Nonnull codeString) {
//        if (ws.screenSuccess) {
//            ws.screenSuccess(codeString);
//        }
//        [ws.navigationController popViewControllerAnimated:YES];
//    };
//    
//    [self addChildViewController:self.zxScan];
//    [self.previewV addSubview:self.zxScan.view];
//    
//    self.zxScan.view.frame = self.previewV.bounds;
//    [self.zxScan didMoveToParentViewController:self];
//}
//
///*切换各个标签内容*/
//- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)nowController{
//    nowController.view.frame = self.previewV.bounds;
//    [oldController willMoveToParentViewController:nil];
//    [self transitionFromViewController:oldController toViewController:nowController duration:0.3 options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
//        if (finished) {
//            [nowController didMoveToParentViewController:self];
//        }else{
//            
//        }
//    }];
//}
//
///** 切换扫码*/
//- (IBAction)scanning:(UIButton *)sender {
//    self.scanIcon.image = [UIImage imageNamed:@"manuallyEnter"];
//    self.inputIcon.image = [UIImage imageNamed:@"scanAdd"];
//    self.scanLab.textColor = [UIColor colorNamed:@"333333"];
//    self.inputLab.textColor = [UIColor colorNamed:@"8C8C8C"];
//    
//    self.albumView.hidden = NO;
//    self.flashView.hidden = NO;
//    
//    [self replaceController:self.inputVc newController:self.zxScan];
//}
//
///** 切换输入码*/
//- (IBAction)inputting:(UIButton *)sender {
//    self.scanIcon.image = [UIImage imageNamed:@"manuallyEnterSlt"];
//    self.inputIcon.image = [UIImage imageNamed:@"scanAddSlt"];
//    self.scanLab.textColor = [UIColor colorNamed:@"8C8C8C"];
//    self.inputLab.textColor = [UIColor colorNamed:@"333333"];
//    
//    self.albumView.hidden = YES;
//    self.flashView.hidden = YES;
//    
//    [self replaceController:self.zxScan newController:self.inputVc];
//}
//
//- (void)openPhotoLibrary {
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    picker.delegate = self;
//    [self presentViewController:picker animated:YES completion:nil];
//}
//
////开关闪光灯
//- (IBAction)openOrCloseFlash:(UIButton *)sender {
//    sender.selected = !sender.selected;
//    if (sender.selected) {
//        [sender setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
//    } else {
//        [sender setBackgroundImage:[UIImage imageNamed:@"cover"] forState:UIControlStateNormal];
//    }
//    [self.zxScan openOrCloseFlash];
//}
//
//- (IBAction)scanFromPhotoLibrary:(UIButton *)sender {
//    sender.selected = !sender.selected;
//    if (sender.selected) {
//        [sender setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
//    } else {
//        [sender setBackgroundImage:[UIImage imageNamed:@"cover"] forState:UIControlStateNormal];
//    }
//    
//    // 请求相册权限
//    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
//    if (status == PHAuthorizationStatusNotDetermined) {
//        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (status == PHAuthorizationStatusAuthorized) {
//                    [self openPhotoLibrary];
//                } else {
//                    [MBProgressHUD showError:@"Please allow access to the album in the settings"];
//                }
//            });
//            
//        }];
//    } else if (status == PHAuthorizationStatusAuthorized) {
//        [self openPhotoLibrary];
//    } else {
//        [MBProgressHUD showError:@"Please allow access to the album in the settings"];
//    }
//}
//
//- (IBAction)popBack:(UIButton *)sender {
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
//    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
//    [picker dismissViewControllerAnimated:YES completion:nil];
//    
//    // 使用 LBXScanZXingViewController 处理选中的图片
//    //[self.zxScan setScanImage:selectedImage];
//    //[self.zxScan scanImage];
//    WS(ws);
//    [ZXingWrapper recognizeImage:selectedImage block:^(ZXBarcodeFormat barcodeFormat, NSString *str) {
//        NSLog(@"扫描结果 %@",str);
//        if (str) {
//            if (ws.screenSuccess) {
//                ws.screenSuccess(str);
//            }
//            [ws.navigationController popViewControllerAnimated:YES];
//        } else {
//            NSLog(@"无法识别条形码");
//            [MBProgressHUD showError:@"Barcode and QR code not recognized"];
//        }
//    }];
//}
//
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [picker dismissViewControllerAnimated:YES completion:nil];
//}
//
//// 配置扫描样式
//- (LBXScanViewStyle*)defaultStyle {
//    //设置扫码区域参数
//    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
//    //扫码框中心位置与View中心位置上移偏移像素(一般扫码框在视图中心位置上方一点)
//    style.centerUpOffset = 44;
//    //扫码框周围4个角的类型设置为在框的上面,可自行修改查看效果
//    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_On;
//    //扫码框周围4个角绘制线段宽度
//    style.photoframeLineW = 2;
//    //扫码框周围4个角水平长度
//    style.photoframeAngleW = 38;
//    //扫码框周围4个角垂直高度
//    style.photoframeAngleH = 44;
//    //动画类型：网格形式，模仿支付宝
//    style.anmiationStyle = LBXScanViewAnimationStyle_NetGrid;
//    //动画图片:网格图片
//    style.animationImage = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_part_net"];
//    //style.animationImage = [UIImage imageNamed:@"qrcode_scan_part_net"];
//    //扫码框周围4个角的颜色
//    //style.colorAngle = [UIColor colorWithRed:65./255. green:174./255. blue:57./255. alpha:1.0];
//    style.colorAngle = [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1.0];
//    //是否显示扫码框
//    style.isNeedShowRetangle = YES;
//    //扫码框颜色
//    style.colorRetangleLine = [UIColor colorWithRed:247/255. green:202./255. blue:15./255. alpha:0.0];
//    //非扫码框区域颜色(扫码框周围颜色，一般颜色略暗)
//    //必须通过[UIColor colorWithRed: green: blue: alpha:]来创建，内部需要解析成RGBA
//    style.notRecoginitonArea = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
//    return style;
//}
//
//@end



/*
 @interface HYZBarCoderVC () <BarcodeScannerDelegate>
 
 @property (nonatomic, strong) BarcodeScanner *barcodeScanner;
 
 @end
 
 @implementation HYZBarCoderVC
 
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 self.navigationItem.title = @"Qcode Scan";
 
 self.barcodeScanner = [[BarcodeScanner alloc] initWithViewController:self];
 self.barcodeScanner.delegate = self;
 [self.barcodeScanner startScanning];
 }
 
 - (IBAction)startScanning:(id)sender {
 [self.barcodeScanner stopScanning];
 [self.barcodeScanner startScanning];
 }
 
 - (IBAction)scanFromPhotoLibrary:(id)sender {
 [self.barcodeScanner scanImageFromPhotoLibrary];
 }
 
 #pragma mark - BarcodeScannerDelegate
 
 - (void)didFindCode:(NSString *)code {
 NSLog(@"Found code: %@", code);
 // Handle the found code
 }
 
 - (void)didFailWithError:(NSError *)error {
 NSLog(@"Error: %@", error.localizedDescription);
 // Handle the error
 }
 
 @end
 */
