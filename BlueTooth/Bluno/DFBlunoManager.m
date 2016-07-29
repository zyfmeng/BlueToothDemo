//
//  DFBlunoManager.m
//
//  Created by Seifer on 13-12-1.
//  Copyright (c) 2013年 DFRobot. All rights reserved.
//

#import "DFBlunoManager.h"

#define kBlunoService @"dfb0"
#define kBlunoDataCharacteristic @"dfb1"

@interface DFBlunoManager ()
{
    BOOL _bSupported;
}
//@property (strong,nonatomic) CBCentralManager *centralManager;
@property (strong,nonatomic) NSMutableDictionary* dicBleDevices;
@property (strong,nonatomic) NSMutableDictionary* dicBlunoDevices;

@end

@implementation DFBlunoManager

#pragma mark- Functions

+ (id)sharedInstance
{
	static DFBlunoManager* this	= nil;
    
	if (!this)
    {
		this = [[DFBlunoManager alloc] init];
        this.dicBleDevices = [[NSMutableDictionary alloc] init];
        this.dicBlunoDevices = [[NSMutableDictionary alloc] init];
        this->_bSupported = NO;
        this.centralManager = [[CBCentralManager alloc]initWithDelegate:this queue:nil];
    }
    
	return this;
}

- (void)configureSensorTag:(CBPeripheral*)peripheral
{
    
    CBUUID *sUUID = [CBUUID UUIDWithString:kBlunoService];
    CBUUID *cUUID = [CBUUID UUIDWithString:kBlunoDataCharacteristic];
    
    [BLEUtility setNotificationForCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID enable:YES];
    NSString* key = [peripheral.identifier UUIDString];
    DFBlunoDevice* blunoDev = [self.dicBlunoDevices objectForKey:key];
    blunoDev->_bReadyToWrite = YES;
    if ([((NSObject*)_delegate) respondsToSelector:@selector(readyToCommunicate:)])
    {
        [_delegate readyToCommunicate:blunoDev];
    }
    
}

- (void)deConfigureSensorTag:(CBPeripheral*)peripheral
{
    
    CBUUID *sUUID = [CBUUID UUIDWithString:kBlunoService];
    CBUUID *cUUID = [CBUUID UUIDWithString:kBlunoDataCharacteristic];
    
    [BLEUtility setNotificationForCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    
}
//扫描周围的蓝牙
- (void)scan
{
    [self.centralManager stopScan];
    //[self.dicBleDevices removeAllObjects];
    //[self.dicBlunoDevices removeAllObjects];
    if (_bSupported)
    {
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kBlunoService]] options:nil];
    }

}

- (void)stop
{
    [self.centralManager stopScan];
}

- (void)clear
{
    [self.dicBleDevices removeAllObjects];
    [self.dicBlunoDevices removeAllObjects];
}
//选中BuleTooth调用方法
- (void)connectToDevice:(DFBlunoDevice*)dev
{
    BLEDevice* bleDev = [self.dicBleDevices objectForKey:dev.identifier];
    [bleDev.centralManager connectPeripheral:bleDev.peripheral options:nil];
}

- (void)disconnectToDevice:(DFBlunoDevice*)dev
{
    BLEDevice* bleDev = [self.dicBleDevices objectForKey:dev.identifier];
    [self deConfigureSensorTag:bleDev.peripheral];
    [bleDev.centralManager cancelPeripheralConnection:bleDev.peripheral];
}

#pragma mark - CBCentralManager delegate
//1
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn)
    {
        _bSupported = NO;
        NSArray* aryDeviceKeys = [self.dicBlunoDevices allKeys];
        for (NSString* strKey in aryDeviceKeys)
        {
            DFBlunoDevice* blunoDev = [self.dicBlunoDevices objectForKey:strKey];
            blunoDev->_bReadyToWrite = NO;
        }
        
    }
    else
    {
        _bSupported = YES;
        
    }
    
    if ([((NSObject*)_delegate) respondsToSelector:@selector(bleDidUpdateState:)])
    {
        [_delegate bleDidUpdateState:_bSupported];
    }
    
}
//也就是收到了一个周围的蓝牙发来的广告信息，这是CBCentralManager会通知代理来处理
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString* key = [peripheral.identifier UUIDString];
    BLEDevice* dev = [self.dicBleDevices objectForKey:key];
    if (dev !=nil )
    {
        //if ([dev.peripheral isEqual:peripheral])
        {
            dev.peripheral = peripheral;
            if ([((NSObject*)_delegate) respondsToSelector:@selector(didDiscoverDevice:)])
            {
                DFBlunoDevice* blunoDev = [self.dicBlunoDevices objectForKey:key];
                [_delegate didDiscoverDevice:blunoDev];
            }
        }
    }
    else
    {
        BLEDevice* bleDev = [[BLEDevice alloc] init];
        bleDev.peripheral = peripheral;
        bleDev.centralManager = self.centralManager;
        [self.dicBleDevices setObject:bleDev forKey:key];
        DFBlunoDevice* blunoDev = [[DFBlunoDevice alloc] init];
        blunoDev.identifier = key;
        blunoDev.name = peripheral.name;
        [self.dicBlunoDevices setObject:blunoDev forKey:key];

        if ([((NSObject*)_delegate) respondsToSelector:@selector(didDiscoverDevice:)])
        {
            [_delegate didDiscoverDevice:blunoDev];
        }
    }
//    NSLog(@"aaaaaaaa====");
}

//当连接上某个蓝牙之后，CBCentralManager会通知代理处理
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //因为在后面我们要从外设蓝牙那边再获取一些信息，并与之通讯，这些过程会有一些事件可能要处理，所以要给这个外设设置代理
    peripheral.delegate = self;
    [self.centralManager stopScan];
    //查询蓝牙服务
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSString* key = [peripheral.identifier UUIDString];
    DFBlunoDevice* blunoDev = [self.dicBlunoDevices objectForKey:key];
    blunoDev->_bReadyToWrite = NO;
    if ([((NSObject*)_delegate) respondsToSelector:@selector(didDisconnectDevice:)])
    {
        [_delegate didDisconnectDevice:blunoDev];
    }
}

#pragma  mark - CBPeripheral delegate
//返回的蓝牙服务通知通过代理实现
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //查询服务所带的特征值
    for (CBService *s in peripheral.services) [peripheral discoverCharacteristics:nil forService:s];
}
//返回的蓝牙特征值通知通过代理实现
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:kBlunoService]])
    {
        [self configureSensorTag:peripheral];
    }
}


-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"pppppppp=====");
    
    
}
//处理蓝牙发过来的数据
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if ([((NSObject*)_delegate) respondsToSelector:@selector(didReceiveData:Device:)])
    {
        NSString* key = [peripheral.identifier UUIDString];
        DFBlunoDevice* blunoDev = [self.dicBlunoDevices objectForKey:key];
        [_delegate didReceiveData:characteristic.value Device:blunoDev];
    }
//     NSLog(@"ooooooo=====%@",characteristic.value);
//        NSLog(@"%@",peripheral.identifier.UUIDString);
}
//给蓝牙发数据,[peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];,这时还会触发一个代理事件
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([((NSObject*)_delegate) respondsToSelector:@selector(didWriteData:)])
    {
        NSString* key = [peripheral.identifier UUIDString];
        DFBlunoDevice* blunoDev = [self.dicBlunoDevices objectForKey:key];
        [_delegate didWriteData:blunoDev];
    }
     NSLog(@"uuuuuuuu=====");
}

@end
