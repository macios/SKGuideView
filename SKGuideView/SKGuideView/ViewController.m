//
//  ViewController.m
//  SKGuideView
//
//  Created by ac-hu on 2018/9/30.
//  Copyright © 2018年 sk-hu. All rights reserved.
//

#import "ViewController.h"
#import "SKGuideView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;

@property (weak, nonatomic) IBOutlet UIView *view21;
@property (weak, nonatomic) IBOutlet UIView *view22;
@property (weak, nonatomic) IBOutlet UIView *view23;

@property (weak, nonatomic) IBOutlet UIView *view31;
@property (weak, nonatomic) IBOutlet UIView *view32;
@property (weak, nonatomic) IBOutlet UIView *view33;

@property (weak, nonatomic) IBOutlet UIView *view41;
@property (weak, nonatomic) IBOutlet UIView *view42;
@property (weak, nonatomic) IBOutlet UIView *view43;

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _view2.layer.cornerRadius = 10.f;
    _view2.layer.borderColor = [UIColor whiteColor].CGColor;
    _view2.layer.borderWidth = 1.;
    _view2.clipsToBounds = YES;
    
    _view3.layer.cornerRadius = 15.f;
    _view3.clipsToBounds = YES;
    [self guide];
}

-(void)guide{
    [SKGuideView share].font = [UIFont systemFontOfSize:14];
    [SKGuideView share].shapeType = SKGuideViewShapeTypeOval;
    [SKGuideView share].shapeAlpha = 0.8;
    [SKGuideView share].dataArr = @[@[_view1,_view2,_view3,_view21,_view22,_view23,_view31,_view32,_view33,_view41,_view42,_view43,_btn1],
                                    @[@"点击这里查看余额",@"点击这里查看李时珍的西瓜皮",@"点击这里查看无敌爆炸西瓜皮使肌肤开始收费健康是福司法解释开发商发顺丰收费健康是福司法解释开发商发顺丰",@"点击这里查看余额",@"点击这里查看李时珍的西瓜皮",@"点击这里查看无敌爆炸西瓜皮使肌肤开始收费健康是福司法解释开发商发顺丰收费健康是福司法解释开发商发顺丰",@"点击这里查看余额",@"点击这里查看李时珍的皮",@"无敌爆炸西瓜皮使肌肤开始收费健康是福司法解释开发商发顺丰收费健康是福司法解释开发商发顺丰",@"点击这里查看余额",@"点击这里查看李时珍的皮",@"点击这里查看无敌爆炸西瓜皮使肌肤开始收费健康是福司法解释开发商发顺丰收费健康是福司法解释开发商发顺丰",@"点击这里查看无敌爆炸西瓜皮使肌肤开始收费健康是福司法解释开发商发顺丰收费健康是福司法解释开发商发顺丰皮使肌肤开始收费健康是福司法解释开发商发顺丰收费健康是福司法"]];
}
@end
