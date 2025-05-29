//
//  VLOPlayerVC.m
//  STA
//
//  Created by admin on 2025/5/11.
//

#import "VLOPlayerVC.h"
#import <VLCKit/VLCKit.h>

@interface VLOPlayerVC () <VLCMediaPlayerDelegate>

@property (nonatomic, strong) VLCMediaPlayer *mediaPlayer;
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, assign) BOOL isFullscreen; // 是否全屏
@property (nonatomic, strong) UIButton *fullscreenButton; // 全屏按钮
@property (nonatomic, strong) UIButton *closeButton; // 关闭按钮
@property (nonatomic, strong) UIView *loadingOverlay; // 加载遮罩层
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator; // 加载动画


@end

@implementation VLOPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFullscreen = YES; // 默认全屏
    // 默认横屏
    [self setOrientation:UIInterfaceOrientationLandscapeRight];
    
    // 初始化视频视图
    self.videoView = [[UIView alloc] init];
    self.videoView.backgroundColor = [UIColor blackColor];
    self.videoView.userInteractionEnabled = NO;
    [self.view addSubview:self.videoView];
    self.videoView.translatesAutoresizingMaskIntoConstraints = NO; // 禁用 autoresizing
    // 设置 Auto Layout 约束
    [NSLayoutConstraint activateConstraints:@[
        [self.videoView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.videoView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.videoView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.videoView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    // 初始化播放器
    self.mediaPlayer = [[VLCMediaPlayer alloc] initWithOptions:@[
        @"--network-caching=1000",    // 全局网络缓存时间（单位：毫秒）
        @"--rtsp-tcp",               // 强制使用 TCP 传输
        @"--no-stats",               // 禁用统计信息（可减少性能开销）
        @"--clock-jitter=0",         // 禁用时间抖动
        @"--clock-synchro=0",        // 禁用时钟同步
        @"--network-caching=1000"    // 网络缓存时间（可选）
    ]];
    self.mediaPlayer.delegate = self;
    self.mediaPlayer.drawable = self.videoView; // 绑定视频输出
    
    // 初始化加载遮罩层
    self.loadingOverlay = [[UIView alloc] init];
    self.loadingOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5]; // 半透明黑色背景
    self.loadingOverlay.translatesAutoresizingMaskIntoConstraints = NO; // 禁用 autoresizing
    self.loadingOverlay.hidden = YES; // 默认隐藏
    [self.videoView addSubview:self.loadingOverlay];
    
    // 设置加载遮罩层的 Auto Layout 约束
    [NSLayoutConstraint activateConstraints:@[
        [self.loadingOverlay.topAnchor constraintEqualToAnchor:self.videoView.topAnchor],
        [self.loadingOverlay.leadingAnchor constraintEqualToAnchor:self.videoView.leadingAnchor],
        [self.loadingOverlay.trailingAnchor constraintEqualToAnchor:self.videoView.trailingAnchor],
        [self.loadingOverlay.bottomAnchor constraintEqualToAnchor:self.videoView.bottomAnchor]
    ]];
    
    // 初始化加载动画
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.color = [UIColor whiteColor]; // 设置加载动画颜色为白色
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO; // 禁用 autoresizing
    [self.loadingOverlay addSubview:self.activityIndicator];
    
    // 设置加载动画的 Auto Layout 约束
    [NSLayoutConstraint activateConstraints:@[
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.loadingOverlay.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.loadingOverlay.centerYAnchor]
    ]];
    
    // 初始化全屏按钮
    self.fullscreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullscreenButton.tintColor = [UIColor whiteColor];
    [self.fullscreenButton setImage:[UIImage systemImageNamed:@"arrow.up.left.and.arrow.down.right"] forState:UIControlStateNormal]; // 全屏图标
    self.fullscreenButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.fullscreenButton.layer.cornerRadius = 20;
    self.fullscreenButton.translatesAutoresizingMaskIntoConstraints = NO; // 禁用 autoresizing
    [self.fullscreenButton addTarget:self action:@selector(toggleFullscreen) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.fullscreenButton];
    
    // 设置全屏按钮的 Auto Layout 约束
    [NSLayoutConstraint activateConstraints:@[
        [self.fullscreenButton.widthAnchor constraintEqualToConstant:40],
        [self.fullscreenButton.heightAnchor constraintEqualToConstant:40],
        [self.fullscreenButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.fullscreenButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-20]
    ]];

    // 初始化关闭按钮
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.tintColor = [UIColor whiteColor];
    [self.closeButton setImage:[UIImage systemImageNamed:@"xmark"] forState:UIControlStateNormal]; // 关闭图标
    self.closeButton.tintColor = [UIColor whiteColor];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO; // 禁用 autoresizing
    [self.closeButton addTarget:self action:@selector(closePlayer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    // 设置关闭按钮的 Auto Layout 约束
    [NSLayoutConstraint activateConstraints:@[
        [self.closeButton.widthAnchor constraintEqualToConstant:40],
        [self.closeButton.heightAnchor constraintEqualToConstant:40],
        [self.closeButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.closeButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20]
    ]];
    
}

- (void)playWithLiveUrl:(NSString *)urlStr {
    NSURL *streamURL = [NSURL URLWithString:urlStr];
    VLCMedia *media = [VLCMedia mediaWithURL:streamURL];
    
    [media addOptions:@{
        @"rtsp-tcp": @(YES),          // 强制使用 TCP 传输（适用于 RTSP 流）
        @"clock-jitter": @(0),        // 禁用时间抖动（适用于低延迟场景）
        @"clock-synchro": @(0),       // 禁用时钟同步（适用于低延迟场景）
        @"--no-ssl-verify": @(YES),   // 忽略 SSL 验证
        @"--ignore-cert": @(YES),     // 忽略证书错误
        @"--no-video-toolbox": @(YES),// 禁用硬件加速
        @"network-caching": @(1000),  // 增加网络缓存（1秒）
        @"file-caching": @(1000),     // 文件缓存
        @"live-caching": @(1000)      // 直播缓存
    }];
    
    self.mediaPlayer.media = media;
    //[self.mediaPlayer play];
    if (self.mediaPlayer.isPlaying) {
        [self.mediaPlayer pause];
    }
    [self.mediaPlayer play];
    // 显示加载动画
    [self showLoadingIndicator];

}

- (void)play {
    if (self.mediaPlayer) {
        [self.mediaPlayer pause];
    }
    [self.mediaPlayer play];
}

#pragma mark - 加载动画显示与隐藏

- (void)showLoadingIndicator {
    self.loadingOverlay.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)hideLoadingIndicator {
    self.loadingOverlay.hidden = YES;
    [self.activityIndicator stopAnimating];
}


#pragma mark - 关闭播放器

- (void)closePlayer {
    [self setOrientation:UIInterfaceOrientationPortrait]; // 恢复竖屏
    WS(ws);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.34 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ws dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - 横竖屏切换

- (void)toggleFullscreen {
    self.isFullscreen = !self.isFullscreen;
    if (self.isFullscreen) {
        [self setOrientation:UIInterfaceOrientationLandscapeRight]; // 横屏
        [self.fullscreenButton setImage:[UIImage systemImageNamed:@"arrow.up.left.and.arrow.down.right"] forState:UIControlStateNormal]; // 全屏图标
    } else {
        [self setOrientation:UIInterfaceOrientationPortrait]; // 竖屏
        [self.fullscreenButton setImage:[UIImage systemImageNamed:@"arrow.down.right.and.arrow.up.left"] forState:UIControlStateNormal]; // 小屏图标
    }
}
- (void)setOrientation:(UIInterfaceOrientation)orientation {
    if (@available(iOS 16.0, *)) {
        UIWindowScene *windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
        [windowScene requestGeometryUpdateWithPreferences:[[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:(UIInterfaceOrientationMask)(1 << orientation)] errorHandler:nil];
    } else {
        [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
        [UIViewController attemptRotationToDeviceOrientation];
    }
}

- (void)updateLayoutForOrientation {
    if (self.isFullscreen) {
        self.videoView.frame = self.view.bounds;
    } else {
        self.videoView.frame = self.view.bounds;
    }
}

#pragma mark - 恢复竖屏

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self setOrientation:UIInterfaceOrientationPortrait]; // 恢复竖屏
    // 停止播放器
    [self.mediaPlayer stop];
}

#pragma mark - VLCMediaPlayerDelegate

- (void)mediaPlayerStateChanged:(VLCMediaPlayerState)newState {
    VLCMediaPlayerState state = self.mediaPlayer.state;
    NSLog(@"当前流状态: %ld", (long)state);
    
    switch (state) {
        case VLCMediaPlayerStateBuffering:
            NSLog(@"正在缓冲");
            [self showLoadingIndicator]; // 视频缓冲时显示加载动画
            break;
        case VLCMediaPlayerStatePlaying:
            NSLog(@"正在播放");
            [self hideLoadingIndicator]; // 视频开始播放时隐藏加载动画
            break;
        case VLCMediaPlayerStateError:
            NSLog(@"播放器发生错误：%@", self.mediaPlayer.media);
        case VLCMediaPlayerStateStopped:
        case VLCMediaPlayerStatePaused:
            NSLog(@"播放错误或结束、暂停");
            break;
        default:
            break;
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    NSString *time = self.mediaPlayer.time.stringValue;
    NSLog(@"当前播放时间：%@", time);
}

- (void)dealloc {
    // 移除播放器代理
    self.mediaPlayer.delegate = nil;
    
    // 释放播放器资源
    self.mediaPlayer = nil;
    
    // 停止加载动画
    [self.activityIndicator stopAnimating];
    self.activityIndicator = nil;
    
    // 清理其他资源
    self.loadingOverlay = nil;
    self.videoView = nil;
    
    NSLog(@"VLOPlayerVC 已释放");
}

@end
