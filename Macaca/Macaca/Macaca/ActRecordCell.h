//
//  ActRecordCell.h
//  Macaca
//
//  Created by Julie on 14/12/9.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActRecordCellItem;
@interface ActRecordCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UIImageView *borderView;
@property (weak, nonatomic) IBOutlet UIImageView *middleView;
@property (strong, nonatomic) IBOutlet UILabel *titleLable;

@property (nonatomic, strong) ActRecordCellItem* actItem;

@end
