//
//  SignatureView.m
//  WeiDai_Native
//
//  Created by AFCA on 2017/2/24.
//  Copyright © 2017年 x9bank. All rights reserved.
//

#import "SignatureView.h"

@implementation SignatureView{
    CAShapeLayer *shapeLayer;
    UIBezierPath *beizerPath;
    UIImage *incrImage;
    CGPoint points[5];
    uint control;
    int minX,maxX,minY,maxY;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self myInit];
    }
    return self;
}

- (void)myInit {
    minX = minY = maxX = maxY = -1;
    self.backgroundColor = [UIColor whiteColor];
    [self setMultipleTouchEnabled:NO];
    beizerPath = [UIBezierPath bezierPath];
    beizerPath.lineWidth = 3;
    _isAlreadySignture = NO;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self myInit];
}

- (void)drawRect:(CGRect)rect
{
    [incrImage drawInRect:rect];
    [beizerPath stroke];
    
    UIColor *fillColor = [UIColor blackColor];
    [fillColor setFill];
    UIColor *strokeColor = [UIColor blackColor];
    [strokeColor setStroke];
    [beizerPath stroke];
}

#pragma mark - UIView Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    control = 0;
    UITouch *touch = [touches anyObject];
    points[0] = [touch locationInView:self];
    CGPoint startPoint = points[0];
    CGPoint endPoint = CGPointMake(startPoint.x + 1.5, startPoint.y
                                   + 2);
    if (minX == -1) {
        minX = startPoint.x;
    }
    if (maxX == -1) {
        maxX = startPoint.x;
    }
    if (minY == -1) {
        minY = startPoint.y;
    }
    if (maxY == -1) {
        maxY = startPoint.y;
    }
    
    
    
    [beizerPath moveToPoint:startPoint];
    [beizerPath addLineToPoint:endPoint];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    control++;
    points[control] = touchPoint;
    
    maxX = maxX > touchPoint.x ? maxX : touchPoint.x;
    minX = minX < touchPoint.x ? minX : touchPoint.x;
    maxY = maxY > touchPoint.y ? maxY : touchPoint.y;
    minY = minY < touchPoint.y ? minY : touchPoint.y;
    if (control == 4)
    {
        points[3] = CGPointMake((points[2].x + points[4].x)/2.0, (points[2].y + points[4].y)/2.0);
        
        [beizerPath moveToPoint:points[0]];
        [beizerPath addCurveToPoint:points[3] controlPoint1:points[1] controlPoint2:points[2]];
        
        [self setNeedsDisplay];
        
        points[0] = points[3];
        points[1] = points[4];
        control = 1;
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isAlreadySignture = YES;
    [self drawBitmapImage];
    [self setNeedsDisplay];
    [beizerPath removeAllPoints];
    control = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)drawBitmapImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    
    if (!incrImage)
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
    }
    [incrImage drawAtPoint:CGPointZero];
    
    UIColor *strokeColor = [UIColor blackColor];
    [strokeColor setStroke];
    [beizerPath stroke];
    incrImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)clearSignature
{
    incrImage = nil;
    _isAlreadySignture = NO;
    [self setNeedsDisplay];
}

- (UIImage *)getSignatureImage {
    minX = minX <= 0 ? 0 : minX;
    minY = minY <= 0 ? 0 : minY;
    maxX = maxX >= self.bounds.size.width ? self.bounds.size.width : maxX;
    maxY = maxY >= self.bounds.size.height ? self.bounds.size.height : maxY;
    float width = maxX - minX > 5 ? maxX - minX : 5;
    float height = maxY - minY > 5 ? maxY - minY : 5;
    minX = minX - 3;
    minY = minY - 3;
    width = width + 5;
    height = height + 5;
    int times = 0;
    if (IS_IPHONE_6_PLUS) {
        times = 3;
    }else {
        times = 2;
    }
    CGRect rect = CGRectMake(minX*times, minY*times, width*times, height*times);
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *signatureImage = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef newImageRef = CGImageCreateWithImageInRect([signatureImage CGImage], rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}


@end
