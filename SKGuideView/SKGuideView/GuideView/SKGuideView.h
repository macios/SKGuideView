//
//  SKGuideView.h
//  SKGuideView
//
//  Created by ac-hu on 2018/9/30.
//  Copyright © 2018年 sk-hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKGuideView : UIView


@property(nonatomic,strong)NSArray *dataArr;
@property(nonatomic,strong)UIFont *font;

+(instancetype)share;

@end
