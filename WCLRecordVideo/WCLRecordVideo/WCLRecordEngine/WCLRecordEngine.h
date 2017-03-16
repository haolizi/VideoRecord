//
//
//  WCLRecordEngine.h
//  WCL
//
//  Created by 王崇磊 on 16/9/14.
//  Copyright © 2016年 王崇磊. All rights reserved.
//
// @class WCLRecordEngine
// @abstract 视频录制类
// @discussion 视频录制类
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>

typedef NS_ENUM(NSUInteger,RecordOrientation){
    RecordOrientationPortrait,
    RecordOrientationLandscapeRight,
    RecordOrientationLandscapeLeft,
};

@protocol WCLRecordEngineDelegate <NSObject>

- (void)recordProgress:(CGFloat)progress;

@end

@interface WCLRecordEngine : NSObject

@property (atomic, assign, readonly) BOOL isCapturing;//正在录制
@property (atomic, assign, readonly) BOOL isPaused;//是否暂停
@property (atomic, assign, readonly) CGFloat currentRecordTime;//当前录制时间
@property (atomic, assign) CGFloat maxRecordTime;//录制最长时间
@property (weak, nonatomic) id<WCLRecordEngineDelegate>delegate;
@property (atomic, strong) NSString *videoPath;//视频路径
@property (nonatomic, assign) RecordOrientation  recordOrientation;//方向
//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer;
//调整录制的方向
- (void)adjustRecorderOrientation:(AVCaptureVideoOrientation)orientation;
//启动录制功能
- (void)startUp;
//关闭录制功能
- (void)shutdown;
//开始录制
- (void)startCapture;
//暂停录制
- (void)pauseCapture;
//停止录制
- (void)stopCaptureHandler:(void (^)(UIImage *movieImage))handler;
//继续录制
- (void)resumeCapture;
//开启闪光灯
- (void)openFlashLight;
//关闭闪光灯
- (void)closeFlashLight;
//设置聚焦点  手动聚焦
- (void)setFocusCursorWithPoint:(CGPoint)tapPoint;
//切换前后置摄像头
- (void)changeCameraInputDeviceisFront:(BOOL)isFront;
//将mov的视频转成mp4
- (void)changeMovToMp4:(NSURL *)mediaURL dataBlock:(void (^)(UIImage *movieImage))handler;

- (CGFloat)getVideoLength:(NSURL *)URL;

- (CGFloat)getFileSize:(NSString *)path;


@end
