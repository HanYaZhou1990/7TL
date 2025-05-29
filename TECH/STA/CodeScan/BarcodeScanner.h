//
//  BarcodeScanner.h
//  STA
//
//  Created by admin on 2024/7/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BarcodeScannerDelegate <NSObject>
- (void)didFindCode:(NSString *)code;
- (void)didFailWithError:(NSError *)error;
@end


@interface BarcodeScanner : NSObject

@property (nonatomic, weak) id<BarcodeScannerDelegate> delegate;
@property (nonatomic, strong, readonly) UIView *previewView;

- (instancetype)initWithViewController:(UIViewController *)viewController;
- (void)startScanning;
- (void)stopScanning;
- (void)scanImageFromPhotoLibrary;


@end

NS_ASSUME_NONNULL_END
