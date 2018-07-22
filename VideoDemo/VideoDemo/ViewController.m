//
//  ViewController.m
//  VideoDemo
//
//  Created by 张威 on 2018/7/22.
//  Copyright © 2018年 张威. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // record video
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"Start Record" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor cyanColor]];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(200, 50));
    }];
    
}

- (void)btnClick:(UIButton *)sender {
    
    CameraViewController *cameraVC = [[CameraViewController alloc] init];
    [self presentViewController:cameraVC animated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
