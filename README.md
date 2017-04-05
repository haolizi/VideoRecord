# VideoRecoder

用AVFoundation自定义视频录制功能，包含：横竖屏录制、断点录制、前后摄像头、闪光灯、手动聚焦等,还可设置最低和最高录制时间等

![image](https://github.com/haolizi/VideoRecord/blob/master/pause.jpg)
![image](https://github.com/haolizi/VideoRecord/blob/master/star.jpg)

## 声明

首先我要声明的是：这个demo是修改自[WCLRecordVideo](https://github.com/631106979/WCLRecordVideo)，仅用来大家互相学习，如果侵犯了原作者利益，请及时指出。</br>

新加功能：</br>
1.app进入后台监测。如果正在录制则进入暂停状态，如果未开始录制则返回上一个界面。</br>
2.视频删除，建议上传成功或视频出错等情况下删除沙盒中视频，调用[self.recordEngine deleteVideoCache];</br>
3.码率处理。  如下： 
        
```objective-C
/**
 调整视频写入时的压缩比率，可根据需求自行调节 
 @param AVVideoAverageBitRateKey 视频尺寸*比率
 @param AVVideoProfileLevelKey 画质设置，H.264有3种profile，用于确定编码过程中帧间压缩使用的算法，这里使用Main
 @param AVVideoMaxKeyFrameIntervalKey 关键帧最大间隔，数值越大压缩率越高
*/
NSDictionary *compressConfig = @{AVVideoAverageBitRateKey:[NSNumber numberWithInteger:cx*cy*3.0],
                                   AVVideoProfileLevelKey:AVVideoProfileLevelH264MainAutoLevel,
                            AVVideoMaxKeyFrameIntervalKey:[NSNumber numberWithInteger:10]};
    
//录制视频的一些配置，分辨率，编码方式等等
NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                          AVVideoCodecH264, AVVideoCodecKey,
                          [NSNumber numberWithInteger: cx], AVVideoWidthKey,
                          [NSNumber numberWithInteger: cy], AVVideoHeightKey,
                          compressConfig,AVVideoCompressionPropertiesKey,
                          nil];
```

如有不懂，可以参考一下[AVFoundation基础知识<一>](http://www.jianshu.com/p/485e946f80b4)</br>
欢迎下载、欢迎指导、欢迎star。</br>
使用过程中如果遇到什么问题，可发邮件给我。</br>
持续添加功能中，敬请期待...</br>



