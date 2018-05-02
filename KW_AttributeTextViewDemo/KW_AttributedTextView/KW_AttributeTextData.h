//
//  KW_AttributeTextData.h
//  KW_LabelText
//
//  Created by LKW on 2018/4/27.
//  Copyright © 2018年 Udo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

/**
 超链接文字的key
 */
typedef NSString * KWHyperLinkText;

/**
 超链接点击回调的key
 */
typedef NSString * KWHyperLinkInfoKey;

/**
 需要忽略设置为超链接的index
 */
typedef NSString * KWIgnoreHyperLinkTextIndex;



@interface KW_AttributeTextData : NSObject


/**
 需要显示的文字
 */
@property (nonatomic, copy) NSString * text;

/**
 文字显示的宽度
 */
@property (nonatomic, assign) CGFloat width;

/**
 文字实际显示的size
 */
@property (nonatomic, assign, readonly) CGSize textRealSize;

/**
 字体 默认16号
 */
@property (nonatomic, strong) UIFont * font;

/**
 字体颜色 默认黑色
 */
@property (nonatomic, strong) UIColor * textColor;

/**
 行间距 默认3
 */
@property (nonatomic, assign) CGFloat lineSpacing;

/**
 字间距 默认0
 */
@property (nonatomic, assign) CGFloat wordSpacing;

/**
 文字的ctFrame
 */
@property (nonatomic, assign) CTFrameRef ctFrame;

/**
 截断模式 默认 kCTLineBreakByWordWrapping
 */
@property (nonatomic, assign) CTLineBreakMode mode;

/**
 文字对齐方式 默认 kCTTextAlignmentLeft
 */
@property (nonatomic, assign) CTTextAlignment textAlignment;

/**
 设置超链接字符串，以需要设置为超链接的字符串为key，value为该超链接Attributed属性
 如果一个超链接文字在文中出现多次，需要忽略其中某些不设置为超链接，
 则在Attributed里面添加 key为IgnoreHyperLinkTextIndex, value为需要忽略的下标（即该超链接在文中第几处出现，下标从0开始计算），有多个时用逗号分开
 exmple: 
    @{@"势趋好": @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor blueColor], IgnoreHyperLinkTextIndex: @"1,2"} 不设置文中第二处、第三处“势趋好”为超链接
 
 exmple:
 text.hyperLinks = @{@"势趋好": @{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor blueColor]},
                     @"200万": @{NSFontAttributeName: [UIFont systemFontOfSize:17], NSForegroundColorAttributeName: [UIColor orangeColor]},
                     @"近年来": @{NSFontAttributeName: [UIFont systemFontOfSize:18], NSForegroundColorAttributeName: [UIColor greenColor]}};
 */
@property (nonatomic, strong) NSDictionary <KWHyperLinkText, NSDictionary *>* hyperLinks;

/**
 所有超链接字符串在文中的range, 只读
 exmple:
 {
 "200万" =     (
 "NSRange: {40, 4}",
 "NSRange: {114, 4}"
 );
 "势趋好" =     (
 "NSRange: {3, 3}",
 "NSRange: {95, 3}",
 "NSRange: {122, 3}"
 );
 "近年来" =     (
 "NSRange: {48, 3}"
 );
 }
 */
@property (nonatomic, strong, readonly) NSDictionary <KWHyperLinkText, NSMutableArray<NSValue *> *>* allLinkTextRanges;



/**
 ⚠️⚠️⚠️
 完成text的配置，当属性设置完成时，必须调用此方法使文字配置生效
 ⚠️⚠️⚠️
 */
- (void)kw_completedDataSetting;

/**
 把点击的point转换成字符串的index

 @param point 当前点击的point
 @return 点击的字符串的index
 */
- (CFIndex)kw_textIndexFromTouchedPoint:(CGPoint)point;

@end


/**
 当前点击的超链接字符串
 */
FOUNDATION_EXPORT KWHyperLinkInfoKey const HyperLinkText;

/**
 当前点击的超链接字符串的NSRange
 */
FOUNDATION_EXPORT KWHyperLinkInfoKey const HyperLinkTextRange;

/**
 当前点击的超链接字符串的在文中的index
 */
FOUNDATION_EXPORT KWHyperLinkInfoKey const HyperLinkTextIndex;

/**
 需要忽略设置为超链接的index
 */
FOUNDATION_EXPORT KWIgnoreHyperLinkTextIndex const IgnoreHyperLinkTextIndex;
