//
//  ViewController.m
//  AVFAudioRecorder
//
//  Created by 向洪 on 2017/6/26.
//  Copyright © 2017年 向洪. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVAudioRecorderDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self recorder2];
}


- (void)recorder {
    
    /*
     
     音频基础
     
     声波是一种机械波，是一种模拟信号。
     PCM，全称脉冲编码调制，是一种模拟信号的数字化的方法。
     采样精度（bit pre sample)，每个声音样本的采样位数。
     采样频率（sample rate）每秒钟采集多少个声音样本。
     声道（channel）：相互独立的音频信号数，单声道（mono）立体声（Stereo）
     语音帧（frame），In audio data a frame is one sample across all channels.
     
     */
    // 语音录制
    
    // 格式（真机）
    NSMutableDictionary *recordSetting = [NSMutableDictionary dictionary];
    NSError *error = nil;
    NSString *outputPath = nil;
    // 输出地址
#if TARGET_IPHONE_SIMULATOR//模拟器
    outputPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"1.caf"];
    // 设置录音格式
    [recordSetting setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    
#elif TARGET_OS_IPHONE//真机
    
    NSString *outputPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"1.m4a"];
    [recordSetting setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
#endif
    
    // 设置录音采样率
    [recordSetting setObject:@(8000) forKey:AVSampleRateKey];
    // 设置通道,这里采用单声道 1:单声道；2:立体声
    [recordSetting setObject:@(1) forKey:AVNumberOfChannelsKey];
    // 每个采样点位数,分为8、16、24、32
    [recordSetting setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    
    // 大端还是小端,是内存的组织方式
    [recordSetting setObject:@(NO) forKey:AVLinearPCMIsBigEndianKey];
    // 是否使用浮点数采样
    [recordSetting setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    // 是否交叉
    [recordSetting setObject:@(NO) forKey:AVLinearPCMIsNonInterleaved];
    
    // 设置录音质量
    [recordSetting setObject:@(AVAudioQualityMin) forKey:AVEncoderAudioQualityKey];
    
    // 比特率
    [recordSetting setObject:@(128000) forKey:AVEncoderBitRateKey];
    // 每个声道音频比特率
    [recordSetting setObject:@(128000) forKey:AVEncoderBitRatePerChannelKey];
    
    // 深度
    [recordSetting setObject:@(8) forKey:AVEncoderBitDepthHintKey];
    
    // 设置录音采样质量
    [recordSetting setObject:@(AVAudioQualityMin) forKey:AVSampleRateConverterAudioQualityKey];
    
    // 策略 AVSampleRateConverterAlgorithmKey
    // 采集率算法 AVSampleRateConverterAlgorithmKey
    // 渠道布局 AVChannelLayoutKey
    
    
    // 初始化
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:outputPath] settings:recordSetting error:&error];
    // 设置协议
    recorder.delegate = self;
    // 准备录制
    [recorder prepareToRecord];
    [recorder record];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [recorder stop];
        
    });
    
}

- (void)recorder2 {
    
    NSString *outputPath;
    
    NSError *error = nil;
    
    // Core Audio
    AudioStreamBasicDescription basic;
    // 内存空间初始化
    memset(&basic, 0, sizeof(basic));
#if TARGET_IPHONE_SIMULATOR//模拟器
    outputPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"1.caf"];
    // 设置录音格式
    basic.mFormatID = kAudioFormatLinearPCM;
    
#elif TARGET_OS_IPHONE//真机
    
    NSString *outputPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"1.m4a"];
    basic.mFormatID = kAudioFormatMPEG4AAC;
#endif
    
    
    /**
     AudioStreamBasicDescription:
     mSampleRate;       采样率, eg. 44100
     mFormatID;         格式, eg. kAudioFormatLinearPCM
     mFormatFlags;      标签格式, eg. kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
     mBytesPerPacket;   每个Packet的Bytes数量, eg. 2
     mFramesPerPacket;  每个Packet的帧数量, eg. 1
     mBytesPerFrame;    (mBitsPerChannel / 8 * mChannelsPerFrame) 每帧的Byte数, eg. 2
     mChannelsPerFrame; 1:单声道；2:立体声, eg. 1
     mBitsPerChannel;   语音每采样点占用位数[8/16/24/32], eg. 16
     mReserved;         保留
     */
    
    basic.mSampleRate = 44100;
    basic.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    basic.mBytesPerPacket = 2;
    basic.mFramesPerPacket = 1152;
    basic.mBytesPerFrame = 2;
    basic.mChannelsPerFrame = 1;
    basic.mBitsPerChannel = 16;
    basic.mReserved = 0;
    AVAudioFormat *format = [[AVAudioFormat alloc] initWithStreamDescription:&basic];
    
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:outputPath] format:format error:&error];
    recorder.delegate = self;
    
    [recorder record];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [recorder stop];
        
    });
    
    // 其他属性易懂，可以自己查看。
    
}

#pragma mark - delegate <AVAudioRecorderDelegate>

// 录音结束
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    NSLog(@"%@", recorder.url);
}

// 发生错误调用
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    
    NSLog(@"%@", error);
}



- (void)avf_audio {
    
    
    //    AVAudioPlayer - 音频播放
    //    AVAudioRecorder - 音频录制
    //    AVAudioSession - 音频会话 https://developer.apple.com/library/content/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007875
    //
    //
    //    AVAudioBuffer - 代表一个缓冲区的音频数据及其格式。
    //    AVAudioFormat - 格式
    //    AVAudioPCMBuffer - 操纵的缓冲区在PCM音频格式
    //    AVAudioCompressedBuffer - 音频压缩相关
    //
    //    AVAudioChannelLayout - 音频通道
    //
    //    AVAudioConnectionPoint - 音频连接位置
    //
    //    AVAudioConverter - 各种格式之间转换的音频流。
    //
    //    AVAudioEngine - 建立一个音频的节点图，从源节点 (播放器和麦克风) 以及过处理 (overprocessing) 节点 (混音器和效果器) 到目标节点 (硬件输出) http://www.jianshu.com/p/506c62183763
    //
    //    AVAudioEnvironmentNode - 混响
    //
    //    AVAudioFile - 读取音频格式信息和进行帧分离
    //
    //    AVAudioFormat - 音频格式
    //
    //    AVAudioIONode -
    //
    //    AVAudioMixerNode - 音频输入输出相关
    //
    //    AVAudioMixing - 协议
    //
    //    AVAudioNode - 节点
    //
    //    AVAudioPlayerNode - 调度AVAudioBuffer实例的回放
    //
    //    AVAudioSequencer
    //
    //    AVAudioTime - 音频时间
    //
    //    AudioUnit
    //
    //    AVAudioUnitComponent - 提供一些音频元的详细信息，如类型、子类型,制造商,位置等
    //
    //    AVAudioUnitDelay - 音频延迟效果
    //
    //    AVAudioUnitDistortion - 音频效果场景 如  教堂  大型房间
    //
    //    AVAudioUnitEffect - 实现音效 http://www.jianshu.com/p/df03d566d832
    //
    //    AVAudioUnitEQ - 均衡器
    //
    //    AVAudioUnitGenerator - 生成音频输出
    //
    //    AVAudioUnitMIDIInstrument - 抽象类代表音乐设备或远程工具
    //
    //    AVAudioUnitReverb - 混响
    //
    //    AVAudioUnitSampler
    //
    //    AVAudioUnitTimeEffect - 非实时音频处理
    //
    //    AVAudioUnitTimePitch - 优质时间拉伸和音调变化
    //    
    //    AVAudioUnitTimeEffect - 控制回放速度
    //    
    //    AVMIDIPlayer - MIDI 播放
    //    
    //    AVSpeechSynthesisVoice - 语音合成
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
