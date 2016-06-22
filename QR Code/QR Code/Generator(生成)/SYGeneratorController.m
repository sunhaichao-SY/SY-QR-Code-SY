//
//  SYGeneratorController.m
//  QR Code
//
//  Created by 码农界四爷__King on 16/6/22.
//  Copyright © 2016年 码农界四爷__King. All rights reserved.
//

#import "SYGeneratorController.h"
#import <CoreImage/CoreImage.h>


@interface SYGeneratorController ()
@property (weak, nonatomic) IBOutlet UITextField *textLable;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeView;

@end

@implementation SYGeneratorController

- (IBAction)switchQRCode {
    
    //当输入完需要转换的文字之后点击转换二维码按钮的时候应该退出输入的弹出的键盘
    [self.view endEditing:YES];
    
    //获取输入框中的内容
    NSString *textContent = self.textLable.text;
    
    //判断是否有内容
    if (textContent.length == 0) {
        NSLog(@"请输入内容");
        return;
    }
    
    //转换二维码时需要调用一个库 #import <CoreImage/CoreImage.h>
    //将输入的内容转换成二维码,首先创建滤镜对象，在字符中固定写CIQRCodeGenerator
    CIFilter *filer = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //将滤镜恢复成默认
    [filer setDefaults];
    
    //设置二维码的内容(通过KVC设置)
    NSData *qrcodeData = [textContent dataUsingEncoding:NSUTF8StringEncoding];
    
    //在字符创中固定写inputMessage
    [filer setValue:qrcodeData forKeyPath:@"inputMessage"];
    
    //生成二维码
    CIImage *QRCodeImage = [filer outputImage];
    
    //生成高清图片
    UIImage *HDImage = [self createHDImageWithCIImage:QRCodeImage scaleRatio:10];
    
    //添加前景图片
    UIImage *iconImage = [UIImage imageNamed:@"Snip20160518_2"];
    
    //抽取一个方法，先将大图画进上下文中，再将小图片画进上下文中
    self.QRCodeView.image = [self createFGImageWithQRImage:HDImage fgImage:iconImage];
}

//将模糊的图片变高清
- (UIImage *)createHDImageWithCIImage:(CIImage *)ciImage scaleRatio:(CGFloat)ratio {
    // 1.创建放大的transform
    CGAffineTransform transform = CGAffineTransformMakeScale(ratio, ratio);
    
    // 2.放大图片
    CIImage *newImage = [ciImage imageByApplyingTransform:transform];
    
    // 3.生成UIImage对象
    return  [UIImage imageWithCIImage:newImage];
}

//利用图形上下文将小头像画进二维码中
- (UIImage *)createFGImageWithQRImage:(UIImage *)qrImage fgImage:(UIImage *)fgImage {
    // 1.获取qrImage的尺寸
    CGSize size = qrImage.size;
    
    // 2.开启上下文
    UIGraphicsBeginImageContext(size);
    
    // 3.将qrImage绘制到上下文中
    [qrImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 4.将fgImage绘制到上下文中
    CGFloat w = 60;
    CGFloat h = 60;
    CGFloat x = (size.width - w) * 0.5;
    CGFloat y = (size.height - h) * 0.5;
    [fgImage drawInRect:CGRectMake(x, y, w, h)];
    
    // 5.从上下文中获取图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 6.关闭上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
