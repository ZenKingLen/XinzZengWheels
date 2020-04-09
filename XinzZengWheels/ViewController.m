//
//  ViewController.m
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/5/29.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import "ViewController.h"
#import "XZhExtensions/XZhData/NSData+XZhData.h"
#import "XZhExtensions/XZhNSString/NSString+XZhString.h"
#import "XZhExtensions/XZhView/UIView+XZhEdge.h"
#import "Tools/AudioQueue/XZhAudioRecord.h"
#import "XZhFiles.h"
#import "TSOpusManager.h"
#import "NewOpusMgr.h"
#import "NewOpuslib.h"
#import "XZhShapeView.h"

@interface ViewController () <XZhRecordDelegate>

//@property (weak, nonatomic) IBOutlet WKWebView *wkwebview;
//https://show.lianj.com/index/project/scene_view/mobile/1/id/5

@property(nonatomic, strong) XZhAudioRecord *record;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"test" style:UIBarButtonItemStylePlain target:self action:@selector(testDatas)];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://show.lianj.com/index/project/scene_view/mobile/1/id/5"]];
//    [self.wkwebview loadRequest:request];
//    [XZhAudioRecord share].isMainThread = NO;
//    [XZhAudioRecord share].delegate = self;
}

- (void)testDatas {

    [self testQLImageView];
    
//    [self testNewOpus];
//    [self testPcm2Opus];
//    [self testRecord];
    
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"/Images"];
//    NSLog(@"path = %@", path);
//    NSLog(@"documentFiles file png = %@", XZhFiles.documentFiles(path));
//    NSLog(@"documentFiles file png = %@", XZhFiles.uniformtCaseFiles(path, @"jpg"));
//    NSLog(@"documentFiles file png = %@", XZhFiles.uniformtNoCaseFiles(path, @"jPG"));
    
//    UIAlertAction
//    NSString *key = @"223";
//    NSData *cData = [@"111" dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"cdata = %@", cData);
//    NSString *enString = key.xzh_hexDataString(cData.xzh_aes128Encrypt(key));
//    NSLog(@"enstring = %@", enString);
//    NSData *deData = cData.xzh_aes128Encrypt(key).xzh_aes128Decrypt(key);
//    NSLog(@"de = %@", deData);
    
//    NSLog(@"x = %lf, y = %lf, width = %lf, height = %lf", self.view.x, self.view.y, self.view.width, self.view.height);
//    NSLog(@"size = %@, orgin = %@", NSStringFromCGSize(self.view.size), NSStringFromCGPoint(self.view.origin));
}

- (void)testQLImageView {
    XZhShapeView *shape = [[XZhShapeView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:shape];
}

- (void)testNewOpus {
    NewOpuslib *olib = [[NewOpuslib alloc] init];
    NSData *data;
    data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"temp.pcm" ofType:nil]];
    [olib encodeWithPCM:data];
}

- (void)testPcm2Opus {
    NSString *pcmPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:@"/temp.pcm"];
    NSString *opusPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:@"/temp.opus"];
    NSData *pcmData = [NSData dataWithContentsOfFile:pcmPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:opusPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:opusPath error:nil];
    }
    
    NSData *opusData;
//    TSOpusManager *opus = [[TSOpusManager alloc] init];
//    opusData = [opus encodePCM:pcmData];
    opusData = [[NewOpusMgr shared] encode:pcmData];
    
    BOOL flag = [opusData writeToFile:opusPath atomically:YES];
    NSLog(@"pcmPath: %@\n, opusPath: %@", pcmPath, opusPath);
    if (flag) {
        NSLog(@"ok 了");
        return;
    }
    NSLog(@"失败了");
}

- (void)testRecord {
    if ([XZhAudioRecord share].isRecording) {
        [[XZhAudioRecord share] stop];
        return;
    }
    [[XZhAudioRecord share] start];
}

#pragma mark - record delegate

- (void)xzhRecordStart {
    NSString *docpcm = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:@"/temp.pcm"];
    NSString *docwav = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:@"/temp.wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:docpcm]) {
        [[NSFileManager defaultManager] removeItemAtPath:docpcm error:nil];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:docwav]) {
        [[NSFileManager defaultManager] removeItemAtPath:docwav error:nil];
    }
    NSLog(@"pcm: %@\n, wav: %@", docpcm, docwav);
}
- (void)xzhRecordStop {
    NSString *docpcm = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:@"/temp.pcm"];
    NSString *docwav = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:@"/temp.wav"];
    NSLog(@"save path = %@", docpcm);
    [[XZhAudioRecord share] convertPCMFile:docpcm toWavFile:docwav];
}
- (void)xzhRecordError:(NSError *)error {
    NSLog(@"error: %@", error.description);
}
- (void)xzhRecording:(NSData *)data {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:@"/temp.pcm"];
    XZhFiles.writeDataToFile(data, doc);
}

@end
