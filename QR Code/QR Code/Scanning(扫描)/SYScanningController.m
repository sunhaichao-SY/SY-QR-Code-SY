//
//  SYScanningController.m
//  QR Code
//
//  Created by 码农界四爷__King on 16/6/22.
//  Copyright © 2016年 码农界四爷__King. All rights reserved.
//

#import "SYScanningController.h"
#import <AVFoundation/AVFoundation.h>

@interface SYScanningController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *frameImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanImage;

@property (weak, nonatomic) IBOutlet UILabel *textLable;

@property (weak, nonatomic) IBOutlet UIView *qrCodeImage;

@property (weak,nonatomic) AVCaptureVideoPreviewLayer *layer;

@property (nonatomic,strong) NSMutableArray *layers;
@end

@implementation SYScanningController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //添加扫描动画
    [self startScanAnimation];
    
    //开始扫描
    [self startScanning];
}

- (void)startScanAnimation{
    
    //记住设置一下背景图片的裁剪
    //改变约束
    self.scanImage.constant = -200;
    
    //指定动画
    [UIView animateWithDuration:1.0 animations:^{
        [UIView setAnimationRepeatCount:CGFLOAT_MAX];
        [self.view layoutIfNeeded];
    }];
}

- (void)startScanning{
    
    //创建输入设备(摄像头)
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    //创建输入方式
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //创建会话，将输入个输出联系起来
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session addInput:input];
    [session addOutput:output];
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    //创建会话图层
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
    layer.frame = self.view.frame;
    [self.view.layer insertSublayer:layer atIndex:0];
    self.layer = layer;
    
    //开始扫描
    [session startRunning];
    
    //设置扫描的区域
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat x = self.qrCodeImage.frame.origin.y / size.height;
    CGFloat y = self.qrCodeImage.frame.origin.x / size.width;
    CGFloat w = self.qrCodeImage.frame.size.height / size.height;
    CGFloat h = self.qrCodeImage.frame.size.width / size.width;
    output.rectOfInterest = CGRectMake(x, y, w, h);
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //移除之前的绘制
    for (CAShapeLayer *layer in self.layers) {
        [layer removeFromSuperlayer];
    }
    
    //获取扫描结果
    NSMutableString *resultMStr = [NSMutableString string];
    for (AVMetadataMachineReadableCodeObject *result in metadataObjects) {
        //获取扫描到的字符串
        [resultMStr appendString:result.stringValue];
        
        [self drawEdgeBorder:result];
    }
    
    //显示结果
    NSString *string = [resultMStr isEqualToString:@""] ? @"请将二维码放到扫描框中" : resultMStr;

    self.textLable.text = string;
}

- (void)drawEdgeBorder:(AVMetadataMachineReadableCodeObject *)resultObjc {
    // 0.转化object
    resultObjc = (AVMetadataMachineReadableCodeObject *)[self.layer transformedMetadataObjectForMetadataObject:resultObjc];
    
    // 1.创建绘制的图层
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    
    // 2.设置图层的属性
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor blueColor].CGColor;
    shapeLayer.lineWidth = 5;
    
    // 3.创建贝塞尔曲线
    // 3.1.创建贝塞尔曲线
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    // 3.2.将path移动到起始位置
    int index = 0;
    for (id dict in resultObjc.corners) {
        // 3.2.1.获取点
        CGPoint point = CGPointZero;
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)dict, &point);

        // 3.2.2.判断如何使用该点
        if (index == 0) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
        
        // 3.2.3.下标值自动加1
        index++;
    }
    
    // 3.3.关闭路径
    [path closePath];
    
    // 4.画出路径
    shapeLayer.path = path.CGPath;
    
    // 5.将layer添加到图册中
    [self.view.layer addSublayer:shapeLayer];
    
    // 6.添加到数组中
    [_layers addObject:shapeLayer];
}

- (NSMutableArray *)layers {
    if (_layers == nil) {
        _layers = [NSMutableArray array];
    }
    return _layers;
}
@end
