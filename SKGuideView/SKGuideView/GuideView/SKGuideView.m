//
//  SKGuideView.m
//  SKGuideView
//
//  Created by ac-hu on 2018/9/30.
//  Copyright © 2018年 sk-hu. All rights reserved.
//

#import "SKGuideView.h"

#define SK_TextSpace 5.
#define SK_ShapeSpace 10.

#define SK_Height_Statusbar  [[UIApplication sharedApplication] statusBarFrame].size.height  //状态栏高

#define SK_ArgumentToString(macro) #macro
#define SK_ClangWarningConcat(warning_name) SK_ArgumentToString(clang diagnostic ignored warning_name)
#define SK_WarnDeprecatedStart _Pragma("clang diagnostic push") _Pragma(SK_ClangWarningConcat("-Wdeprecated-declarations"))
#define SK_WarnDeprecatedEnd _Pragma("clang diagnostic pop")

@interface SKGuideView()

@property(nonatomic,assign)int currentIndex;
@property(nonatomic,assign)CGRect currentRect;
@property(nonatomic,strong)NSArray<UIView *> *viewArr;
@property(nonatomic,strong)NSArray<NSString *> *textArr;

@end

@implementation SKGuideView

+(instancetype)share{
    static SKGuideView *guideView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (guideView == nil) {
            guideView = [[SKGuideView alloc]init];
            [guideView defaultConfig];
        }
    });
    return guideView;
}

-(void)defaultConfig{
    UIWindow *screenWindow = [UIApplication sharedApplication].keyWindow;
    self.frame = CGRectMake(0, 0, screenWindow.bounds.size.width, screenWindow.bounds.size.height);
    [screenWindow addSubview:self];
    self.font = [UIFont systemFontOfSize:16];
    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [self addGestureRecognizer:ges];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - 44, SK_Height_Statusbar, 44, 44)];
    [btn setImage:[UIImage imageNamed:@"sk_close.png"] forState:UIControlStateNormal];
    btn.layer.cornerRadius = 22.f;
    btn.clipsToBounds = YES;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.layer.borderWidth = .5;
    [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    CGFloat wide = [self textWideWithViewHeight:40 andStr:@"下一步" font:[UIFont boldSystemFontOfSize:20]] + 10;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - wide, [UIScreen mainScreen].bounds.size.height - 40 - (SK_Height_Statusbar > 20 ? 30 : 15), wide, 40)];
    label.textColor = [UIColor whiteColor];
    label.text = @"下一步";
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 4.f;
    label.clipsToBounds = YES;
    label.layer.borderColor = [UIColor whiteColor].CGColor;
    label.layer.borderWidth = .5;
    [self addSubview:label];
}


-(void)tapClick{
    if (_currentIndex == _viewArr.count) {
        [self removeFromSuperview];
        return;
    }
    [self setNeedsDisplay];
}

-(void)dismiss{
    _currentIndex = 0;
    [self removeFromSuperview];
}

-(void)setDataArr:(NSArray *)dataArr{
    _viewArr = dataArr.firstObject;
    _textArr = dataArr.lastObject;
    _dataArr = dataArr;
    [self tapClick];
}

-(void)drawRect:(CGRect)rect{
    UIView *view = [_viewArr objectAtIndex:_currentIndex];
    _currentRect = [[UIApplication sharedApplication].keyWindow convertRect:view.frame fromView:view.superview];
    [self drawViewBorder];
    [self drawBubble];
    _currentIndex ++;
}

-(void)drawBubble{
    NSString *text = _textArr[_currentIndex];
    int quadrant = [self quadrant];
    NSLog(@"%d",quadrant);
    CGFloat centerX = CGRectGetMidX(_currentRect);
    CGFloat minY = CGRectGetMinY(_currentRect);
    CGFloat maxY = CGRectGetMaxY(_currentRect);
    
    CGFloat rectMinX = 0;
    CGFloat rectMinY = 0;
    CGFloat rectWide = 20;
    CGFloat rectHeight = 16;
    CGRect drawRect = CGRectZero;
    if (quadrant == 1) {
        rectMinY = minY - rectHeight - SK_ShapeSpace;
        rectMinX = centerX + SK_ShapeSpace - rectWide/2.;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        
        //绘制第一个椭圆
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIBezierPath * oval= [UIBezierPath bezierPathWithOvalInRect:drawRect];
        CGContextAddPath(context, oval.CGPath);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
        
        //绘制第二个椭圆
        drawRect = CGRectMake(CGRectGetMaxX(drawRect) + SK_ShapeSpace, CGRectGetMinY(drawRect) - 1.5 * rectHeight - SK_ShapeSpace, 1.5 * rectWide, 1.5 * rectHeight);
        oval= [UIBezierPath bezierPathWithOvalInRect:drawRect];
        CGContextAddPath(context, oval.CGPath);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
        
        //绘制文本框
        rectMinX = CGRectGetMaxX(drawRect) + SK_ShapeSpace;
        rectWide = [self textWideWithViewHeight:20 andStr:text font:self.font] + SK_TextSpace * 2;
        if (rectWide > (self.frame.size.width - CGRectGetMaxX(drawRect) - SK_ShapeSpace - 15)) {
            rectWide = self.frame.size.width - CGRectGetMaxX(drawRect) - SK_ShapeSpace - 15;
        }
        
        rectHeight = [self textHeightWithViewWidth:rectWide andStr:text] + SK_TextSpace * 2;
        rectMinY = CGRectGetMinY(drawRect) - rectHeight - SK_ShapeSpace;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:drawRect cornerRadius:SK_TextSpace];
        CGContextAddPath(context, bezierPath.CGPath);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
    }else if (quadrant == 2){
        rectMinY = maxY + SK_ShapeSpace;
        rectMinX = centerX + SK_ShapeSpace - rectWide/2.;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        
        //绘制第一个椭圆
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIBezierPath * oval= [UIBezierPath bezierPathWithOvalInRect:drawRect];
        CGContextAddPath(context, oval.CGPath);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
        
        //绘制第二个椭圆
        drawRect = CGRectMake(CGRectGetMaxX(drawRect) + SK_ShapeSpace, CGRectGetMaxY(drawRect) + SK_ShapeSpace, 1.5 * rectWide, 1.5 * rectHeight);
        oval= [UIBezierPath bezierPathWithOvalInRect:drawRect];
        CGContextAddPath(context, oval.CGPath);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
        
        //绘制文本框
        rectMinX = CGRectGetMaxX(drawRect) + SK_ShapeSpace;
        rectWide = [self textWideWithViewHeight:20 andStr:text font:self.font] + SK_TextSpace * 2;
        if (rectWide > (self.frame.size.width - CGRectGetMaxX(drawRect) - SK_ShapeSpace - 15)) {
            rectWide = self.frame.size.width - CGRectGetMaxX(drawRect) - SK_ShapeSpace - 15;
        }
        rectHeight = [self textHeightWithViewWidth:rectWide andStr:text] + SK_TextSpace * 2;
        rectMinY = CGRectGetMaxY(drawRect)  + SK_ShapeSpace;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:drawRect cornerRadius:SK_TextSpace];
        CGContextAddPath(context, bezierPath.CGPath);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
    }else if (quadrant == 3){
        rectMinY = maxY + SK_ShapeSpace;
        rectMinX = centerX - SK_ShapeSpace - rectWide/2.;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        
        //绘制第一个椭圆
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIBezierPath * oval= [UIBezierPath bezierPathWithOvalInRect:drawRect];
        CGContextAddPath(context, oval.CGPath);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
        
        //绘制第二个椭圆
        drawRect = CGRectMake(CGRectGetMinX(drawRect) - SK_ShapeSpace - 1.5 * rectWide, CGRectGetMaxY(drawRect) + SK_ShapeSpace, 1.5 * rectWide, 1.5 * rectHeight);
        oval= [UIBezierPath bezierPathWithOvalInRect:drawRect];
        CGContextAddPath(context, oval.CGPath);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
        
        //绘制文本框
        rectWide = [self textWideWithViewHeight:20 andStr:text font:self.font] + SK_TextSpace * 2;
        if (rectWide > (CGRectGetMinX(drawRect) - SK_ShapeSpace - 15)) {
            rectWide = CGRectGetMinX(drawRect) - SK_ShapeSpace - 15;
        }
        rectMinX = CGRectGetMinX(drawRect) - rectWide -SK_ShapeSpace;
        rectHeight = [self textHeightWithViewWidth:rectWide andStr:text] + SK_TextSpace * 2;
        rectMinY = CGRectGetMaxY(drawRect)  + SK_ShapeSpace;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:drawRect cornerRadius:SK_TextSpace];
        CGContextAddPath(context, bezierPath.CGPath);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
    }else{
        rectMinY = minY - rectWide - SK_ShapeSpace;
        rectMinX = centerX - SK_ShapeSpace - rectWide/2.;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        
        //绘制第一个椭圆
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIBezierPath * oval= [UIBezierPath bezierPathWithOvalInRect:drawRect];
        CGContextAddPath(context, oval.CGPath);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
        
        //绘制第二个椭圆
        drawRect = CGRectMake(CGRectGetMinX(drawRect) - SK_ShapeSpace - 1.5 * rectWide, CGRectGetMinY(drawRect) - 1.5 * rectHeight - SK_ShapeSpace, 1.5 * rectWide, 1.5 * rectHeight);
        oval= [UIBezierPath bezierPathWithOvalInRect:drawRect];
        CGContextAddPath(context, oval.CGPath);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
        
        //绘制文本框
        rectWide = [self textWideWithViewHeight:20 andStr:text font:self.font] + SK_TextSpace * 2;
        if (rectWide > (CGRectGetMinX(drawRect) - SK_ShapeSpace - 15)) {
            rectWide = CGRectGetMinX(drawRect) - SK_ShapeSpace - 15;
        }
        rectMinX = CGRectGetMinX(drawRect) - rectWide -SK_ShapeSpace;
        rectHeight = [self textHeightWithViewWidth:rectWide andStr:text] + SK_TextSpace * 2;
        rectMinY = CGRectGetMinY(drawRect) - rectHeight - SK_ShapeSpace;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:drawRect cornerRadius:SK_TextSpace];
        CGContextAddPath(context, bezierPath.CGPath);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
    }
    //绘制文本
    drawRect = CGRectMake(CGRectGetMinX(drawRect) + SK_TextSpace, CGRectGetMinY(drawRect) + SK_TextSpace, CGRectGetWidth(drawRect) - SK_TextSpace * 2, CGRectGetHeight(drawRect) - SK_TextSpace * 2);
    [text drawInRect:drawRect withAttributes:@{NSFontAttributeName : self.font}];
}

//存在相对视图的第几象限绘制
-(int)quadrant{
    float topDistance = CGRectGetMinY(_currentRect);
    float leftDistance = CGRectGetMinX(_currentRect);
    float botDistance = CGRectGetHeight(self.frame) - CGRectGetMaxY(_currentRect);
    float rightDistance = CGRectGetWidth(self.frame) - CGRectGetMaxX(_currentRect);
    
    NSArray<NSNumber *> *arr = @[@(topDistance),@(leftDistance),@(botDistance),@(rightDistance)];
    
    arr = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return NSOrderedDescending;
        } else if ([obj1 integerValue] < [obj2 integerValue]) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    if (([arr.firstObject floatValue] == botDistance && [arr[1] floatValue] == leftDistance) || ([arr.firstObject floatValue] == leftDistance && [arr[1] floatValue] == botDistance)) {
        return 1;
    }else if (([arr.firstObject floatValue] == topDistance && [arr[1] floatValue] == leftDistance) || ([arr.firstObject floatValue] == leftDistance && [arr[1] floatValue] == topDistance)){
        return 2;
    }else if (([arr.firstObject floatValue] == topDistance && [arr[1] floatValue] == rightDistance) || ([arr.firstObject floatValue] == rightDistance && [arr[1] floatValue] == topDistance)){
        return 3;
    }else{
        return 4;
    }
}

-(void)drawViewBorder{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor);
    UIBezierPath *fullPath  = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *showPath = [UIBezierPath bezierPath];
    
    
    CGFloat beginX = CGRectGetMinX(_currentRect);
    CGFloat beginY = CGRectGetMinY(_currentRect);
    CGFloat maxX = CGRectGetMaxX(_currentRect);
    CGFloat maxY = CGRectGetMaxY(_currentRect);
    UIView *view = [_viewArr objectAtIndex:_currentIndex];
    CGFloat radius = view.layer.cornerRadius;
    [showPath moveToPoint:CGPointMake(beginX + radius, beginY)];
    [showPath addLineToPoint:CGPointMake(maxX - radius, beginY)];
    [showPath addArcWithCenter:CGPointMake(maxX - radius, beginY + radius) radius:radius startAngle:1.5 * M_PI endAngle:0 clockwise:YES];
    [showPath addLineToPoint:CGPointMake(maxX, maxY - radius)];
    [showPath addArcWithCenter:CGPointMake(maxX - radius, maxY - radius) radius:radius startAngle:0 endAngle:0.5 * M_PI clockwise:YES];
    [showPath addLineToPoint:CGPointMake(beginX + radius, maxY)];
    [showPath addArcWithCenter:CGPointMake(beginX + radius, maxY - radius) radius:radius startAngle:0.5 * M_PI endAngle:M_PI clockwise:YES];
    [showPath addLineToPoint:CGPointMake(beginX, beginY + radius)];
    [showPath addArcWithCenter:CGPointMake(beginX + radius, beginY + radius) radius:radius startAngle:M_PI endAngle:1.5 * M_PI clockwise:YES];
    [showPath closePath];
    
    [fullPath appendPath:[showPath bezierPathByReversingPath]];
    CGContextAddPath(context, fullPath.CGPath);
    CGContextFillPath(context);
}

// 计算文字的宽度 (高固定)
- (CGFloat)textWideWithViewHeight:(CGFloat)viewHeight andStr:(NSString *)str font:(UIFont *)font{
    if (!font) return CGSizeZero.width;
    
    if (str == nil) return CGSizeZero.width;
    
    CGSize size = CGSizeMake(MAXFLOAT,viewHeight);
    
    //计算实际frame大小，并将label的frame变成实际大小
    CGSize txtSize;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        CGRect txtRT = [str boundingRectWithSize:size options:options attributes:@{NSFontAttributeName:font} context:nil];
        txtSize = txtRT.size;
    } else {
        SK_WarnDeprecatedStart
        txtSize = [str sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        SK_WarnDeprecatedEnd
    }
    return txtSize.width;
}


// 计算文字的高度 (宽度固定)
- (CGFloat)textHeightWithViewWidth:(CGFloat)viewWidth andStr:(NSString *)str{
    if (!self.font || str == nil) return 0;
    
    CGSize size = CGSizeMake(viewWidth,MAXFLOAT);
    //计算实际frame大小，并将label的frame变成实际大小
    CGSize txtSize;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        CGRect txtRT = [str boundingRectWithSize:size options:options attributes:@{NSFontAttributeName:self.font} context:nil];
        txtSize = txtRT.size;
    } else {
        SK_WarnDeprecatedStart
        txtSize = [str sizeWithFont:self.font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        SK_WarnDeprecatedEnd
    }
    return txtSize.height;
}
@end

