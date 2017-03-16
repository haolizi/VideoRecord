//
//  MoviePlayController.m
//  WCLRecordVideo
//
//  Created by chuang Hao on 2017/3/9.
//  Copyright © 2017年 王崇磊. All rights reserved.
//

#import "MoviePlayController.h"
#import "KrVideoPlayerController.h"
#import "KrVideoPlayerControlView.h"
@interface MoviePlayController ()

@property(nonatomic, strong) UIView * Play;
@property(nonatomic, strong) KrVideoPlayerController * videoController;

@end

@implementation MoviePlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL fileURLWithPath:self.videoPath];
    [self addVideoPlayerWithURL:url];
}

- (void)addVideoPlayerWithURL:(NSURL *)url{
    if (!self.videoController) {
        self.videoController = [[KrVideoPlayerController alloc] initWithFrame:self.view.bounds];
        WEAKSELF(weakSelf);
        [self.videoController setDimissCompleteBlock:^(BOOL isSave) {
            weakSelf.videoController = nil;
            if (isSave) {
                if (weakSelf.finishRecordBlock) {
                    weakSelf.finishRecordBlock(YES);
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        [self.videoController setWillBackOrientationPortrait:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        }];
        [self.videoController setWillChangeToFullscreenMode:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        }];
        [self.view addSubview:self.videoController.view];
    }
    self.videoController.contentURL = url;
    [self.videoController play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
