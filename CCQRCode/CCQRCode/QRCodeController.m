//
//  QRCodeController.m
//  QRCode
//
//  Created by imCloud on 16/7/16.
//  Copyright © 2016年 Cloud. All rights reserved.
//

#import "QRCodeController.h"
#import "CCQRcodeTool.h"

#define CCScreenW [UIScreen mainScreen].bounds.size.width
#define CCScreenH [UIScreen mainScreen].bounds.size.height
@interface QRCodeController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property(strong,nonatomic) UIView *maskView;
/** <#name#>   */
@property(strong,nonatomic) UIView *scanView;
/** <#name#>   */
@property(strong,nonatomic) UILabel *label;
/** <#name#>   */
@property(strong,nonatomic) UIButton *imageButton;
@end

@implementation QRCodeController
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    
   
   
    [self setupMask];
     [self setupSubViews];
    
    CCQRcodeTool *qrTool = [CCQRcodeTool sharedInstance];
    [qrTool beginScanInView:self.view result:^(NSArray<NSString *> *resultStrs) {
        NSLog(@"resultStrs %@",resultStrs);
        self.label.text = resultStrs.lastObject;
    }];
    
    [qrTool setInsteretRect:self.scanView.frame];
    qrTool.drawCodeFrameFlag = YES;

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[CCQRcodeTool sharedInstance]stopScan];
    
    
}
-(void)openAlbum{
   
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];//modal
   
    
    
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
 [picker dismissViewControllerAnimated:YES completion:nil];
    
   UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [[CCQRcodeTool sharedInstance]distinguishQRCodeFromImage:image result:^(NSArray<NSString *> *resultStrs) {
        self.label.text = resultStrs.lastObject;
    }];
    
    
    
}
-(void)setupSubViews{
    self.label = [[UILabel alloc]init];
    self.label.frame = CGRectMake(10, 10, 300, 30);
    self.label.textColor = [UIColor whiteColor];
    [self.view addSubview:self.label];
    
    self.imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _imageButton.frame = CGRectMake(10, 40, 50, 20);
    [_imageButton setTitle:@"相册" forState:UIControlStateNormal];
    [_imageButton addTarget:self action:@selector(openAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.imageButton];
}
-(void)setupMask{
    
    self.maskView = [[UIView alloc]init];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.frame = [UIScreen mainScreen].bounds;
    self.maskView.alpha = 0.6;
    [self.view addSubview:self.maskView];
    
    
    CGRect scanFrame = CGRectMake(0, 0, 300, 300);
    scanFrame.origin.x = (CCScreenW - 300) * 0.5;
    scanFrame.origin.y = (CCScreenH - 300) * 0.5;
    self.scanView = [[UIView alloc]initWithFrame:scanFrame];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0,  CCScreenW ,  CCScreenH)];
    [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:scanFrame cornerRadius:0] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [self.maskView.layer setMask:shapeLayer];
    
}

@end
