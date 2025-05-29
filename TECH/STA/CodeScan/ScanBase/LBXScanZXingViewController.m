//
//
//  
//
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "LBXScanZXingViewController.h"
#import <ZXResultPoint.h>
#import "MBProgressHUD+YY.h"

@interface LBXScanZXingViewController ()

@end

@implementation LBXScanZXingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor blackColor];
    self.isNeedScanImage = NO;
    self.isOpenInterestRect = YES;
    [self drawScanView];
    [self requestCameraPemissionWithResult:^(BOOL granted) {
        if (granted) {
            [self startScan];
        }else{
            //[self.qRScanView stopDeviceReadying];
            [MBProgressHUD hideHUDForView:self.codeFlagView];
        }
    }];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect rect = self.view.frame;
    rect.origin = CGPointMake(0, 0);
    self.qRScanView.frame = rect;
    self.cameraPreView.frame = self.view.bounds;
    if (_zxingObj) {
        [_zxingObj setVideoLayerframe:self.cameraPreView.frame];
    }
    [self.qRScanView stopScanAnimation];
    [self.qRScanView startScanAnimation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.firstLoad) {
        [self reStartDevice];
    }
}

//绘制扫描区域
- (void)drawScanView {
    if (!self.qRScanView) {
        self.qRScanView = [[LBXScanView alloc]initWithFrame:self.view.bounds style:self.style];
        [self.view insertSubview:self.qRScanView atIndex:1];
    }
    if (!self.cameraInvokeMsg) {
        self.cameraInvokeMsg = NSLocalizedString(@"waiting...", nil);
    }

}

- (void)reStartDevice {
    [self refreshLandScape];
    //[self.qRScanView startDeviceReadyingWithText:self.cameraInvokeMsg];
    [MBProgressHUD showMessage:self.cameraInvokeMsg toView:self.codeFlagView];
    
    if (_zxingObj) {
        _zxingObj.continuous = self.continuous;
        _zxingObj.orientation = [self videoOrientation];
        [_zxingObj start];
    }
}

//启动设备
- (void)startScan {
    if (!self.cameraPreView) {
        CGRect frame = self.view.bounds;
        UIView *videoView = [[UIView alloc]initWithFrame:frame];
        videoView.backgroundColor = [UIColor clearColor];
        [self.view insertSubview:videoView atIndex:0];
        
        self.cameraPreView = videoView;
    }
        
    __weak __typeof(self) weakSelf = self;
    if (!_zxingObj) {
        self.zxingObj = [[ZXingWrapper alloc]initWithPreView:self.cameraPreView success:^(ZXBarcodeFormat barcodeFormat, NSString *str, UIImage *scanImg, NSArray *resultPoints) {
            [weakSelf handZXingResult:barcodeFormat barStr:str scanImg:scanImg resultPoints:resultPoints];
        }];
        
        if (self.isOpenInterestRect) {
            //设置只识别框内区域
            CGRect cropRect = [LBXScanView getZXingScanRectWithPreView:self.cameraPreView style:self.style];
            [_zxingObj setScanRect:cropRect];
        }
    }
    _zxingObj.continuous = self.continuous;
    _zxingObj.orientation = [self videoOrientation];
    //[self.qRScanView startDeviceReadyingWithText:self.cameraInvokeMsg];
    [MBProgressHUD showMessage:self.cameraInvokeMsg toView:self.codeFlagView];

#if TARGET_OS_SIMULATOR
    
#else
    [_zxingObj start];
#endif
    
    _zxingObj.onStarted = ^{
    //[weakSelf.qRScanView stopDeviceReadying];
        [MBProgressHUD hideHUDForView:weakSelf.codeFlagView];
        [weakSelf.qRScanView startScanAnimation];
    };

    self.view.backgroundColor = [UIColor clearColor];
}

- (void)handZXingResult:(ZXBarcodeFormat)barcodeFormat barStr:(NSString*)str scanImg:(UIImage*)scanImg resultPoints:(NSArray*)resultPoints {
    LBXScanResult *result = [[LBXScanResult alloc]init];
    result.strScanned = str;
    result.imgScanned = scanImg;
    result.strBarCodeType = [self convertZXBarcodeFormat:barcodeFormat];
    
    NSLog(@"ZXing pts:%@",resultPoints);
    if (self.screenSuccess) {
        NSLog(@"---->扫描结果：%@",result.strScanned);
        self.screenSuccess(result.strScanned);
    }
    
    if (self.cameraPreView && resultPoints && scanImg) {
        
        CGFloat minx = 100000;
        CGFloat miny= 100000;
        CGFloat maxx = 0;
        CGFloat maxy= 0;
        
        for (ZXResultPoint *pt in resultPoints) {
            
            if (pt.x < minx) {
                minx = pt.x;
            }
            if (pt.x > maxx) {
                maxx = pt.x;
            }
            
            if (pt.y < miny) {
                miny = pt.y;
            }
            if (pt.y > maxy) {
                maxy = pt.y;
            }
        }
        
        CGSize imgSize = scanImg.size;
        CGSize preViewSize = self.cameraPreView.frame.size;
        minx = minx / imgSize.width * preViewSize.width;
        maxx = maxx / imgSize.width * preViewSize.width;
        miny = miny / imgSize.height * preViewSize.height;
        maxy = maxy / imgSize.height * preViewSize.height;
        
        result.bounds = CGRectMake(minx, miny,  maxx - minx,maxy - miny);
        
        NSLog(@"bounds:%@",NSStringFromCGRect(result.bounds));
        
        [self scanResultWithArray:@[result]];
    }
    else
    {
        [self scanResultWithArray:@[result]];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stopScan];
    [self.qRScanView stopScanAnimation];

}

- (void)stopScan {
    [_zxingObj stop];
}


//开关闪光灯
- (void)openOrCloseFlash {
    [_zxingObj openOrCloseTorch];

    self.isOpenFlash =!self.isOpenFlash;
}


#pragma mark- 旋转
- (void)refreshLandScape {
    if ([self isLandScape]) {
        self.style.centerUpOffset = 20;
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        CGFloat h = [UIScreen mainScreen].bounds.size.height;
        CGFloat max = MAX(w, h);
        CGFloat min = MIN(w, h);
        CGFloat scanRetangeH = min / 3;
        self.style.xScanRetangleOffset = max / 2 - scanRetangeH / 2;
    } else {
        self.style.centerUpOffset = 40;
        self.style.xScanRetangleOffset = 60;
    }
    self.qRScanView.viewStyle = self.style;
    [self.qRScanView setNeedsDisplay];
}


- (void)statusBarOrientationChanged:(NSNotification*)notification {
    [self refreshLandScape];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (_zxingObj) {
        _zxingObj.orientation = [self videoOrientation];
    }
    
    [self.qRScanView stopScanAnimation];
    
    [self.qRScanView startScanAnimation];
}

- (NSString*)convertZXBarcodeFormat:(ZXBarcodeFormat)barCodeFormat {
    NSString *strAVMetadataObjectType = nil;
    
    switch (barCodeFormat) {
        case kBarcodeFormatQRCode:
            strAVMetadataObjectType = AVMetadataObjectTypeQRCode;
            break;
        case kBarcodeFormatEan13:
            strAVMetadataObjectType = AVMetadataObjectTypeEAN13Code;
            break;
        case kBarcodeFormatEan8:
            strAVMetadataObjectType = AVMetadataObjectTypeEAN8Code;
            break;
        case kBarcodeFormatPDF417:
            strAVMetadataObjectType = AVMetadataObjectTypePDF417Code;
            break;
        case kBarcodeFormatAztec:
            strAVMetadataObjectType = AVMetadataObjectTypeAztecCode;
            break;
        case kBarcodeFormatCode39:
            strAVMetadataObjectType = AVMetadataObjectTypeCode39Code;
            break;
        case kBarcodeFormatCode93:
            strAVMetadataObjectType = AVMetadataObjectTypeCode93Code;
            break;
        case kBarcodeFormatCode128:
            strAVMetadataObjectType = AVMetadataObjectTypeCode128Code;
            break;
        case kBarcodeFormatDataMatrix:
            strAVMetadataObjectType = AVMetadataObjectTypeDataMatrixCode;
            break;
        case kBarcodeFormatITF:
            strAVMetadataObjectType = AVMetadataObjectTypeITF14Code;
            break;
        case kBarcodeFormatRSS14:
            break;
        case kBarcodeFormatRSSExpanded:
            break;
        case kBarcodeFormatUPCA:
            break;
        case kBarcodeFormatUPCE:
            strAVMetadataObjectType = AVMetadataObjectTypeUPCECode;
            break;
        default:
            break;
    }
    
    return strAVMetadataObjectType;
}

@end
