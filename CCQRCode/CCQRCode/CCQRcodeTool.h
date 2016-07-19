//
//  CCQRcodeTool.h
//  QRCode
//
//  Created by imCloud on 16/7/16.
//  Copyright © 2016年 Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CCQRcodeTool : NSObject

/** 是否绘制边框标记   */
@property(assign,nonatomic,getter=isDrawCodeFrameFlag) BOOL drawCodeFrameFlag;

+(CCQRcodeTool*)sharedInstance;
/**
 *  扫码
 *
 *  @param inView      范围
 *  @param resultBlock 结果
 */
- (void)beginScanInView:(UIView *)inView result:(void(^)(NSArray<NSString *> *resultStrs))resultBlock;
/**
 *  停止
 */
- (void)stopScan;
-(void)startScan;
/**
 *  设置兴趣点
 *
 *  @param originRect 范围
 */
-(void)setInsteretRect:(CGRect)originRect;
/**
 *  从一张图片获取二维码
 *
 *  @param sourceImage 图片
 *  @param resultBlock 回调
 */
-(void)distinguishQRCodeFromImage:(UIImage *)sourceImage result:(void(^)(NSArray<NSString *> *resultStrs))resultBlock;
/**
 *  生成二维码
 *
 *  @param contentSting 生成二维码的内容
 *  @param size         二维码尺寸
 *  @param icomImage    需要加入的图标
 *
 *  @return 返回一个二维码图片
 */
-(UIImage *)createQRCodeImageWithString:(NSString *)contentSting size:(CGFloat)size iconImage:(UIImage *)icomImage;
@end
