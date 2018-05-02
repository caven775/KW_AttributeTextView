//
//  KW_AttributeTextData.m
//  KW_LabelText
//
//  Created by LKW on 2018/4/27.
//  Copyright © 2018年 Udo. All rights reserved.
//

#import "KW_AttributeTextData.h"

KWHyperLinkInfoKey const HyperLinkText          = @"HyperLinkText";
KWHyperLinkInfoKey const HyperLinkTextRange     = @"HyperLinkTextRange";
KWIgnoreHyperLinkTextIndex const IgnoreHyperLinkTextIndex = @"KWIgnoreHyperLinkTextIndex";


@interface KW_AttributeTextData ()

@property (nonatomic, strong) NSMutableDictionary <KWHyperLinkText, NSMutableArray<NSValue *> *>* linkTextRanges;

@end

@implementation KW_AttributeTextData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.wordSpacing = 0;
        self.lineSpacing = 3;
        self.textColor = [UIColor blackColor];
        self.font = [UIFont systemFontOfSize:16];
        self.mode = kCTLineBreakByWordWrapping;
        self.textAlignment = kCTTextAlignmentLeft;
    }
    return self;
}

- (void)setCtFrame:(CTFrameRef)ctFrame
{
    if (_ctFrame != ctFrame) {
        if (_ctFrame != nil) {
            CFRelease(_ctFrame);
        }
        CFRetain(ctFrame);
        _ctFrame = ctFrame;
    }
}

- (NSMutableDictionary<KWHyperLinkText, NSMutableArray<NSValue *> *> *)linkTextRanges
{
    if (!_linkTextRanges) {
        _linkTextRanges = [[NSMutableDictionary alloc] init];
    }
    return _linkTextRanges;
}

/**
 获取绘制文字的CTFrame

 @return CTFrame
 */
- (CTFrameRef)textCTFrame
{
    CGSize size = CGSizeMake(self.width, CGFLOAT_MAX);
    NSAttributedString * attributedContent = [self attributedContentText];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedContent);
    CGSize textRealSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, size, nil);
    _textRealSize = textRealSize;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, self.width, textRealSize.height));
    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    self.ctFrame = ctFrame;
    
    CFRelease(path);
    CFRelease(framesetter);
    return ctFrame;
}

/**
 配置文字显示属性

 @return attributedText
 */
- (NSAttributedString *)attributedContentText
{
    [self attributeHyperLinkText];
    CGFloat lineSpacing = self.lineSpacing;
    NSMutableAttributedString * attributedContent = nil;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    
    CGFloat minLineHeight = self.font.pointSize;
    CGFloat maxLineHeight = self.font.pointSize + self.font.pointSize/2.0;
    
    CTLineBreakMode textMode = self.mode;
    CTTextAlignment textAlignment = self.textAlignment;
    
    const CFIndex kNumberOfSettings = 7;
    CTParagraphStyleSetting setting[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierAlignment,                   sizeof(textAlignment), &textAlignment},
        {kCTParagraphStyleSpecifierMinimumLineHeight,           sizeof(minLineHeight),&minLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineHeight,           sizeof(maxLineHeight),&maxLineHeight},
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,       sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierMaximumLineSpacing,          sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierMinimumLineSpacing,          sizeof(CGFloat), &lineSpacing},
        {kCTParagraphStyleSpecifierLineBreakMode,               sizeof(CTLineBreakMode),&textMode}
    };
    CTParagraphStyleRef styleRef = CTParagraphStyleCreate(setting, kNumberOfSettings);
    NSDictionary * attributed = @{(id)kCTForegroundColorAttributeName:  (id)self.textColor,
                                  (id)kCTParagraphStyleAttributeName:   (id)styleRef,
                                  (id)kCTFontAttributeName:             (__bridge id)fontRef,
                                  (id)kCTKernAttributeName:             (id)@(self.wordSpacing)};
    attributedContent = [[NSMutableAttributedString alloc] initWithString:self.text attributes:attributed];
    [self setHyperLinkText:attributedContent];

    CFRelease(fontRef);
    CFRelease(styleRef);
    return attributedContent;
}

- (void)setHyperLinkText:(NSMutableAttributedString *)attributedContent
{
    if (self.hyperLinks.count) {
        _allLinkTextRanges = self.linkTextRanges;
        for (KWHyperLinkText key in self.hyperLinks.allKeys) {
            NSArray * values = self.linkTextRanges[key];
            for (int i = 0; i < values.count; i ++) {
                NSRange range = [values[i] rangeValue];
                NSDictionary * linkTextAttributed = self.hyperLinks[key];
                if ((range.location + range.length <= attributedContent.length) && linkTextAttributed) {
                    NSString * idx = linkTextAttributed[IgnoreHyperLinkTextIndex];
                    if (idx) {
                        NSArray * idxArray = [idx componentsSeparatedByString:@","];
                        NSString * y = [NSString stringWithFormat:@"%@", @(i)];
                        if (![idxArray containsObject:y]) {
                            [attributedContent setAttributes:linkTextAttributed range:range];
                        }
                    } else {
                        [attributedContent setAttributes:linkTextAttributed range:range];
                    }
                }
            }
        }
    }
}

/**
 计算超链接字符串的range
 */
- (void)attributeHyperLinkText
{
    if (self.hyperLinks.allKeys.count) {
        for (KWHyperLinkText key in self.hyperLinks.allKeys) {
            [self saveHyperLinkTextRange:key originText:self.text];
        }
    }
}

/**
 保存每个超链接的range

 @param linkText 超链接字符串
 @param origin 超链接所在的字符串
 */
- (void)saveHyperLinkTextRange:(KWHyperLinkText)linkText originText:(NSString *)origin
{
    static NSString * text = @"";
    NSRange range = [origin rangeOfString:linkText];
    if (range.location != NSNotFound) {
        NSMutableArray * values = self.linkTextRanges[linkText];
        if (!values) {
            values = [[NSMutableArray alloc] init];
        }
        NSString * preString = [origin substringToIndex:range.location + range.length];
        NSString * suffString = [origin substringFromIndex:range.location + range.length];
        NSMutableString * append = [[NSMutableString alloc] initWithString:text];
        [append appendString:preString];
        text = append;
        NSValue * value = [NSValue valueWithRange:NSMakeRange(text.length - linkText.length, linkText.length)];
        [values addObject:value];
        [self.linkTextRanges setValue:values forKey:linkText];
        if (suffString.length >= linkText.length) {
            [self saveHyperLinkTextRange:linkText originText:suffString];
        } else {
            text = @"";
        }
    } else {
        text = @"";
    }
}


/**
 ⚠️⚠️⚠️
 完成text的配置，当属性设置完成时，必须调用此方法使文字配置生效
 ⚠️⚠️⚠️
 */
- (void)kw_completedDataSetting
{
    self.ctFrame = [self textCTFrame];
}

/**
 把点击的point转换成字符串的index
 
 @param point 当前点击的point
 @return 点击的字符串的index
 */
- (CFIndex)kw_textIndexFromTouchedPoint:(CGPoint)point
{
    CGRect frame = {{0, 0}, self.textRealSize};
    CTFrameRef ctframe = self.ctFrame;
    CFArrayRef lines = CTFrameGetLines(ctframe);
    if (!lines) { return -1; }
    CFIndex count = CFArrayGetCount(lines);
    CGPoint origins[count];
    CTFrameGetLineOrigins(ctframe, CFRangeMake(0, 0), origins);
    //翻转坐标系
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, frame.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    CFIndex idx = -1;
    
    for (int i = 0; i < count; i ++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        if (CGRectContainsPoint(rect, point)) {
            // 将点击的坐标转换成相对于当前行的坐标，需要把文字的宽度减去（一般是pointSize的一半）
            CGPoint relativePoint = CGPointMake(point.x - CGRectGetMinX(rect) - self.font.pointSize/2.0,
                                                point.y - CGRectGetMinY(rect));
            // 获得当前点击坐标对应的字符串偏移
            idx = CTLineGetStringIndexForPosition(line, relativePoint);
        }
    }
    return idx;
}

/**
 获得每一行的CGRect
 
 @param line 当前行
 @param point 当前行的point
 @return CGRect
 */
- (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point
{
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}

- (void)dealloc
{
    if (_ctFrame) {
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }
}

@end
