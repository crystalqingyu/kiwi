//
//  ActRecordCell.m
//  Macaca
//
//  Created by Julie on 14/12/9.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "ActRecordCell.h"
#import "ActRecordCellItem.h"

@interface ActRecordCell ()

//@property (strong, nonatomic) IBOutlet UIImageView *iconView;
//@property (weak, nonatomic) IBOutlet UIImageView *borderView;
//@property (weak, nonatomic) IBOutlet UIImageView *middleView;
//@property (strong, nonatomic) IBOutlet UILabel *titleLable;

@end

@implementation ActRecordCell

- (void)awakeFromNib {
    // cell设为圆角
    self.iconView.layer.cornerRadius = self.iconView.frame.size.width/2;
    self.iconView.clipsToBounds = YES;
    self.borderView.layer.cornerRadius = self.borderView.frame.size.width/2;
    self.borderView.clipsToBounds = YES;
    self.middleView.layer.cornerRadius = self.middleView.frame.size.width/2;
    self.middleView.clipsToBounds = YES;
    
}

// 重写setActItem，为cell各个部分赋值
- (void)setActItem:(ActRecordCellItem *)actItem {
    // 初始化分隔线与圆圈的颜色
    [[self viewWithTag:1] setBackgroundColor:[UIColor lightGrayColor]];
    [[self viewWithTag:2] setBackgroundColor:[UIColor lightGrayColor]];
    [[self viewWithTag:3] setBackgroundColor:[UIColor colorWithRed:193.0/255.0 green:193.0/255 blue:193.0/255 alpha:1]];
    _actItem = actItem;
    [self setUpIcon];
    [self setUpTitle];
    // 如果是空的图片设为白色
    if (self.iconView.image==nil) {
        [[self viewWithTag:1] setBackgroundColor:[UIColor whiteColor]];
        [[self viewWithTag:2] setBackgroundColor:[UIColor whiteColor]];
        [[self viewWithTag:3] setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)setUpIcon {
    self.iconView.image = [UIImage imageNamed:_actItem.icon];
}

- (void)setUpTitle {
    self.titleLable.text = _actItem.title;
}

@end
