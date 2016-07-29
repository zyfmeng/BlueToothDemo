//
//  ListCell.m
//  BlueTooth
//
//  Created by md on 16/5/27.
//  Copyright © 2016年 HKQ. All rights reserved.
//

#import "ListCell.h"

@implementation ListCell
{
    UILabel *nameLab;
    UILabel *connectionLab;
    UIImageView *lineImageView;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        nameLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width-80, 50)];
        nameLab.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:nameLab];
        connectionLab = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-60, 0, 60, 50)];
        connectionLab.textAlignment = NSTextAlignmentCenter;
        connectionLab.font = [UIFont systemFontOfSize:14];
        connectionLab.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:connectionLab];
        lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 49, self.frame.size.width, 1)];
        lineImageView.image = [UIImage imageNamed:@"app_17"];
        [self.contentView addSubview:lineImageView];
    }
    return self;
}
- (void)contentListCell:(DFBlunoDevice *)dev isConnection:(BOOL)isConnection
{
    nameLab.text = dev.name;
//    if (isConnection) {
//        connectionLab.text = @"已连接";
//    }else{
        connectionLab.text = @"";
//    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
