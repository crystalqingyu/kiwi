//
//  ActQueryViewCell.h
//  Macaca
//
//  Created by Julie on 14/12/26.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ActQueryViewCellDelegate <NSObject>
- (void)buttonDeleteActionForItemText:(NSString *)itemText cell: (UITableViewCell*)cell;
- (void)buttonExplodeActionForItemText:(NSString *)itemText cell: (UITableViewCell*)cell;
- (void)cellDidOpen:(UITableViewCell *)cell;
- (void)cellDidClose:(UITableViewCell *)cell;
@end


@interface ActQueryViewCell : UITableViewCell

@property (nonatomic, weak) id<ActQueryViewCellDelegate> delegate;

@property (nonatomic, copy) NSString* itemText; // 设置actQueryViewCellTextLabel按钮的
@property (nonatomic, copy) NSString* itemDetailText; // 设置actQueryViewCellDetailTextLabel按钮的

+ (id)actQueryViewCell; // 添加cell
- (void)openCell; // 这个方法允许 delegate 修改 Cell 的状态

@end
