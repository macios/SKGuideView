//
//  SKGuideView.h
//  SKGuideView
//
//  Created by ac-hu on 2018/9/30.
//  Copyright © 2018年 sk-hu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SKGuideViewShapeTypeOval,
    SKGuideViewShapeTypeImaginary ,
} SKGuideViewShapeType;

@interface SKGuideView : UIView

@property(nonatomic,assign)SKGuideViewShapeType shapeType;
@property(nonatomic,strong)NSArray *dataArr;
@property(nonatomic,strong)UIFont *font;
@property(nonatomic,assign)CGFloat shapeAlpha;

+(instancetype)share;

@end
