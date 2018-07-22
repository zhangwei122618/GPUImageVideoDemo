//
//  CameraViewController.m
//  VideoDemo
//
//  Created by 张威 on 2018/7/22.
//  Copyright © 2018年 张威. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraView.h"
@interface CameraViewController ()

@property (nonatomic, strong)CameraView *cameraView;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark --- lazy load

- (CameraView *)cameraView {
    if (!_cameraView) {
        _cameraView = [[CameraView alloc] init];
    }
    
    return _cameraView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
