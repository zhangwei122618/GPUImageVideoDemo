//
//  CameraView.m
//  VideoDemo
//
//  Created by 张威 on 2018/7/22.
//  Copyright © 2018年 张威. All rights reserved.
//

#import "CameraView.h"
#import "LFGPUImageEmptyFilter.h"
#import "GPUImageBeautifyFilter.h"

#define kVideoSaveFolder @"Video"
typedef NS_ENUM(NSInteger, CameraManagerDevicePosition) {
    CameraManagerDevicePositionBack,
    CameraManagerDevicePositionFront,
};

@interface CameraView ()

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic, strong) GPUImageView *filteredVideoView;

// 一键美颜
@property (nonatomic ,strong) UIButton *beautyBtn;
// 切换摄像头
@property (nonatomic ,strong) UIButton *cameraPositionChangeBtn;
// 录制视频按钮
@property (nonatomic, strong) UIButton *videoRecordBtn;
// 从相册选择
@property (nonatomic, strong) UIButton *inputLocalVideoBtn;
// 完成录制
@property (nonatomic, strong) UIButton *finishRecordBtn;
// 撤销录制
@property (nonatomic, strong) UIButton *cancelBtn;
// 录制进度条
@property (nonatomic, strong) UIView* progressView;

@property (nonatomic, assign) CameraManagerDevicePosition position;

@property (nonatomic, strong) NSMutableArray *lastArray;
@property (nonatomic, strong) NSMutableArray* urlArray;

//@property (nonatomic, strong) UIView* btView;

@property (nonatomic, assign) BOOL isRecoding;

@property (nonatomic, strong)UIButton *recordDurationBtn;

@property (nonatomic, strong)UIImageView *breathLightView;

@property (nonatomic, copy)NSString *pathToMovie;

@end
@implementation CameraView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    // 创建视频保存路径
    [self createVideoFolder];
    
    [self initCamera];
    
    //
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraViewTapAction:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    [self.filteredVideoView addGestureRecognizer:singleFingerOne];
    [self addSubview:self.filteredVideoView];
    [self.filteredVideoView addSubview:self.progressView];
    //
    [self initTopView];
    [self initBottomView];
}

- (void)initTopView {
    
    UIView *topView = [[UIView alloc] init];
    [self.filteredVideoView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.centerX.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 44));
    }];
    
    UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"circle_arrow_left"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(clickBackToHome) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [topView addSubview:self.cameraPositionChangeBtn];
    [self.cameraPositionChangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(0);
    }];
    
    [topView addSubview:self.beautyBtn];
    [self.beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.cameraPositionChangeBtn.mas_left).offset(-15);
        make.centerY.mas_equalTo(0);
    }];
    
    [topView addSubview:self.recordDurationBtn];
    [self.recordDurationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
    
    [topView addSubview:self.breathLightView];
    [self.breathLightView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(0);
        make.right.equalTo(self.recordDurationBtn.mas_left).offset(-7);
    }];
}

- (void)initBottomView {
    
    UIView *bottomView = [[UIView alloc] init];
    [self.filteredVideoView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-50);
        make.centerX.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 100));
    }];
    
    UIView *bottomLeftView = [[UIView alloc] init];
    [bottomView addSubview:bottomLeftView];
    [bottomLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.bottom.mas_equalTo(-50);
        make.left.top.bottom.mas_equalTo(0);
        make.right.equalTo(bottomView.mas_centerX);
        //        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 100));
    }];
    
    UIView *bottomRightView = [[UIView alloc] init];
    [bottomView addSubview:bottomRightView];
    [bottomRightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.mas_equalTo(0);
        make.left.equalTo(bottomView.mas_centerX);
    }];
    
    
    [bottomView addSubview:self.videoRecordBtn];
    [self.videoRecordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
    
    [bottomLeftView addSubview:self.inputLocalVideoBtn];
    [self.inputLocalVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.mas_equalTo(0);
        //        make.right.equalTo(self.videoRecordBtn.mas_left).offset(-50);
        
    }];
    
    [bottomRightView addSubview:self.finishRecordBtn];
    [self.finishRecordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.mas_equalTo(0);
        //        make.left.equalTo(self.videoRecordBtn.mas_right).offset(50);
    }];
    
    
    [bottomLeftView addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        //        make.right.equalTo(self.videoRecordBtn.mas_left).offset(-50);
    }];
    
}

- (void)initCamera {
    
    if ([self.videoCamera.inputCamera lockForConfiguration:nil]) {
        //自动对焦
        if ([self.videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [self.videoCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动曝光
        if ([self.videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        //自动白平衡
        if ([self.videoCamera.inputCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [self.videoCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        [self.videoCamera.inputCamera unlockForConfiguration];
    }
    
    _position = CameraManagerDevicePositionBack;
    //    videoCamera.frameRate = 10;
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [self.videoCamera addAudioInputsAndOutputs];
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    
    self.filter = [[LFGPUImageEmptyFilter alloc] init];
    self.filteredVideoView = [[GPUImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.videoCamera addTarget:self.filter];
    [self.filter addTarget:self.filteredVideoView];
    [self.videoCamera startCameraCapture];
}

- (void)createVideoFolder {
    //沙盒中Temp路径
    NSString *tempPath = NSTemporaryDirectory();
    NSString *folderPath = [tempPath stringByAppendingPathComponent:kVideoSaveFolder];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建保存视频文件夹失败");
        }
    }
}


#pragma mark --- Button Action

- (void)startRecording:(UIButton *)sender {
    
}


// 呼吸灯动画
- (CABasicAnimation *)breathLightAnimation:(CGFloat)time {
    
    CABasicAnimation *animation =[CABasicAnimation animationWithKeyPath:@"opacity"];
    
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    
    animation.toValue = [NSNumber numberWithFloat:0.3f];//这是透明度。
    
    animation.autoreverses = YES;
    
    animation.duration = time;
    
    animation.repeatCount = MAXFLOAT;
    
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    return animation;
}


#pragma mark --- lazy load

- (GPUImageVideoCamera *)videoCamera {
    if (!_videoCamera) {
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    }
    return _videoCamera;
}

- (UIButton *)recordDurationBtn {
    
    if (!_recordDurationBtn) {
        _recordDurationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [_recordDurationBtn setImage:[UIImage imageNamed:@"circle_time_point"] forState:UIControlStateNormal];
        [_recordDurationBtn setTitle:[NSString stringWithFormat:@"00:00/00:%d",kVideoRecordDuration] forState:UIControlStateNormal];
        [_recordDurationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _recordDurationBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _recordDurationBtn;
}

- (UIButton *)cameraPositionChangeBtn {
    if (!_cameraPositionChangeBtn) {
        _cameraPositionChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 25, 30, 30)];
        UIImage* img2 = [UIImage imageNamed:@"cammera"];
        [_cameraPositionChangeBtn setImage:img2 forState:UIControlStateNormal];
        [_cameraPositionChangeBtn addTarget:self action:@selector(changeCameraPositionBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraPositionChangeBtn;
}
- (UIButton *)beautyBtn {
    if (!_beautyBtn) {
        _beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        _beautyBtn.frame = CGRectMake(SCREEN_WIDTH - 110,  25, 30.0, 30.0);
        UIImage* img = [UIImage imageNamed:@"beautyOFF"];
        [_beautyBtn setImage:img forState:UIControlStateNormal];
        [_beautyBtn setImage:[UIImage imageNamed:@"beautyON"] forState:UIControlStateSelected];
        [_beautyBtn addTarget:self action:@selector(changebeautifyFilterBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _beautyBtn;
}


- (UIButton *)videoRecordBtn {
    
    if (!_videoRecordBtn) {
        _videoRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoRecordBtn setImage:[UIImage imageNamed:@"circle_videoRecording_normal"] forState:UIControlStateNormal];
        [_videoRecordBtn setImage:[UIImage imageNamed:@"circle_videoRecording_selected"] forState:UIControlStateSelected];
        [_videoRecordBtn addTarget:self action:@selector(startRecording:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoRecordBtn;
}

- (UIButton *)inputLocalVideoBtn {
    if (!_inputLocalVideoBtn) {
        _inputLocalVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //    self.inputLocalVideoBtn.hidden = YES;
        _inputLocalVideoBtn.frame = CGRectMake( 50 , SCREEN_HEIGHT - 105.0, 50, 50.0);
        UIImage* img5 = [UIImage imageNamed:@"circle_localSource"];
        [_inputLocalVideoBtn setImage:img5 forState:UIControlStateNormal];
        [_inputLocalVideoBtn addTarget:self action:@selector(clickInputBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _inputLocalVideoBtn;
}

- (UIButton *)finishRecordBtn {
    if (!_finishRecordBtn) {
        _finishRecordBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishRecordBtn.hidden = YES;
        //        _finishRecordBtn.frame = CGRectMake(SCREEN_WIDTH - 100 , SCREEN_HEIGHT - 105.0, 52.6, 50.0);
        UIImage* img3 = [UIImage imageNamed:@"circle_finish"];
        [_finishRecordBtn setImage:img3 forState:UIControlStateNormal];
        [_finishRecordBtn addTarget:self action:@selector(stopRecording:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishRecordBtn;
}

- (UIButton *)cancelBtn {
    
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.hidden = YES;
        //        _cancelBtn.frame = CGRectMake( 50 , SCREEN_HEIGHT - 105.0, 50, 50.0);
        UIImage* img4 = [UIImage imageNamed:@"circle_delete"];
        [_cancelBtn setImage:img4 forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(clickDleBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIImageView *)breathLightView {
    if (!_breathLightView) {
        _breathLightView = [[UIImageView alloc] init];
        _breathLightView.image = [UIImage imageNamed:@"circle_time_point"];
    }
    return _breathLightView;
}

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , 0, 4)];
        _progressView.backgroundColor = Skin_Color;
    }
    return _progressView;
}

- (NSMutableArray *)lastArray {
    
    if (!_lastArray) {
        _lastArray = [NSMutableArray array];
    }
    return _lastArray;
}

- (NSMutableArray *)urlArray {
    
    if (!_urlArray) {
        _urlArray = [NSMutableArray array];
    }
    return _urlArray;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
















