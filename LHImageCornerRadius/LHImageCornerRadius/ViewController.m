//
//  ViewController.m
//  LHImageCornerRadius
//
//  Created by Air on 2017/9/19.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "ViewController.h"

#import <UIImageView+WebCache.h>

#import "SDImageCache+WebRadius.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor clearColor];
    __weak __typeof(self) weakSelf = self;
    [imageView sd_setImageWithURL:[NSURL URLWithString:@"http://www.cdhdky.com/images/ttt.jpg"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        imageView.center = weakSelf.view.center;
    }];
    [self.view addSubview:imageView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
