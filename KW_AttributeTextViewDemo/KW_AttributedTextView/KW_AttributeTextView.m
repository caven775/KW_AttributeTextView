//
//  KW_AttributeTextView.m
//  KW_LabelText
//
//  Created by LKW on 2018/4/27.
//  Copyright © 2018年 Udo. All rights reserved.
//

#import "KW_AttributeTextView.h"


@interface KW_AttributeTextView ()

@property (nonatomic, strong) KW_AttributeTextData * text;
@property (nonatomic, copy) void (^linkCallBack)(NSDictionary <KWHyperLinkInfoKey, id>* linkInfo);

@end


@implementation KW_AttributeTextView

- (instancetype)initWithFrame:(CGRect)frame
                         text:(KW_AttributeTextData *)data
{
    self = [super initWithFrame:frame];
    if (self) {
        self.text = data;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)kw_hyperLinkClicked:(void (^)(NSDictionary <KWHyperLinkInfoKey, id>* linkInfo))link
{
    self.linkCallBack = link;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CTFrameDraw(self.text.ctFrame, context);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    BOOL touchedInHyperLinkText = NO;
    UITouch * touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    CFIndex idx = [self.text kw_textIndexFromTouchedPoint:point];
    if (idx < self.text.text.length && idx > -1) {
        unichar c = [self.text.text characterAtIndex:idx];
        NSLog(@"current touched text == %@", [[NSString alloc] initWithCharacters:&c length:1]);
        for (KWHyperLinkText key in self.text.allLinkTextRanges.allKeys) {
            NSArray * ranges = self.text.allLinkTextRanges[key];
            NSDictionary * attributed = self.text.hyperLinks[key];
            for (int i = 0; i < ranges.count; i ++) {
                NSValue * value = ranges[i];
                NSRange range = [value rangeValue];
                NSString * indexs = attributed[IgnoreHyperLinkTextIndex];
                if (indexs) {
                    NSArray * indexArray = [indexs componentsSeparatedByString:@","];
                    NSString * y = [NSString stringWithFormat:@"%@", @(i)];
                    touchedInHyperLinkText = NSLocationInRange(idx, range) && ![indexArray containsObject:y];
                } else {
                    touchedInHyperLinkText = NSLocationInRange(idx, range);
                }
                if (touchedInHyperLinkText) {
                    NSDictionary * info = @{HyperLinkText           : key,
                                            HyperLinkTextRange      : value,
                                            HyperLinkTextIndex      : @(i)};
                    if (self.linkCallBack) {
                        self.linkCallBack(info);
                    }
                    if ([self.delegate respondsToSelector:@selector(kw_hyperLinkClicked:)]) {
                        [self.delegate kw_hyperLinkClicked:info];
                    }
                    break;
                }
            }
        }
    }
}

@end
