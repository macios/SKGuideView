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
    [SKGuideView share].font = [UIFont systemFontOfSize:14];
    [SKGuideView share].dataArr = @[@[_view1,_view21,_view31,_view41],
          @[@"点击这里查看余额",@"李时珍的皮",@"无敌爆炸西瓜皮使肌肤开始收费健康是福司法解释开发商发顺丰",@"无敌爆炸西瓜皮使肌肤开始收费健康是福司法解释开发商发顺丰收费健康是福司法解释开发商发顺丰"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _view2.layer.cornerRadius = 10.f;
    _view2.layer.borderColor = [UIColor whiteColor].CGColor;
    _view2.layer.borderWidth = 1.;
    _view2.clipsToBounds = YES;
    
    _view3.layer.cornerRadius = 15.f;
    _view3.clipsToBounds = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
