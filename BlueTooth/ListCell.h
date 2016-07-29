//
//  ListCell.h
//  BlueTooth
//
//  Created by md on 16/5/27.
//  Copyright © 2016年 HKQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFBlunoDevice.h"
@interface ListCell : UITableViewCell

- (void)contentListCell:(DFBlunoDevice *)dev isConnection:(BOOL)isConnection;

@end
