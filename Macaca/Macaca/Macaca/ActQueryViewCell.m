//
//  ActQueryViewCell.m
//  Macaca
//
//  Created by Julie on 14/12/26.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "ActQueryViewCell.h"

// 弹性
static CGFloat const kBounceValue = 20.0f;

@interface ActQueryViewCell() <UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *deleteBtn; //删除键
@property (nonatomic, weak) IBOutlet UIButton *explodeBtn; //分解键
@property (nonatomic, weak) IBOutlet UIView *actQueryViewCellContentView;
@property (nonatomic, weak) IBOutlet UILabel *actQueryViewCellTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *actQueryViewCellDetailTextLabel;
- (IBAction)buttonClicked:(UIButton *)sender;

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;

@end

@implementation ActQueryViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // 生成手势
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.panRecognizer.delegate = self;
    [self.actQueryViewCellContentView addGestureRecognizer:self.panRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

// 生成cell
+ (id)actQueryViewCell {
    return [[NSBundle mainBundle] loadNibNamed:@"ActQueryViewCell" owner:nil options:nil][0];
}

// 监听删除、分解两个按钮
- (IBAction)buttonClicked:(UIButton *)sender {
    if (sender == self.deleteBtn) {
//        NSLog(@"Clicked button delete!");
        [self.delegate buttonDeleteActionForItemText:self.itemText cell:self];
    } else if (sender == self.explodeBtn) {
//        NSLog(@"Clicked button explode!");
        [self.delegate buttonExplodeActionForItemText:self.itemText cell:self];
    } else {
        NSLog(@"Clicked unknown button!");
    }
}

// 重置textLable按钮设置
- (void)setItemText:(NSString *)itemText {
    _itemText = itemText; // 必须写_itemText，不能self.itemText，否则引起死循环
    self.actQueryViewCellTextLabel.text = _itemText;
}
// 重置textDetailLable按钮设置
- (void)setItemDetailText:(NSString *)itemDetailText{
    _itemDetailText = itemDetailText; // 必须写_itemText，不能self.itemText，否则引起死循环
    self.actQueryViewCellDetailTextLabel.text = _itemDetailText;
}

// Pan 手势识别器发动时执行
- (void)panThisCell:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
            // 存储 Cell 的初始位置（例如约束值）以确定 Cell 是要打开还是关闭
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = [recognizer translationInView:self.actQueryViewCellContentView];
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
            break;
            // Cell 默认的“关闭”状态下 处理pan手势识别器
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.actQueryViewCellContentView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {  //1
                panningLeft = YES;
            }
            
            if (self.startingRightLayoutConstraintConstant == 0) { //2
                //The cell was closed and is now opening
                if (!panningLeft) {
                    CGFloat constant = MAX(-deltaX, 0); //3
                    if (constant == 0) { //4
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                    } else { //5
                        self.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    CGFloat constant = MIN(-deltaX, [self buttonTotalWidth]); //6
                    if (constant == [self buttonTotalWidth]) { //7
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    } else { //8
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            }else {
                //The cell was at least partially open.
                CGFloat adjustment = self.startingRightLayoutConstraintConstant - deltaX; //1
                if (!panningLeft) {
                    CGFloat constant = MAX(adjustment, 0); //2
                    if (constant == 0) { //3
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                    } else { //4
                        self.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    CGFloat constant = MIN(adjustment, [self buttonTotalWidth]); //5
                    if (constant == [self buttonTotalWidth]) { //6
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    } else { //7
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            }
            
            self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant; //8
        }
            break;
            // 根据 Cell 是否已经打开或关闭以及手势结束时 Cell 的位置在执行不同的处理
        case UIGestureRecognizerStateEnded:
            if (self.startingRightLayoutConstraintConstant == 0) { //1
                //Cell was opening
                CGFloat halfOfButtonExplode = CGRectGetWidth(self.explodeBtn.frame) / 2; //2
                if (self.contentViewRightConstraint.constant >= halfOfButtonExplode) { //3
                    //Open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Re-close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            } else {
                //Cell was closing
                CGFloat buttonExplodePlusHalfOfButtonDelete = CGRectGetWidth(self.explodeBtn.frame) + (CGRectGetWidth(self.deleteBtn.frame) / 2); //4
                if (self.contentViewRightConstraint.constant >= buttonExplodePlusHalfOfButtonDelete) { //5
                    //Re-open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            }
            break;
            // 由于用户取消了触摸，表示他们不想改变 Cell 当前的状态，所以你只需要将一切都设置为它们原本的样子即可
        case UIGestureRecognizerStateCancelled:
            if (self.startingRightLayoutConstraintConstant == 0) {
                //Cell was closed - reset everything to 0
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
            } else {
                //Cell was open - reset to the open state
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
            break;
        default:
            break;
    }
}

// Cell 最远可以滑动多远
- (CGFloat)buttonTotalWidth {
    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.deleteBtn.frame);
}
- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)notifyDelegate {
    // 在一个 swipe 手势完成时通知 delegate ，无论 Cell 是否以及打开或关闭。
    if (notifyDelegate) {
        [self.delegate cellDidClose:self];
    }
    //TODO: Notify delegate.
    
    if (self.startingRightLayoutConstraintConstant == 0 &&
        self.contentViewRightConstraint.constant == 0) {
        //Already all the way closed, no bounce necessary
        return;
    }
    
    self.contentViewRightConstraint.constant = -kBounceValue;
    self.contentViewLeftConstraint.constant = kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contentViewRightConstraint.constant = 0;
        self.contentViewLeftConstraint.constant = 0;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}
- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate {
    // 在一个 swipe 手势完成时通知 delegate ，无论 Cell 是否以及打开或关闭。
    if (notifyDelegate) {
        [self.delegate cellDidOpen:self];
    }
    //TODO: Notify delegate.
    
    //1
    if (self.startingRightLayoutConstraintConstant == [self buttonTotalWidth] &&
        self.contentViewRightConstraint.constant == [self buttonTotalWidth]) {
        return;
    }
    //2
    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - kBounceValue;
    self.contentViewRightConstraint.constant = [self buttonTotalWidth] + kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        //3
        self.contentViewLeftConstraint.constant = -[self buttonTotalWidth];
        self.contentViewRightConstraint.constant = [self buttonTotalWidth];
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            //4
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

// 生成动画，0.1 秒的间隔和 ease-out curve 动画都是我从实践和错误中总结出来的。如果你找到其他更让你看着愉悦的速度或动画类型，可以自由修改它们
- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.1;
    }
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}
// 确保 Cell 在其回收重利用时再次关闭
- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetConstraintContstantsToZero:NO notifyDelegateDidClose:NO];
}
// 这个方法允许 delegate 修改 Cell 的状态
- (void)openCell {
    [self setConstraintsToShowAllButtons:NO notifyDelegateDidOpen:NO];
}

#pragma mark - UIGestureRecognizerDelegate
// UIPanGestureRecognizer 有时候会影响 UITableView 的 Scroll 操作，告知各手势识别器，它们可以同时工作
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
