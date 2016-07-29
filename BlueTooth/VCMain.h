//
//  VCMain.h
//  BlueTooth
//
//  Created by md on 16/5/27.
//  Copyright © 2016年 HKQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFBlunoManager.h"

//iPhone
#define IsRetina    CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size)
#define IsiPhone5   CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)
#define IsiPhone6   CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size)
#define IsiPhone6Plus   CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)

#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height
#define UIViewAutoresizingFlexibleFullFit   UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight
@interface VCMain : UIViewController<DFBlunoDelegate,UITableViewDataSource,UITableViewDelegate>
@property(strong, nonatomic) DFBlunoManager* blunoManager;
@property(strong, nonatomic) DFBlunoDevice* blunoDev;
@property(strong, nonatomic) NSMutableArray* aryDevices;

@property (strong, nonatomic) UIView *viewDevices;
@property (strong, nonatomic) UIButton *bgImageView;
@property (strong, nonatomic) UITableView *tbDevices;

@property (strong, nonatomic) UIActivityIndicatorView *SearchIndicator;
//@property (strong, nonatomic) UITableViewCell *cellDevices;

@property (nonatomic, copy) NSString *mLoadMsg;
- (void)startLoading;
- (void)stopLoading;

@end
