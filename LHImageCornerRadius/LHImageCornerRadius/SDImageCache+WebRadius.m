//
//  SDImageCache+WebRadius.m
//  LHImageCornerRadius
//
//  Created by Air on 2017/9/19.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "SDImageCache+WebRadius.h"
#import "NSData+ImageContentType.h"
#import "UIImage+MultiFormat.h"
#import <objc/runtime.h>


@interface UIImage (WebRadius)

- (UIImage*)imageByRoundCornerRadius;

@end

@implementation UIImage (WebRadius)

- (UIImage*)imageByRoundCornerRadius{
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -self.size.height);
    
    CGFloat minSize = MIN(self.size.width, self.size.height);
    CGRect rect = CGRectMake((self.size.width-minSize)/2, (self.size.height-minSize)/2, minSize, minSize);
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:minSize/2];
    [path closePath];
    CGContextSaveGState(context);
    [path addClip];
    CGContextDrawImage(context, rect, self.CGImage);
    CGContextRestoreGState(context);
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end


@implementation SDImageCache (WebRadius)

+ (void)load{
    Method originalMethod = class_getInstanceMethod(self, @selector(storeImage:imageData:forKey:toDisk:completion:));
    Method myMethod = class_getInstanceMethod(self, @selector(lh_storeImage:imageData:forKey:toDisk:completion:));
    method_exchangeImplementations(originalMethod, myMethod);
}

- (void)lh_storeImage:(nullable UIImage *)image
            imageData:(nullable NSData *)imageData
               forKey:(nullable NSString *)key
               toDisk:(BOOL)toDisk
           completion:(nullable SDWebImageNoParamsBlock)completionBlock {
    if (!image || !key) {
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    image = [image imageByRoundCornerRadius];
    
    NSString * imageType = [self typeForImageData:imageData];
    if ([imageType isEqualToString:@"image/jpeg"]) {
        imageData = UIImageJPEGRepresentation(image, 1.0);
    }
    else if ([imageType isEqualToString:@"image/png"]){
        imageData = UIImagePNGRepresentation(image);
    }
    Ivar memCachevar = class_getInstanceVariable([self class], [@"memCache" UTF8String]);
    if (memCachevar == nil) {
        memCachevar = class_getInstanceVariable([self class], [[NSString stringWithFormat:@"_%@",@"memCache"] UTF8String]);
    }
    NSCache * memCache = object_getIvar(self, memCachevar);
    
    Ivar ioQueuevar = class_getInstanceVariable([self class], [@"ioQueue" UTF8String]);
    if (ioQueuevar == nil) {
        ioQueuevar = class_getInstanceVariable([self class], [[NSString stringWithFormat:@"_%@",@"ioQueue"] UTF8String]);
    }
    dispatch_queue_t  ioQueue = object_getIvar(self, ioQueuevar);
    
    if (self.config.shouldCacheImagesInMemory) {
        NSUInteger cost = image.size.height * image.size.width * image.scale * image.scale;
        [memCache setObject:image forKey:key cost:cost];
    }
    if (toDisk) {
        dispatch_async(ioQueue, ^{
            @autoreleasepool {
                NSData *data = imageData;
                if (!data && image) {
                    SDImageFormat imageFormatFromData = [NSData sd_imageFormatForImageData:data];
                    data = [image sd_imageDataAsFormat:imageFormatFromData];
                }
                [self storeImageDataToDisk:data forKey:key];
            }
            
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock();
                });
            }
        });
    } else {
        if (completionBlock) {
            completionBlock();
        }
    }
}
- (NSString *)typeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

@end
