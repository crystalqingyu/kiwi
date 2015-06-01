//
//  GuideViewController.m
//  Macaca
//
//  Created by Julie on 15/2/10.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import "GuideViewController.h"

#define kImageCount 5

@interface GuideViewController () <UIScrollViewDelegate> {
    CGFloat _w;
    CGFloat _h;
}
@property (weak, nonatomic) IBOutlet UIScrollView *guideScrollView;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _w = self.view.frame.size.width;
    _h = self.view.frame.size.height;
    
    //循环添加图片
    for (int i = 0; i<kImageCount; i++) {
        NSString* imageName = [NSString stringWithFormat:@"demo%d.png",i];
        UIImageView* imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:imageName];
        if (0.125*_h+_w*4/3<0.75*_h) {
            imageView.frame = CGRectMake(i*_w+(1/6)*_w, 0.125*_h, _w*2/3, 4*_w/3);
        } else {
            imageView.frame = CGRectMake(i*_w+(_w-5*_h/16)/2, _h/8, 5*_h/16, 5*_h/8);
        }
        [_guideScrollView addSubview:imageView];
    }
    //设置scrollView属性
    _guideScrollView.contentOffset = CGPointMake(0, 0);
    _guideScrollView.contentSize = CGSizeMake(kImageCount*_w, 0);
    _guideScrollView.showsVerticalScrollIndicator = NO;
    //创建分页功能
    _guideScrollView.pagingEnabled = YES;
    //显示pageControl底下图片小圆点
    _pageControl.center = CGPointMake(_w*0.5, _h-20);
    _pageControl.bounds = CGRectMake(0, 0, _w, 50);
    _pageControl.numberOfPages = kImageCount;
    _pageControl.currentPage = 0;  //know why =0
    //翻页小圆点跟着滚动
    _guideScrollView.delegate = self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = _guideScrollView.contentOffset.x/_guideScrollView.frame.size.width;
    if (self.navigationController==nil) { // 首次登录时出现的，不是在“新手指引”菜单里
        if (page==kImageCount-1) {
            self.startBtn.hidden = NO;
            self.startBtn.enabled = YES;
        } else {
            self.startBtn.hidden = YES;
            self.startBtn.enabled = NO;
        }
    }
    _pageControl.currentPage = page;    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
