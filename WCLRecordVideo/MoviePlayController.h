//
//  MoviePlayController.h
//  WCLRecordVideo
//
//  Created by chuang Hao on 2017/3/9.
//  Copyright © 2017年 王崇磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviePlayController : UIViewController

@property (nonatomic, copy) void(^finishRecordBlock)(BOOL isFinishRecord);
@property (nonatomic, copy) NSString *videoPath;

@end
