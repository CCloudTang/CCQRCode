//
//  ViewController.m
//  CCQRCode
//
//  Created by 123 on 16/7/19.
//  Copyright © 2016年 ccqrcode. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeController.h"
#import "CCQRcodeTool.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}
- (IBAction)creatQRCodeTouchUpInside:(id)sender {
   self.imageView.image = [[CCQRcodeTool sharedInstance] createQRCodeImageWithString:self.textView.text size:200.0 iconImage:[UIImage imageNamed:@"geng"]];
}

- (IBAction)scanQRCodeTouchUpInside:(id)sender {
    
    QRCodeController *qrCodeVC = [[QRCodeController alloc]init];
    [self.navigationController pushViewController:qrCodeVC animated:YES];
}


@end
