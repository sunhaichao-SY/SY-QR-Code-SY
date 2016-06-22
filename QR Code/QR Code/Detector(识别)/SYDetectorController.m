//
//  SYDetectorController.m
//  QR Code
//
//  Created by 码农界四爷__King on 16/6/22.
//  Copyright © 2016年 码农界四爷__King. All rights reserved.
//

#import "SYDetectorController.h"
#import <CoreImage/CoreImage.h>

@interface SYDetectorController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

@end

@implementation SYDetectorController

- (IBAction)openPicture {
    
    //获取照片源
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    
    //判断照片源是否可用
    if (![UIImagePickerController isSourceTypeAvailable:type]) {
        NSLog(@"照片源不可用");
        return;
    }
    //创建照片选择控制器
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    
    //设置数据源
    imagePicker.sourceType = type;
    //设置代理
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

//从相册中取出照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //取出照片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    //设置照片
    self.iconView.image = image;
    
    //弹出控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)switchQRCode {
    
    //创建过滤器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:nil];
    
    //创建CIIimage对象
    CIImage *ciImage = [[CIImage alloc] initWithImage:self.iconView.image];
    
    //识别ciImage中的内容
    NSArray *content = [detector featuresInImage:ciImage];
    
    //遍历所有的对象
    NSMutableString *resultStr = [NSMutableString string];
    
    for (CIQRCodeFeature *cf in content) {
        [resultStr appendString:cf.messageString];
    }
    
    //显示结果
    self.msgLabel.text = resultStr;
    
}

@end
