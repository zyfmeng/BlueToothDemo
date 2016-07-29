//
//  VCMain.m
//  BlueTooth
//
//  Created by md on 16/5/27.
//  Copyright © 2016年 HKQ. All rights reserved.
//

#import "VCMain.h"
#import "ListCell.h"
#import "MBProgressHUD.h"
@interface VCMain ()
{
    UILabel *tempLab;//温度
    UILabel *humLab;//湿度
    UILabel *pm1Lab;//PM2.0
    UILabel *pm2Lab;//PM10
    NSString *dev_UUIDStr;//设备UUID
    NSString *dev_name;//设备名称
    
    DFBlunoDevice* peripheral2;
    MBProgressHUD *mLoadView;
    BOOL isContent;//是否链接成功
}
@end

@implementation VCMain

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"app_01"] forBarMetrics:UIBarMetricsDefault];//设置导航栏背景图片
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    isContent = NO;
    //(437/750.0)
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 100, 100, 100)];
    imageView.image = [UIImage imageNamed:@"app_09"];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleFullFit;
    [self.view addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *iTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iTapGesture:)];
    [imageView addGestureRecognizer:iTap];
    
    self.bgImageView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.bgImageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.bgImageView setBackgroundImage:[UIImage imageNamed:@"bg_image"] forState:UIControlStateNormal];
    self.bgImageView.userInteractionEnabled = YES;
    [self.bgImageView addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bgImageView];
    self.bgImageView.hidden = YES;
}
- (void)createTableView
{
    if (self.tbDevices) {
        [self.tbDevices removeFromSuperview];
    }
    self.tbDevices = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height-200)/2, self.view.frame.size.width, 200)];
    self.tbDevices.delegate = self;
    self.tbDevices.dataSource = self;
    self.tbDevices.backgroundColor = [UIColor whiteColor];
    self.tbDevices.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgImageView addSubview:self.tbDevices];

}
- (void)btnClick:(UIButton *)tap
{
    self.bgImageView.hidden = YES;
}
- (void)iTapGesture:(UITapGestureRecognizer *)tap
{
    self.bgImageView.hidden = NO;
    [self createTableView];
    if (self.blunoManager) {
        self.blunoManager = nil;
    }
    self.blunoManager = [DFBlunoManager sharedInstance];
    self.blunoManager.delegate = self;
    self.aryDevices = [[NSMutableArray alloc] init];
    
    [self.aryDevices removeAllObjects];
    [self.SearchIndicator startAnimating];
    [self.blunoManager scan];
    [self.tbDevices reloadData];
}
#pragma mark- DFBlunoDelegate

-(void)bleDidUpdateState:(BOOL)bleSupported
{
    if(bleSupported){
        [self.blunoManager scan];
    }
}
-(void)didDiscoverDevice:(DFBlunoDevice*)dev
{
    BOOL bRepeat = NO;
    for (DFBlunoDevice* bleDevice in self.aryDevices){
        if ([bleDevice isEqual:dev]){
            bRepeat = YES;
            break;
        }
    }
    if (!bRepeat){
        [self.aryDevices addObject:dev];
    }
    [self.tbDevices reloadData];
}
-(void)didReceiveData:(NSData*)data Device:(DFBlunoDevice*)dev
{
    //00:E0:4C:3F:14:DE
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self stopLoading];
    isContent = YES;
    dev_UUIDStr = dev.identifier;
    //使用UUID可以标示每一个设备
    NSLog(@"str======%@-%@",dev.name,str);
    [self.tbDevices reloadData];
}

#pragma mark- TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger nCount = [self.aryDevices count];
    return nCount;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"ScanDeviceCell";
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil){
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            cell = [[ListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        }
    }
    
    UILabel* lbName = (UILabel*)[cell viewWithTag:1];
    UILabel* lbUUID = (UILabel*)[cell viewWithTag:2];
    DFBlunoDevice* peripheral   = [self.aryDevices objectAtIndex:indexPath.row];
    peripheral2 = peripheral;
    lbName.text = peripheral.name;
    lbUUID.text = peripheral.identifier;
    BOOL isConnection = NO;
    if ([peripheral.identifier isEqualToString:dev_UUIDStr]) {
        isConnection = YES;
    }
    [cell contentListCell:peripheral isConnection:isConnection];
    
    return cell;
}

#pragma mark- TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.mLoadMsg = @"正在链接……";
    [self startLoading];
    self.bgImageView.hidden = YES;
    DFBlunoDevice* device = [self.aryDevices objectAtIndex:indexPath.row];
    if (self.blunoDev == nil)
    {
        self.blunoDev = device;
        [self.blunoManager connectToDevice:self.blunoDev];
    }else if ([device isEqual:self.blunoDev]){
        if (!self.blunoDev.bReadyToWrite){
            [self.blunoManager connectToDevice:self.blunoDev];
        }
    }else{
        [self.blunoManager connectToDevice:device];
    }
    [self.SearchIndicator stopAnimating];
    [self.viewDevices removeFromSuperview];
    //时间延迟
    double delayInSeconds = 15.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (isContent == NO) {
            [self stopLoading];
            [self showMsg:@"链接超时"];
            [self.blunoManager disconnectToDevice:self.blunoDev];
        }
        isContent = NO;
        [self stopLoading];

    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Loading Animate
//开始加载
- (void)startLoading
{
    //判断mLoadView是否已经被创建
    if (mLoadView) {
        //将mLoadView放到最前面
        [self.view bringSubviewToFront:mLoadView];
        return;//ruturn跳出整个方法
    }
    mLoadView = [[MBProgressHUD alloc] initWithView:self.view];
    //判断是否有提示文字
    if (self.mLoadMsg) {
        mLoadView.mode = MBProgressHUDModeIndeterminate;//显示自定义视图
        mLoadView.labelText = self.mLoadMsg;//加载显示的文字
    }
    [self.view addSubview:mLoadView];
    
    [mLoadView show:YES];//mLoadView视图是否显示，YES显示，NO不显示
}
//结束加载
- (void)stopLoading
{
    [mLoadView hide:YES];//隐藏视图
    [mLoadView removeFromSuperview];//移除视图
    mLoadView = nil;
}
- (void)showMsg:(NSString *)msg
{
    mLoadView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:mLoadView];
    
    mLoadView.mode = MBProgressHUDModeCustomView;
    if (msg.length>20) {
        mLoadView.detailsLabelText = msg;
    }
    else {
        mLoadView.labelText = msg;
    }
    [mLoadView show:YES];
    [mLoadView hide:YES afterDelay:1];
    mLoadView = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
