//
//  DashedBorderView.m
//  STA
//
//  Created by admin on 2024/8/4.
//

#import "DashedBorderView.h"
#import "YYHelper.h"

@implementation DashedBorderView {
    CAShapeLayer *_shapeLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDashedBorder];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupDashedBorder];
    }
    return self;
}

- (void)setupDashedBorder {
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.strokeColor = Color(@"78B1A6").CGColor;
    _shapeLayer.lineWidth = 4;
    _shapeLayer.lineDashPattern = @[@12, @4]; // 8 points line, 4 points space
    _shapeLayer.fillColor = nil; // Ensure the shape layer does not fill the path

    [self.layer addSublayer:_shapeLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Update the path when the view's bounds change
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    _shapeLayer.path = path.CGPath;
}

@end
