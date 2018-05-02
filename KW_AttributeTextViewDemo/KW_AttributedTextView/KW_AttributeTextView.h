//
//  KW_AttributeTextView.h
//  KW_LabelText
//
//  Created by LKW on 2018/4/27.
//  Copyright © 2018年 Udo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KW_AttributeTextData.h"

@protocol KW_AttributeTextViewDelegate;

@interface KW_AttributeTextView : UIView

@property (nonatomic, weak) id <KW_AttributeTextViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                         text:(KW_AttributeTextData *)data;

/**
 超链接点击回调 block方式

 @param link 回调block
 */
- (void)kw_hyperLinkClicked:(void (^)(NSDictionary <KWHyperLinkInfoKey, id>* linkInfo))link;

@end



@protocol KW_AttributeTextViewDelegate <NSObject>

/**
 超链接点击回调 delegate方式

 @param linkInfo 回调Info
 */
- (void)kw_hyperLinkClicked:(NSDictionary <KWHyperLinkInfoKey, id>*)linkInfo;

@end






