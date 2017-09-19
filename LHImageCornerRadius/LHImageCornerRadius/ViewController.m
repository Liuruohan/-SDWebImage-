//
//  ViewController.m
//  LHImageCornerRadius
//
//  Created by Air on 2017/9/19.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "ViewController.h"

#import <SDWebImage/SDWebImageManager.h>

#import "SDImageCache+WebRadius.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [SDImageCache sharedImageCache].isCornerRadius = [NSNumber numberWithBool:NO];
    
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor clearColor];
    NSString * urlString = @"http://www.cdhdky.com/images/ttt.jpg";
    UIImage * image = [[SDImageCache sharedImageCache] imageFromCacheForKey:urlString];
    if (image) {
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        imageView.center = self.view.center;
        imageView.image = image;
    }
    else{
        __weak __typeof(self) weakSelf = self;
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:urlString] options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            imageView.center = weakSelf.view.center;
            imageView.image = [[SDImageCache sharedImageCache]imageFromCacheForKey:imageURL.absoluteString];
        }];
    }
    [self.view addSubview:imageView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
