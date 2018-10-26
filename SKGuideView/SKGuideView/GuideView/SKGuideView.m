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

#define SK_AngleToRadian(angle) ((angle) / 180.0 * M_PI)
#define SK_RadianToAngle(radian) ((radian) * (180.0 / M_PI))

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
@property(nonatomic,strong)UILabel *downLabel;
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
    self.frame = screenWindow.bounds;
    self.font = [UIFont systemFontOfSize:16];
    self.shapeAlpha = 0.7;
    self.shapeType = SKGuideViewShapeTypeImaginary;
    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [self addGestureRecognizer:ges];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - 44, SK_Height_Statusbar, 44, 44)];
    [btn setImage:[UIImage imageNamed:@"sk_close.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    CGFloat wide = [self textWideWithViewHeight:40 andStr:@"下一步" font:[UIFont boldSystemFontOfSize:20]] + 10;
    _downLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 15 - wide, [UIScreen mainScreen].bounds.size.height - 40 - (SK_Height_Statusbar > 20 ? 30 : 15), wide, 40)];
    _downLabel.textColor = [UIColor whiteColor];
    _downLabel.text = @"下一步";
    _downLabel.font = [UIFont boldSystemFontOfSize:20];
    _downLabel.textAlignment = NSTextAlignmentCenter;
    _downLabel.layer.cornerRadius = 4.f;
    _downLabel.clipsToBounds = YES;
    _downLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    _downLabel.layer.borderWidth = .5;
    [self addSubview:_downLabel];
    _downLabel.hidden = YES;
}


-(void)tapClick{
    if (_currentIndex == _viewArr.count) {
        [self dismiss];
        return;
    }
    [self setNeedsDisplay];
}

-(void)dismiss{
    _currentIndex = 0;
    [self removeFromSuperview];
}

-(void)setShapeType:(SKGuideViewShapeType)shapeType{
    _shapeType = shapeType;
    switch (shapeType) {
        case SKGuideViewShapeTypeOval:
            _downLabel.hidden = NO;
            break;
            
        case SKGuideViewShapeTypeImaginary:
            _downLabel.hidden = YES;
            break;
            
        default:
            break;
    }
}

-(void)setDataArr:(NSArray *)dataArr{
    _viewArr = dataArr.firstObject;
    _textArr = dataArr.lastObject;
    _dataArr = dataArr;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
    [self tapClick];
}

-(void)drawRect:(CGRect)rect{
    UIView *view = [_viewArr objectAtIndex:_currentIndex];
    _currentRect = [[UIApplication sharedApplication].keyWindow convertRect:view.frame fromView:view.superview];
    [self drawViewBorder];
    [self drawBubble];
    _currentIndex ++;
}

-(void)drawViewBorder{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:0 alpha:self.shapeAlpha].CGColor);
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
    
    if (self.shapeType == SKGuideViewShapeTypeImaginary){
        
        CGRect rect = CGRectMake(CGRectGetMinX(_currentRect) - 5, CGRectGetMinY(_currentRect) - 5, CGRectGetWidth(_currentRect) + 10, CGRectGetHeight(_currentRect) + 10);
        showPath = [UIBezierPath bezierPath];
        CGFloat beginX = CGRectGetMinX(rect);
        CGFloat beginY = CGRectGetMinY(rect);
        CGFloat maxX = CGRectGetMaxX(rect);
        CGFloat maxY = CGRectGetMaxY(rect);
        UIView *view = [_viewArr objectAtIndex:_currentIndex];
        CGFloat radius = view.layer.cornerRadius * (CGRectGetWidth(rect) / CGRectGetWidth(_currentRect));
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
        
        //设置线条样式
        CGContextSetLineCap(context, kCGLineCapSquare);
        //设置线条粗细宽度
        CGContextSetLineWidth(context, 2);
        //设置颜色
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextAddPath(context, showPath.CGPath);
    }
}

-(void)drawBubble{
    NSString *text = _textArr[_currentIndex];
    int quadrant = [self quadrant];
    CGFloat centerX = CGRectGetMidX(_currentRect);
    CGFloat minY = CGRectGetMinY(_currentRect);
    CGFloat maxY = CGRectGetMaxY(_currentRect);
    
    CGFloat rectMinX = 0;
    CGFloat rectMinY = 0;
    CGFloat rectWide = 20;
    CGFloat rectHeight = 16;
    CGRect drawRect = CGRectZero;
    CGRect drawRectOne = CGRectZero;
    CGRect drawRectTwo = CGRectZero;
    UIBezierPath *bezierPath;
    CGPoint onePoint = CGPointZero;
    CGPoint twoPoint = CGPointZero;
    CGPoint sPoints[3];//坐标点
    CGFloat arr[] = {4, 6};
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableDictionary *attribute = [NSMutableDictionary dictionaryWithDictionary:@{NSFontAttributeName:self.font,NSParagraphStyleAttributeName:paragraphStyle}];
    if (quadrant == 1) {
        rectMinY = minY - rectHeight - SK_ShapeSpace;
        rectMinX = centerX + SK_ShapeSpace - rectWide/2.;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        drawRectOne = drawRect;
        onePoint = CGPointMake(centerX, minY - 10);
        
        //绘制第二个椭圆
        drawRect = CGRectMake(CGRectGetMaxX(drawRect) + SK_ShapeSpace, CGRectGetMinY(drawRect) - 1.5 * rectHeight - SK_ShapeSpace, 1.5 * rectWide, 1.5 * rectHeight);
        drawRectTwo = drawRect;
        
        //绘制文本框
        rectMinX = CGRectGetMaxX(drawRect) + SK_ShapeSpace;
        rectWide = [self textWideWithViewHeight:20 andStr:text font:self.font] + SK_TextSpace * 2;
        if (rectWide > (self.frame.size.width - CGRectGetMaxX(drawRect) - SK_ShapeSpace - 15)) {
            rectWide = self.frame.size.width - CGRectGetMaxX(drawRect) - SK_ShapeSpace - 15;
        }
        
        rectHeight = [self textHeightWithViewWidth:rectWide andStr:text font:self.font] + SK_TextSpace * 2;
        rectMinY = CGRectGetMinY(drawRect) - rectHeight - SK_ShapeSpace;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        
        twoPoint = CGPointMake(CGRectGetMinX(drawRect) - 5 - 14, CGRectGetMidY(drawRect));
        
        //画三角形
        CGPoint triangleOne = CGPointMake(twoPoint.x + 14, twoPoint.y );
        CGPoint triangleTwo = CGPointMake(twoPoint.x, twoPoint.y - 7);
        CGPoint triangleThree = CGPointMake(twoPoint.x, twoPoint.y + 7);
        sPoints[0] = triangleOne;//坐标1
        sPoints[1] = triangleTwo;//坐标2
        sPoints[2] = triangleThree;//坐标3
    }else if (quadrant == 2){
        rectMinY = maxY + SK_ShapeSpace;
        rectMinX = centerX + SK_ShapeSpace - rectWide/2.;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        drawRectOne = drawRect;
        onePoint = CGPointMake(centerX, CGRectGetMaxY(_currentRect) + 10);
        
        //绘制第二个椭圆
        drawRect = CGRectMake(CGRectGetMaxX(drawRect) + SK_ShapeSpace, CGRectGetMaxY(drawRect) + SK_ShapeSpace, 1.5 * rectWide, 1.5 * rectHeight);
        drawRectTwo = drawRect;
        
        //绘制文本框
        rectMinX = CGRectGetMaxX(drawRect) + SK_ShapeSpace;
        rectWide = [self textWideWithViewHeight:20 andStr:text font:self.font] + SK_TextSpace * 2;
        if (rectWide > (self.frame.size.width - CGRectGetMaxX(drawRect) - SK_ShapeSpace - 15)) {
            rectWide = self.frame.size.width - CGRectGetMaxX(drawRect) - SK_ShapeSpace - 15;
        }
        rectHeight = [self textHeightWithViewWidth:rectWide andStr:text font:self.font] + SK_TextSpace * 2;
        rectMinY = CGRectGetMaxY(drawRect)  + SK_ShapeSpace;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        
        twoPoint = CGPointMake(CGRectGetMinX(drawRect) - 5 - 14, CGRectGetMidY(drawRect));
        
        //画三角形
        CGPoint triangleOne = CGPointMake(twoPoint.x + 14, twoPoint.y );
        CGPoint triangleTwo = CGPointMake(twoPoint.x, twoPoint.y - 7);
        CGPoint triangleThree = CGPointMake(twoPoint.x, twoPoint.y + 7);
        sPoints[0] = triangleOne;//坐标1
        sPoints[1] = triangleTwo;//坐标2
        sPoints[2] = triangleThree;//坐标3
        
        
    }else if (quadrant == 3){
        rectMinY = maxY + SK_ShapeSpace;
        rectMinX = centerX - SK_ShapeSpace - rectWide/2.;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        drawRectOne = drawRect;
        onePoint = CGPointMake(centerX, CGRectGetMaxY(_currentRect) + 10);
        
        //绘制第二个椭圆
        drawRect = CGRectMake(CGRectGetMinX(drawRect) - SK_ShapeSpace - 1.5 * rectWide, CGRectGetMaxY(drawRect) + SK_ShapeSpace, 1.5 * rectWide, 1.5 * rectHeight);
        drawRectTwo = drawRect;
        
        //绘制文本框
        rectWide = [self textWideWithViewHeight:20 andStr:text font:self.font] + SK_TextSpace * 2;
        if (rectWide > (CGRectGetMinX(drawRect) - SK_ShapeSpace - 15)) {
            rectWide = CGRectGetMinX(drawRect) - SK_ShapeSpace - 15;
        }
        rectMinX = CGRectGetMinX(drawRect) - rectWide -SK_ShapeSpace;
        rectHeight = [self textHeightWithViewWidth:rectWide andStr:text font:self.font] + SK_TextSpace * 2;
        rectMinY = CGRectGetMaxY(drawRect)  + SK_ShapeSpace;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        
        twoPoint = CGPointMake(CGRectGetMaxX(drawRect) + 5 + 14, CGRectGetMidY(drawRect));
        
        //画三角形
        CGPoint triangleOne = CGPointMake(twoPoint.x - 14, twoPoint.y );
        CGPoint triangleTwo = CGPointMake(twoPoint.x, twoPoint.y - 7);
        CGPoint triangleThree = CGPointMake(twoPoint.x, twoPoint.y + 7);
        sPoints[0] = triangleOne;//坐标1
        sPoints[1] = triangleTwo;//坐标2
        sPoints[2] = triangleThree;//坐标3
    }else{
        rectMinY = minY - rectWide - SK_ShapeSpace;
        rectMinX = centerX - SK_ShapeSpace - rectWide/2.;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        drawRectOne = drawRect;
        onePoint = CGPointMake(centerX, CGRectGetMinY(_currentRect) - 10);
        //绘制第二个椭圆
        drawRect = CGRectMake(CGRectGetMinX(drawRect) - SK_ShapeSpace - 1.5 * rectWide, CGRectGetMinY(drawRect) - 1.5 * rectHeight - SK_ShapeSpace, 1.5 * rectWide, 1.5 * rectHeight);
        drawRectTwo = drawRect;
        
        //绘制文本框
        rectWide = [self textWideWithViewHeight:20 andStr:text font:self.font] + SK_TextSpace * 2;
        if (rectWide > (CGRectGetMinX(drawRect) - SK_ShapeSpace - 15)) {
            rectWide = CGRectGetMinX(drawRect) - SK_ShapeSpace - 15;
        }
        rectMinX = CGRectGetMinX(drawRect) - rectWide -SK_ShapeSpace;
        rectHeight = [self textHeightWithViewWidth:rectWide andStr:text font:self.font] + SK_TextSpace * 2;
        rectMinY = CGRectGetMinY(drawRect) - rectHeight - SK_ShapeSpace;
        drawRect = CGRectMake(rectMinX, rectMinY, rectWide, rectHeight);
        
        twoPoint = CGPointMake(CGRectGetMaxX(drawRect) + 5 + 14, CGRectGetMidY(drawRect));
        
        //画三角形
        CGPoint triangleOne = CGPointMake(twoPoint.x - 14, twoPoint.y );
        CGPoint triangleTwo = CGPointMake(twoPoint.x, twoPoint.y - 7);
        CGPoint triangleThree = CGPointMake(twoPoint.x, twoPoint.y + 7);
        sPoints[0] = triangleOne;//坐标1
        sPoints[1] = triangleTwo;//坐标2
        sPoints[2] = triangleThree;//坐标3
        
    }
    
    
    
    if (self.shapeType == SKGuideViewShapeTypeOval) {
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:drawRect cornerRadius:SK_TextSpace];
        CGContextAddPath(context, bezierPath.CGPath);
        //绘制第一个椭圆
        bezierPath = [UIBezierPath bezierPathWithOvalInRect:drawRectOne];
        CGContextAddPath(context, bezierPath.CGPath);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
        
        //绘制第二个椭圆
        bezierPath = [UIBezierPath bezierPathWithOvalInRect:drawRectTwo];
        CGContextAddPath(context, bezierPath.CGPath);
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
    }else if (self.shapeType == SKGuideViewShapeTypeImaginary){
        paragraphStyle.alignment = NSTextAlignmentLeft;
        [attribute setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        [attribute setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        
        //设置线条样式
        CGContextSetLineCap(context, kCGLineCapSquare);
        //设置线条粗细宽度
        CGContextSetLineWidth(context, 2);
        //设置颜色
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);

        //连接上面定义的坐标点
        //设置虚线排列的宽度间隔:下面的arr中的数字表示先绘制3个点再绘制1个点
        //下面最后一个参数“2”代表排列的个数。
        CGContextSetLineDash(context, 1, arr, 2);
        
        //画曲线
        bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:onePoint];
        [bezierPath addQuadCurveToPoint:twoPoint controlPoint:CGPointMake(onePoint.x, twoPoint.y)];
        CGContextAddPath(context, bezierPath.CGPath);
        //下面最后一个参数“2”代表排列的个数。
        CGContextSetLineDash(context, 1, arr, 2);
        CGContextDrawPath(context, kCGPathStroke);
        
        //画三角形
        CGContextAddLines(context, sPoints, 3);//添加线
        CGContextClosePath(context);//封起来
        [[UIColor whiteColor] set];
        CGContextFillPath(context);
        
        //连接上面定义的坐标点
        //设置虚线排列的宽度间隔:下面的arr中的数字表示先绘制3个点再绘制1个点
        //下面最后一个参数“2”代表排列的个数。
        CGContextSetLineDash(context, 1, arr, 2);
        //画线
        CGContextDrawPath(context, kCGPathStroke);
    }
    drawRect = CGRectMake(CGRectGetMinX(drawRect) + SK_TextSpace, CGRectGetMinY(drawRect) + SK_TextSpace, CGRectGetWidth(drawRect) - SK_TextSpace * 2, CGRectGetHeight(drawRect) - SK_TextSpace * 2);
    
    [text drawWithRect:drawRect options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil];
    if (self.shapeType == SKGuideViewShapeTypeImaginary) {
        if (quadrant == 1) {
            drawRect = CGRectMake(CGRectGetMaxX(drawRect) - 110, CGRectGetMinY(drawRect) - 42 - 10, 110, 42);
        }else if(quadrant == 2){
            drawRect = CGRectMake(CGRectGetMaxX(drawRect) - 110, CGRectGetMaxY(drawRect) + 10, 110, 42);
        }else if(quadrant == 3){
            drawRect = CGRectMake(CGRectGetMinX(drawRect), CGRectGetMaxY(drawRect) + 10, 110, 42);
        }else{
            drawRect = CGRectMake(CGRectGetMinX(drawRect), CGRectGetMinY(drawRect) - 42 - 10, 110, 42);
        }
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:drawRect cornerRadius:4];
        CGContextAddPath(context, bezierPath.CGPath);
        //下面最后一个参数“2”代表排列的个数。
        CGContextSetLineDash(context, 1, arr, 2);
        CGContextDrawPath(context, kCGPathStroke);
        
        UIFont *font = [UIFont boldSystemFontOfSize:20];
        [attribute setObject:font forKey:NSFontAttributeName];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [attribute setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        rectHeight = [self textHeightWithViewWidth:MAXFLOAT andStr:@"知道了" font:font];
        drawRect = CGRectMake(CGRectGetMinX(drawRect) + 2, CGRectGetMinY(drawRect) + (CGRectGetHeight(drawRect) - rectHeight) / 2., CGRectGetWidth(drawRect), rectHeight);
        [@"知道了" drawWithRect:drawRect options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil];
    }
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
- (CGFloat)textHeightWithViewWidth:(CGFloat)viewWidth andStr:(NSString *)str font:(UIFont *)font{
    if (!font || str == nil) return 0;
    
    CGSize size = CGSizeMake(viewWidth,MAXFLOAT);
    //计算实际frame大小，并将label的frame变成实际大小
    CGSize txtSize;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        CGRect txtRT = [str boundingRectWithSize:size options:options attributes:@{NSFontAttributeName:font} context:nil];
        txtSize = txtRT.size;
    } else {
        SK_WarnDeprecatedStart
        txtSize = [str sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        SK_WarnDeprecatedEnd
    }
    return txtSize.height;
}
@end


