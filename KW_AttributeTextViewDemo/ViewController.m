//
//  ViewController.m
//  KW_AttributeTextViewDemo
//
//  Created by LKW on 2018/5/2.
//  Copyright © 2018年 Udo. All rights reserved.
//

#import "ViewController.h"
#import "KW_AttributeTextView.h"

@interface ViewController () <KW_AttributeTextViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString * string = @"就业形势趋好，首先归功于经济200保持中高速经济增长。一季度，我国GDP同比增长200万，延续了近年来平稳增长的态势，经济增速符合预期。经济增长拉动就业的能力势趋好。根据测算，目前我国经济势趋好增长每提高一个百分点，能够带动近200万人就业。势趋好";
    
    CGFloat x = 20;
    CGFloat y = 100;
    CGFloat w = self.view.bounds.size.width - 40;
    
    KW_AttributeTextData * data = [[KW_AttributeTextData alloc] init];
    data.width = w;
    data.text = string;
    data.font = [UIFont systemFontOfSize:14];
    data.textColor = [UIColor blackColor];
    
    data.hyperLinks = @{@"势趋好": @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor blueColor], IgnoreHyperLinkTextIndex: @"1"},
                        @"200万": @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor orangeColor]},
                        @"近年来": @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor greenColor]}};
    
    [data kw_completedDataSetting];
    
    KW_AttributeTextView * text = [[KW_AttributeTextView alloc] initWithFrame:CGRectMake(x, y, w, data.textRealSize.height)
                                                                         text:data];
    
    text.delegate = self;
    [self.view addSubview:text];
    
    [text kw_hyperLinkClicked:^(NSDictionary<KWHyperLinkInfoKey,id> *linkInfo) {
        NSLog(@"block clicked hyperLink text == %@", linkInfo);
    }];
}


- (void)kw_hyperLinkClicked:(NSDictionary<KWHyperLinkInfoKey,id> *)linkInfo
{
    NSLog(@"delegate clicked hyperLink text == %@", linkInfo);
}

@end
