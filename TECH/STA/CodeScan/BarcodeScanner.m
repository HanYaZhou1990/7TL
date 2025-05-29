//
//  BarcodeScanner.m
//  STA
//
//  Created by admin on 2024/7/7.
//

#import "BarcodeScanner.h"
#import <AVFoundation/AVFoundation.h>
#import "HYZBarCoderVC.h"

@interface BarcodeScanner () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) HYZBarCoderVC *vc;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIView *previewView;


@end


@implementation BarcodeScanner

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _vc = (HYZBarCoderVC *)viewController;
        [self setupScanner];
    }
    return self;
}

- (void)setupScanner {
    self.session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    [device lockForConfiguration:nil];
    CGFloat zoomFactor = 2.0; // 调整放大倍数
    if (device.activeFormat.videoMaxZoomFactor >= zoomFactor) {
        device.videoZoomFactor = zoomFactor;
    }
    [device unlockForConfiguration];
    
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        [self.delegate didFailWithError:error];
        return;
    }
    [self.session addInput:input];
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:output];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //output.metadataObjectTypes = output.availableMetadataObjectTypes;
    // 追加可扫码类型，防止无法扫描CODE128
    //output.metadataObjectTypes = [output.availableMetadataObjectTypes arrayByAddingObjectsFromArray:@[ AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode128Code ]];
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]]; // 可以添加更多类型

    
    // Setup preview layer
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    HYZBarCoderVC *crtVC = self.vc;
    // Setup preview view
    self.previewView = [[UIView alloc] initWithFrame:crtVC.previewV.bounds];
    self.previewLayer.frame = self.previewView.bounds;
    [self.previewView.layer addSublayer:self.previewLayer];
    [crtVC.previewV addSubview:self.previewView];
    
    CGRect rectOfInterest = [self.previewLayer metadataOutputRectOfInterestForRect:CGRectMake(16, 0, Main_Screen_Width - 32, 300)];
    output.rectOfInterest = rectOfInterest;
}

// 修改 QRScanner 类的 setupPreviewLayerInView 方法
- (void)setupPreviewLayerInView:(UIView *)view {
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.frame = view.layer.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [view.layer insertSublayer:self.previewLayer atIndex:0];
    
    // 添加绿色边框
    CAShapeLayer *cropLayer = [[CAShapeLayer alloc] init];
    CGRect cropRect = CGRectMake(50, 100, 200, 200); // 自定义扫描框位置和大小
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame))];
    UIBezierPath *cropPath = [UIBezierPath bezierPathWithRect:cropRect];
    [path appendPath:cropPath];
    cropLayer.path = path.CGPath;
    cropLayer.fillRule = kCAFillRuleEvenOdd;
    cropLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor; // 半透明背景
    cropLayer.borderColor = [UIColor greenColor].CGColor; // 绿色边框
    cropLayer.borderWidth = 2.0;
    [view.layer addSublayer:cropLayer];
}

- (void)startScanning {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![self.session isRunning]) {
            [self.session startRunning];
        }
    });
}

- (void)stopScanning {
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
}

- (void)restartScanning {
    [self stopScanning];
    [self startScanning];
}

- (void)scanImageFromPhotoLibrary {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self.vc presentViewController:picker animated:YES completion:nil];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        if ([metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            [self.delegate didFindCode:metadataObject.stringValue];
        } else {
            [self.delegate didFailWithError:[NSError errorWithDomain:@"BarcodeScanner" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Failed to read code"}]];
            [self restartScanning];
        }
    } else {
        [self.delegate didFailWithError:[NSError errorWithDomain:@"BarcodeScanner" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"No code found"}]];
        [self restartScanning];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self scanQRCodeFromImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)scanQRCodeFromImage:(UIImage *)image {
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:ciImage];
    for (CIQRCodeFeature *feature in features) {
        if (feature.messageString) {
            [self.delegate didFindCode:feature.messageString];
            return;
        }
    }
    NSError *error = [NSError errorWithDomain:@"BarcodeScanner" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"No QR code found in image"}];
    [self.delegate didFailWithError:error];
}

@end
