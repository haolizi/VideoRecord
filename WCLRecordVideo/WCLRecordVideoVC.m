//
//  YQRecordVideoVC.m
//  Youqun
//
//  Created by 王崇磊 on 16/5/16.
//  Copyright © 2016年 W_C__L. All rights reserved.
//

#import "WCLRecordVideoVC.h"
#import "WCLRecordEngine.h"
#import "WCLRecordProgressView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMotion/CoreMotion.h>
#import "MoviePlayController.h"

@interface WCLRecordVideoVC ()<WCLRecordEngineDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *flashLightBT;
@property (weak, nonatomic) IBOutlet UIButton *changeCameraBT;
@property (weak, nonatomic) IBOutlet UIButton *recordNextBT;
@property (weak, nonatomic) IBOutlet UIButton *recordBt;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTop;
@property (weak, nonatomic) IBOutlet UILabel *maxTimeLB;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLB;
@property (weak, nonatomic) IBOutlet WCLRecordProgressView *progressView;
@property (strong, nonatomic) WCLRecordEngine *recordEngine;
@property (assign, nonatomic) BOOL            allowRecord;//允许录制
@property (strong, nonatomic) UIImagePickerController *moviePicker;//视频选择器
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) UIInterfaceOrientation orientationLast;
@property (nonatomic, strong) UIImageView *focusImgView;//聚焦

@end

@implementation WCLRecordVideoVC

- (void)dealloc {
    _recordEngine = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if([self.motionManager isAccelerometerAvailable]){
        [self orientationChange];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_recordEngine == nil) {
        [self.recordEngine previewLayer].frame = self.view.bounds;
        [self.view.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
    }
    [self.recordEngine startUp];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allowRecord = YES;
    [self addFocusView];//添加手动聚焦View
    [self addGenstureRecognizer];//添加点按手势
    
    if (0 == self.maxRecordTime) {
        self.maxRecordTime = 5*60;//默认最大录制时间为5分钟
    }
    self.maxTimeLB.text = [NSString stringWithFormat:@"/ %@", [self timeFormatted:self.maxRecordTime]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.motionManager stopAccelerometerUpdates];
    self.motionManager = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.recordEngine shutdown];
}

- (void)addFocusView {
    _focusImgView = [[UIImageView alloc] init];
    _focusImgView.backgroundColor = [UIColor clearColor];
    _focusImgView.image = [UIImage imageNamed:@"focuse"];
    _focusImgView.hidden = YES;
    _focusImgView.alpha = 0;
    [self.view addSubview:_focusImgView];
}

/**
 *  添加点按手势，点按时聚焦
 */
- (void)addGenstureRecognizer {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point = [tapGesture locationInView:self.view];
    [self deailTapGestureWithPoint:point];
    [self.recordEngine setFocusCursorWithPoint:point];
}

//点击聚焦动画
- (void)deailTapGestureWithPoint:(CGPoint)point {
    _focusImgView.hidden = NO;
    _focusImgView.frame = CGRectMake(point.x - 50, point.y - 50, 100, 100);
    [UIView animateWithDuration:0.4 animations:^{
        _focusImgView.frame = CGRectMake(point.x - 30, point.y - 30, 60, 60);
        _focusImgView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            _focusImgView.alpha = 0;
        }];
    }];
}

//根据状态调整view的展示情况
- (void)adjustViewFrame {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (self.recordBt.selected) {
            self.topViewTop.constant = -64;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }
        else {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            self.topViewTop.constant = 0;
        }
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - set、get方法
- (WCLRecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[WCLRecordEngine alloc] init];
        _recordEngine.maxRecordTime = self.maxRecordTime;//最大录制时间
        _recordEngine.delegate = self;
        _recordEngine.previewLayer.frame = self.view.bounds;
        [self.view.layer insertSublayer:_recordEngine.previewLayer atIndex:0];
    }
    return _recordEngine;
}

#pragma mark - WCLRecordEngineDelegate
- (void)recordProgress:(CGFloat)progress currentRecordTime:(CGFloat)currentTime {
    if (progress >= 1) {
        [self recordAction:self.recordBt];
        self.allowRecord = NO;
    }
    self.progressView.progress = progress;
    self.currentTimeLB.text = [self timeFormatted:currentTime];
}

- (NSString *)timeFormatted:(float)totalSeconds
{
    int secondInt = (int)totalSeconds;
    int seconds = secondInt % 60;
    int minutes = (secondInt / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

#pragma mark - 各种点击事件
//返回点击事件
- (IBAction)dismissAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//开关闪光灯
- (IBAction)flashLightAction:(id)sender {
    if (self.changeCameraBT.selected == NO) {
        self.flashLightBT.selected = !self.flashLightBT.selected;
        if (self.flashLightBT.selected == YES) {
            [self.recordEngine openFlashLight];
        }else {
            [self.recordEngine closeFlashLight];
        }
    }
}

//切换前后摄像头
- (IBAction)changeCameraAction:(id)sender {
    self.changeCameraBT.selected = !self.changeCameraBT.selected;
    if (self.changeCameraBT.selected == YES) {
        //前置摄像头
        [self.recordEngine closeFlashLight];
        self.flashLightBT.selected = NO;
        [self.recordEngine changeCameraInputDeviceisFront:YES];
    }else {
        [self.recordEngine changeCameraInputDeviceisFront:NO];
    }
}

//录制下一步点击事件
- (IBAction)recordNextAction:(id)sender {
    //最少录制时间10秒
    if (_recordEngine.currentRecordTime >= 2) {
        WEAKSELF(weakSelf);
        [self.recordEngine stopCaptureHandler:^(UIImage *movieImage) {
            CGFloat duration = [self.recordEngine getVideoLength:[NSURL URLWithString:self.recordEngine.videoPath]];
            CGFloat videoSize = [self.recordEngine getFileSize:self.recordEngine.videoPath];
            
            MoviePlayController *moviePlayVC = [[MoviePlayController alloc] init];
            moviePlayVC.videoPath = weakSelf.recordEngine.videoPath;
            [moviePlayVC setFinishRecordBlock:^(BOOL isFinishRecord) {
                if (isFinishRecord) {
                    //结束录制，打印视频地址和首帧截图
                    NSLog(@"duration:%f-----videoSize:%f------firstImage:%@---------videoUrl:%@",duration,videoSize,movieImage,weakSelf.recordEngine.videoPath);
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
            [weakSelf.navigationController pushViewController:moviePlayVC animated:YES];
        }];
    }
    else {
        NSLog(@"录制时间不能低于10秒~");
    }
}

//开始和暂停录制事件
- (IBAction)recordAction:(UIButton *)sender {
    if (self.allowRecord) {
        self.recordBt.selected = !self.recordBt.selected;
        if (self.recordBt.selected) {
            [self configVideoOutputOrientation];
            if (self.recordEngine.isCapturing) {
                [self.recordEngine resumeCapture];
            }else {
                [self.recordEngine startCapture];
            }
        }
        else {
            [self.recordEngine pauseCapture];
        }
        [self adjustViewFrame];
    }
}

- (void)configVideoOutputOrientation
{
    switch (self.orientationLast) {
        case UIInterfaceOrientationPortrait:
            self.recordEngine.recordOrientation = RecordOrientationPortrait;
            [self.recordEngine adjustRecorderOrientation:AVCaptureVideoOrientationPortrait];
            break;
        case UIInterfaceOrientationLandscapeRight:
            self.recordEngine.recordOrientation = RecordOrientationLandscapeRight;
            [self.recordEngine adjustRecorderOrientation:AVCaptureVideoOrientationLandscapeRight];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            self.recordEngine.recordOrientation = RecordOrientationLandscapeLeft;
            [self.recordEngine adjustRecorderOrientation:AVCaptureVideoOrientationLandscapeLeft];
            break;
        default:
            NSLog(@"不支持的录制方向");
            break;
    }
}

- (CMMotionManager *)motionManager
{
    if (_motionManager == nil) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 1./15.;
    }
    return _motionManager;
}

- (UIInterfaceOrientation)orientationChange
{
    WEAKSELF(weakSelf);
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        CMAcceleration acceleration = accelerometerData.acceleration;
        UIInterfaceOrientation orientationNew;
        if (acceleration.x >= 0.75) {
            orientationNew = UIInterfaceOrientationLandscapeLeft;
        }
        else if (acceleration.x <= -0.75) {
            orientationNew = UIInterfaceOrientationLandscapeRight;
        }
        else if (acceleration.y <= -0.75) {
            orientationNew = UIInterfaceOrientationPortrait;
        }
        else if (acceleration.y >= 0.75) {
            orientationNew = UIInterfaceOrientationPortraitUpsideDown;
            return ;
        }
        else {
            // Consider same as last time
            return;
        }
        
        if (!weakSelf.recordEngine.isCapturing) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (orientationNew == weakSelf.orientationLast)
                    return;
                weakSelf.orientationLast = orientationNew;
            });
        }
    }];
    
    return self.orientationLast;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
