//
//  CCQRcodeTool.m
//  QRCodeTool
//
//  Created by imCloud on 16/7/16.
//  Copyright © 2016年 Cloud. All rights reserved.
//

#import "CCQRcodeTool.h"
#import <AVFoundation/AVFoundation.h>

typedef void(^QRResult)(NSArray <NSString *> *resultArray);
@interface CCQRcodeTool () <AVCaptureMetadataOutputObjectsDelegate>
/** 输入设备   */
@property(strong,nonatomic) AVCaptureDeviceInput *input;
/** 元数输出*/
@property(strong,nonatomic) AVCaptureMetadataOutput *outPut;
/** 会话   */
@property(strong,nonatomic) AVCaptureSession *session;
/** 预览图层   */
@property(strong,nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
/** 扫码类型   */
@property(strong,nonatomic) NSMutableArray *metadataObjectTypes;
/** 记录需要执行的代码块   */
@property(strong,nonatomic) QRResult resultBlock;

@end

@implementation CCQRcodeTool


+(CCQRcodeTool*)sharedInstance {
    
    static CCQRcodeTool *QRcodeTool;
    static dispatch_once_t demoglobalclassonce;
    dispatch_once(&demoglobalclassonce, ^{
        QRcodeTool = [[CCQRcodeTool alloc] init];
    });
    return QRcodeTool;
}



-(void)setup{
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!inputDevice) {
        NSLog(@"创建输入设备失败");
      
    }
    NSError *error=nil;
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:inputDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
    }
    
    self.outPut = [[AVCaptureMetadataOutput alloc]init];
    [_outPut setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
  
    
    self.session = [[AVCaptureSession alloc]init];
    if ([_session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        _session.sessionPreset = AVCaptureSessionPreset1920x1080;
    }

     self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
}
#pragma mark - 扫描
- (void)beginScanInView:(UIView *)inView result:(void(^)(NSArray<NSString *> *resultStrs))resultBlock
{
    [self setup];
    
    self.resultBlock = resultBlock;
    
    // 创建并设置会话
    if ([self.session canAddInput:self.input] && [self.session canAddOutput:self.outPut]) {
        [self.session addInput:self.input];
        [self.session addOutput:self.outPut];
        NSLog(@"test");
        // 设置元数据处理类型(注意, 一定要将设置元数据处理类型的代码添加到  会话添加输出之后)
        [self.outPut setMetadataObjectTypes:self.metadataObjectTypes];
    }else{
        resultBlock(nil);
        return;
    }
    
    
    // 添加预览图层
    if (![inView.layer.sublayers containsObject:self.previewLayer]){
        self.previewLayer.frame = inView.bounds;
        [inView.layer insertSublayer:self.previewLayer atIndex:0];
    }
    
    //启动会话
    [self.session startRunning];
    
}
-(void)startScan{
    [self.session startRunning];
}
- (void)stopScan{
    [self.session stopRunning];
}
-(void)setInsteretRect:(CGRect)originRect{
    // 设置兴趣点
    // 注意: 兴趣点的坐标是横屏状态(0, 0 代表竖屏右上角, 1,1 代表竖屏左下角)
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    CGFloat x = originRect.origin.x / screenBounds.size.width;
    CGFloat y = originRect.origin.y / screenBounds.size.height;
    CGFloat width = originRect.size.width / screenBounds.size.width;
    CGFloat height = originRect.size.height / screenBounds.size.height;
    
    self.outPut.rectOfInterest = CGRectMake(y, x, height, width);
}


-(void)distinguishQRCodeFromImage:(UIImage *)sourceImage result:(void(^)(NSArray<NSString *> *resultStrs))resultBlock{
  
    NSMutableArray *resultArr = [NSMutableArray array];
    
    NSData *imageData = UIImagePNGRepresentation(sourceImage);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    
    //创建探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    NSArray *features = [detector featuresInImage:ciImage];
  
    for (CIQRCodeFeature *feature in features) {
   
        CIQRCodeFeature *resultFeature = (CIQRCodeFeature *)feature;
        [resultArr addObject:resultFeature.messageString];
   
    }
    
    self.resultBlock(resultArr);
}

#pragma mark - 添加框
-(void)addShowLayer:(AVMetadataMachineReadableCodeObject *)readableCodeObject{
    if (readableCodeObject.corners == nil || readableCodeObject.corners.count == 0) {
        return;
    }
    CAShapeLayer *showLayer = [[CAShapeLayer alloc]init];
    showLayer.lineWidth = 1.0;
    showLayer.strokeColor = [UIColor redColor].CGColor;
    showLayer.fillColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *path = [[UIBezierPath alloc]init];
  
    NSInteger index = 0;
    for (NSDictionary *pointDic in readableCodeObject.corners) {
        CGPoint point = CGPointZero;
        CFDictionaryRef dic = (__bridge CFDictionaryRef)pointDic;
        CGPointMakeWithDictionaryRepresentation(dic, &point);
        
        if (index == 0) {
            [path moveToPoint:point];
        }else{
            [path addLineToPoint:point];
        }
        index ++;
        
    }
    
    [path closePath];
    showLayer.path = path.CGPath;
    [self.previewLayer addSublayer:showLayer];
    
}
- (void)removeShapLayers
{

    for (CALayer *layer in self.previewLayer.sublayers) {
        if ([layer isKindOfClass:([CAShapeLayer class])]) {
            [layer removeFromSuperlayer];
        }
    }
}

#pragma mark - delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self removeShapLayers];
    
    
    NSMutableArray *resultStrs = [NSMutableArray array];
    for (AVMetadataMachineReadableCodeObject *obj in metadataObjects){
        
        AVMetadataMachineReadableCodeObject *readCodeObj = (AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:obj];
        if (self.isDrawCodeFrameFlag) {
            [self addShowLayer:readCodeObj];
        }
            
        [resultStrs addObject:readCodeObj.stringValue];
        
    }

         self.resultBlock(resultStrs);
    
   
    
    
}


#pragma mark - 生成

-(UIImage *)createQRCodeImageWithString:(NSString *)contentSting size:(CGFloat)size iconImage:(UIImage *)icomImage{
    // 1.创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 2.设置相关属性
    [filter setDefaults];
    
    // 3.设置输入数据
    NSString *inputData = contentSting;
    NSData *data = [inputData dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    // 4.获取输出结果
    CIImage *outputImage = [filter outputImage];
    
    UIImage *qrImage = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:size];
    
    if (icomImage == nil) {
        return qrImage;
    }else{
        return [self createImage:qrImage iconImage:icomImage];
    }
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

-(UIImage *)createImage:(UIImage *)bgImage iconImage:(UIImage *)iconImage{
    if (!bgImage || !iconImage) {
        return nil;
    }
    
    UIGraphicsBeginImageContext(bgImage.size);
    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
  
    CGFloat width = 50;
    CGFloat height = width;
    CGFloat x = (bgImage.size.width - width) * 0.5;
    CGFloat y = (bgImage.size.height - height) * 0.5;
    
    [iconImage drawInRect:CGRectMake(x, y, width, height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}


#pragma mark - 懒加载
- (NSMutableArray *)metadataObjectTypes{
    
    if (!_metadataObjectTypes) {
        
        _metadataObjectTypes = [NSMutableArray arrayWithObjects:AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeUPCECode, nil];
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
            
            [_metadataObjectTypes addObjectsFromArray:@[AVMetadataObjectTypeInterleaved2of5Code, AVMetadataObjectTypeITF14Code, AVMetadataObjectTypeDataMatrixCode]];
            
        }
        
    }
    
    return _metadataObjectTypes;
    
}

@end
