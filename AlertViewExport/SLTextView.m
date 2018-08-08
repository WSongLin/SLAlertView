//
//  SLTextView.m
//  SLAlertView
//
//  Created by sl on 2018/8/8.
//  Copyright © 2018年 WSonglin. All rights reserved.
//

#import "SLTextView.h"

@implementation SLTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChange:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:nil
         ];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = [placeholder copy];
    [self setNeedsDisplay];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    [self setNeedsDisplay];
}

//重写系统方法- (void)setFont:(UIFont *)font保持font一致
- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self setNeedsDisplay];
}

//重写系统方法- (void)setText:(NSString *)text控制是否绘制placeholder
- (void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsDisplay];
}

#pragma mark - NSNotification
- (void)textDidChange:(NSNotification *)notification {
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    //hasText是一个系统的BOOL属性，若UITextView开始输入则hasText为YES，否则为NO
    if ([self hasText]) {
        return;
    }
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = self.placeholderColor ? self.placeholderColor : [UIColor grayColor];
    attrs[NSFontAttributeName] = self.font ? self.font : [UIFont systemFontOfSize:12.f];
    
    CGFloat x = 5.f;
    CGFloat y = 8.f;
    CGFloat w = self.bounds.size.width - 2 * x;
    CGFloat h = self.bounds.size.height - 2 * y;
    CGRect placeholderRect = CGRectMake(x, y, w, h);
    
    [self.placeholder drawInRect:placeholderRect withAttributes:attrs];
}

@end
