//
//  SLAlertView.m
//  SLAlertView
//
//  Created by sl on 2018/8/8.
//  Copyright © 2018年 WSonglin. All rights reserved.
//

#import "SLAlertView.h"
#import "SLTextView.h"

static CGFloat const SLAlertViewTitleFont = 18.f;
static CGFloat const SLAlertViewMessageFont = 14.f;
static CGFloat const SLAlertViewTopMargin = 10.f;

@interface SLAlertView ()<UITextFieldDelegate, UITextViewDelegate> {
    CGFloat flyoutViewHeight;
    NSTimeInterval timeDelay;
    NSTimer *timer;
    BOOL isAutoDismiss;
}

@property (nonatomic, weak) UIView      *alphaBackgroundView;
@property (nonatomic, weak) UIView      *flyoutView;//弹出视图
@property (nonatomic, weak) UILabel     *titleLabel;
@property (nonatomic, weak) UILabel     *messageLabel;
@property (nonatomic, weak) UITextField *plainTextField;
@property (nonatomic, weak) UITextField *passwordTextField;
@property (nonatomic, weak) SLTextView  *textView;

@property (nonatomic, strong) NSMutableArray *buttonTitles;
@property (nonatomic, weak) id<SLAlertViewDelegate>delegate;

@property (nonatomic, assign) SLAlertViewStyle alertViewStyle;

@end

@implementation SLAlertView

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                        style:(SLAlertViewStyle)style
                     delegate:(id)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... {
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.4f];
        [self setFrame:frame];
        
        flyoutViewHeight = 0.f;
        isAutoDismiss = NO;
        
        self.titleLabel.text = title;
        self.messageLabel.text = message;
        self.delegate = delegate;
        self.alertViewStyle = style;
        self.buttonTitles = @[].mutableCopy;
        
        if (cancelButtonTitle) {
            [self.buttonTitles addObject:cancelButtonTitle];
        }
        
        if (otherButtonTitles) {
            [self.buttonTitles addObject:otherButtonTitles];
        }
        
        va_list argList;
        va_start(argList, otherButtonTitles);
        NSString *buttonTitleString;
        while ((buttonTitleString = va_arg(argList, NSString *))) {
            [self.buttonTitles addObject:buttonTitleString];
        }
        va_end(argList);
    }
    
    return self;
}

- (instancetype)initAutoDismissAlertViewWithTitle:(NSString *)title message:(NSString *)message dismissAfterDelay:(NSTimeInterval)delay {
    CGRect frame = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.4f];
        [self setFrame:frame];
        
        flyoutViewHeight = 0.f;
        timeDelay = delay;
        isAutoDismiss = YES;
        
        self.buttonTitles = [NSMutableArray array];
        self.titleLabel.text = title;
        self.messageLabel.text = message;
        self.alertViewStyle = SLAlertViewStyleDefault;
    }
    return self;
}

- (instancetype)initAutoDismissAlertViewWithMessage:(NSString *)message {
    CGRect frame = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.4f];
        [self setFrame:frame];
        
        flyoutViewHeight = 0.f;
        timeDelay = 2.f;
        isAutoDismiss = YES;
        
        self.buttonTitles = [NSMutableArray array];
        self.titleLabel.text = nil;
        self.messageLabel.text = message;
        self.alertViewStyle = SLAlertViewStyleDefault;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)show {
    [self settingFrame];
    
    if (isAutoDismiss) {
        timer = [NSTimer scheduledTimerWithTimeInterval:timeDelay target:self selector:@selector(dismissAlertView) userInfo:nil repeats:NO];
    }
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex {
    if (self.alertViewStyle == SLAlertViewStylePlainTextInput) {
        if (0 == textFieldIndex) {
            return self.plainTextField;
        }
    } else if (self.alertViewStyle == SLAlertViewStyleSecureTextInput) {
        if (0 == textFieldIndex) {
            return self.passwordTextField;
        }
    } else if (self.alertViewStyle == SLAlertViewStyleLoginAndPasswordInput) {
        if (0 == textFieldIndex) {
            return self.plainTextField;
        } else if (1 == textFieldIndex) {
            return self.passwordTextField;
        }
    }
    
    return nil;
}

- (SLTextView *)textViewAtIndex:(NSInteger)textViewIndex {
    if (self.alertViewStyle == SLAlertViewStyleTextViewInput) {
        if (0 == textViewIndex) {
            return self.textView;
        }
    }
    
    return nil;
}

#pragma mark - Event response
- (void)buttonTap:(id)sender {
    UIButton *button = (UIButton *)sender;
    if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:button.tag];
    }
    
    [self removeFromSuperview];
}

- (void)doneButtonTap:(id)sender {
    [self.textView resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (range.location > 100) {
        SLAlertView *alertView = [[SLAlertView alloc] initAutoDismissAlertViewWithMessage:@"已超出100字上限"];
        [alertView show];
        return NO;
    }
    return YES;
}

#pragma mark - Private method
#pragma mark - LayoutSubviews
- (void)settingFrame {
    if (self.superview) {
        [self removeFromSuperview];
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    if (0 == CGRectGetWidth(self.bounds) || 0 == CGRectGetHeight(self.bounds)) {
        return;
    }
    
    if (isAutoDismiss) {
        self.alertViewStyle = SLAlertViewStyleDefault;
        self.buttonTitles = [NSMutableArray array];
    }
    
    CGFloat width = CGRectGetWidth(self.bounds) * 7 / 8;
    [self layoutTitleLabelWithWidth:width];
    [self layoutMessageLabelWithWidth:width];
    
    if (self.alertViewStyle == SLAlertViewStyleSecureTextInput) {
        [self layoutPasswordTextFieldWithWidth:width];
    } else if (self.alertViewStyle == SLAlertViewStylePlainTextInput) {
        [self layoutPlainTextFieldWithWidth:width];
    } else if (self.alertViewStyle == SLAlertViewStyleLoginAndPasswordInput) {
        [self layoutPlainTextFieldWithWidth:width];
        [self layoutPasswordTextFieldWithWidth:width];
    } else if (self.alertViewStyle == SLAlertViewStyleTextViewInput) {
        [self layoutTextViewWithWidth:width];
    }
    
    [self layoutButtonsWithWidth:width];
    
    CGRect rect = CGRectZero;
    rect.size.width = width;
    if (0 == self.buttonTitles.count) {
        rect.size.height = flyoutViewHeight + SLAlertViewTopMargin;
    } else {
        rect.size.height = flyoutViewHeight;
    }
    
    [self.flyoutView setFrame:rect];
    
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    [self.flyoutView setCenter:center];
}

#pragma mark 布局标题
- (void)layoutTitleLabelWithWidth:(CGFloat)width {
    if (!self.titleLabel.text || [self.titleLabel.text isEqualToString:@""]) {
        return;
    }
    
    CGSize size = [self getStringSizeWithString:self.titleLabel.text FontSize:SLAlertViewTitleFont maxWidth:width maxHeight:MAXFLOAT];
    CGRect rect = self.frame;
    rect.origin.x = SLAlertViewTopMargin;
    rect.origin.y = SLAlertViewTopMargin;
    rect.size.width = width - SLAlertViewTopMargin * 2;
    rect.size.height = size.height;
    [self.titleLabel setFrame:rect];
    
    flyoutViewHeight += rect.size.height + SLAlertViewTopMargin;
}

#pragma mark 布局消息
- (void)layoutMessageLabelWithWidth:(CGFloat)width {
    if (!self.messageLabel.text || [self.messageLabel.text isEqualToString:@""]) {
        return;
    }
    
    CGSize size = [self getStringSizeWithString:self.messageLabel.text FontSize:SLAlertViewMessageFont maxWidth:width maxHeight:MAXFLOAT];
    CGRect rect = self.frame;
    rect.origin.x = SLAlertViewTopMargin;
    if (!self.titleLabel.text || [self.titleLabel.text isEqualToString:@""]) {
        rect.origin.y = SLAlertViewTopMargin;
    } else {
        rect.origin.y = CGRectGetMaxY(self.titleLabel.frame) + SLAlertViewTopMargin;
    }
    
    rect.size.width = width - SLAlertViewTopMargin * 2;
    rect.size.height = size.height > 44.f ? size.height : 44.f;
    [self.messageLabel setFrame:rect];
    
    flyoutViewHeight += rect.size.height + SLAlertViewTopMargin;
}

#pragma mark 布局plainTextField
- (void)layoutPlainTextFieldWithWidth:(CGFloat)width {
    CGRect rect = CGRectZero;
    rect.origin.x = SLAlertViewTopMargin;
    if ((!self.titleLabel.text || [self.titleLabel.text isEqualToString:@""])
        && (!self.messageLabel.text || [self.messageLabel.text isEqualToString:@""])) {
        rect.origin.y = SLAlertViewTopMargin;
    } else if ((self.titleLabel.text && ![self.titleLabel.text isEqualToString:@""])
               && (!self.messageLabel.text || [self.messageLabel.text isEqualToString:@""])) {
        rect.origin.y = CGRectGetMaxY(self.titleLabel.frame) + SLAlertViewTopMargin;
    } else {
        rect.origin.y = CGRectGetMaxY(self.messageLabel.frame) + SLAlertViewTopMargin;
    }
    
    rect.size.width = width - SLAlertViewTopMargin * 2;
    rect.size.height = 35.f;
    [self.plainTextField setFrame:rect];
    
    flyoutViewHeight += rect.size.height + SLAlertViewTopMargin;
}

#pragma mark 布局passwordTextField
- (void)layoutPasswordTextFieldWithWidth:(CGFloat)width {
    CGRect rect = CGRectZero;
    rect.origin.x = SLAlertViewTopMargin;
    
    if (self.alertViewStyle == SLAlertViewStyleLoginAndPasswordInput) {
        rect.origin.y = CGRectGetMaxY(self.plainTextField.frame) + SLAlertViewTopMargin / 2;
    } else {
        if ((!self.titleLabel.text || [self.titleLabel.text isEqualToString:@""])
            && (!self.messageLabel.text || [self.messageLabel.text isEqualToString:@""])) {
            rect.origin.y = SLAlertViewTopMargin;
        } else if ((self.titleLabel.text && ![self.titleLabel.text isEqualToString:@""])
                   && (!self.messageLabel.text || [self.messageLabel.text isEqualToString:@""])) {
            rect.origin.y = CGRectGetMaxY(self.titleLabel.frame) + SLAlertViewTopMargin;
        } else {
            rect.origin.y = CGRectGetMaxY(self.messageLabel.frame) + SLAlertViewTopMargin;
        }
    }
    rect.size.width = width - SLAlertViewTopMargin * 2;
    rect.size.height = 35.f;
    [self.passwordTextField setFrame:rect];
    
    flyoutViewHeight += rect.size.height + SLAlertViewTopMargin;
}

#pragma mark 布局textView
- (void)layoutTextViewWithWidth:(CGFloat)width {
    CGRect rect = CGRectZero;
    rect.origin.x = SLAlertViewTopMargin;
    if ((!self.titleLabel.text || [self.titleLabel.text isEqualToString:@""])
        && (!self.messageLabel.text || [self.messageLabel.text isEqualToString:@""])) {
        rect.origin.y = SLAlertViewTopMargin;
    } else if ((self.titleLabel.text && ![self.titleLabel.text isEqualToString:@""])
               && (!self.messageLabel.text || [self.messageLabel.text isEqualToString:@""])) {
        rect.origin.y = CGRectGetMaxY(self.titleLabel.frame) + SLAlertViewTopMargin;
    } else {
        rect.origin.y = CGRectGetMaxY(self.messageLabel.frame) + SLAlertViewTopMargin;
    }
    
    rect.size.width = width - SLAlertViewTopMargin * 2;
    rect.size.height = 70.f;
    [self.textView setFrame:rect];
    
    flyoutViewHeight += rect.size.height + SLAlertViewTopMargin;
}

#pragma mark 布局按钮
- (void)layoutButtonsWithWidth:(CGFloat)width {
    if (0 == self.buttonTitles.count || ((!self.titleLabel.text || [self.titleLabel.text isEqualToString:@""])
                                         && (!self.messageLabel.text || [self.messageLabel.text isEqualToString:@""]))) {
        return;
    }
    
    CGFloat buttonOriginY = SLAlertViewTopMargin;
    if (self.alertViewStyle == SLAlertViewStyleLoginAndPasswordInput
        || self.alertViewStyle == SLAlertViewStyleSecureTextInput) {
        buttonOriginY += CGRectGetMaxY(self.passwordTextField.frame);
    } else if (self.alertViewStyle == SLAlertViewStylePlainTextInput) {
        buttonOriginY += CGRectGetMaxY(self.plainTextField.frame);
    } else if (self.alertViewStyle == SLAlertViewStyleTextViewInput) {
        buttonOriginY += CGRectGetMaxY(self.textView.frame);
    } else {
        buttonOriginY += CGRectGetMaxY(self.messageLabel.frame);
    }
    
    CGRect hRect = CGRectZero;
    hRect.origin.y = buttonOriginY;
    hRect.size.width = width;
    hRect.size.height = 1.f;
    
    UIView *horizontalSeparatorLine = [[UIView alloc] initWithFrame:hRect];
    horizontalSeparatorLine.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.f];
    [self.flyoutView addSubview:horizontalSeparatorLine];
    
    UIButton *lastButton = nil;
    CGFloat buttonHeight = 0.f;
    for (NSInteger i = 0; i < self.buttonTitles.count; ++i) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.backgroundColor = [UIColor clearColor];
        [button setTitle:self.buttonTitles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:SLAlertViewMessageFont];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.tag = i;
        [button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.flyoutView addSubview:button];
        
        CGFloat buttonWidth = (width - (self.buttonTitles.count - 1) * 1.f) / self.buttonTitles.count;
        CGRect rect = CGRectZero;
        rect.origin.y = CGRectGetMaxY(horizontalSeparatorLine.frame) + 1.f;
        rect.size.width = buttonWidth;
        rect.size.height = 25.f * [UIScreen mainScreen].scale;
        buttonHeight = rect.size.height;
        
        if (!lastButton) {
            rect.origin.x = 0.f;
        } else {
            rect.origin.x = CGRectGetMaxX(lastButton.frame) + 1.f;
        }
        [button setFrame:rect];
        
        lastButton = button;
        
        if (i != 0) {
            CGRect vRect = CGRectZero;
            vRect.origin.x = CGRectGetMinX(button.frame) - 1.f;
            vRect.origin.y = CGRectGetMinY(button.frame);
            vRect.size.width = 1.f;
            vRect.size.height = CGRectGetHeight(button.bounds);
            
            UIView *verticalSeparatorLine = [[UIView alloc] initWithFrame:vRect];
            verticalSeparatorLine.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.f];
            [self.flyoutView addSubview:verticalSeparatorLine];
        }
    }
    
    flyoutViewHeight += buttonHeight + 1.f + SLAlertViewTopMargin;
}

#pragma mark - 获取字符串大小
- (CGSize)getStringSizeWithString:(NSString *)string FontSize:(CGFloat)fontSize maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGRect rect = [string boundingRectWithSize:CGSizeMake(maxWidth, maxHeight)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:dict
                                       context:nil
                   ];
    return rect.size;
}

- (void)dismissAlertView {
    
    [self removeFromSuperview];
    [timer invalidate];
}

#pragma mark - Getter
- (UIView *)flyoutView {
    if (!_flyoutView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        view.clipsToBounds = YES;
        view.layer.cornerRadius = 12.f;
        [self addSubview:view];
        _flyoutView = view;
    }
    return _flyoutView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:SLAlertViewTitleFont];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [self.flyoutView addSubview:label];
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:SLAlertViewMessageFont];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithWhite:0.4f alpha:1.f];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [self.flyoutView addSubview:label];
        _messageLabel = label;
    }
    return _messageLabel;
}

- (UITextField *)plainTextField {
    if (!_plainTextField) {
        UITextField *textField = [[UITextField alloc] init];
        textField.font = [UIFont systemFontOfSize:SLAlertViewMessageFont];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate = self;
        [self.flyoutView addSubview:textField];
        _plainTextField = textField;
    }
    return _plainTextField;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        UITextField *textField = [[UITextField alloc] init];
        textField.secureTextEntry = YES;
        textField.font = [UIFont systemFontOfSize:SLAlertViewMessageFont];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate = self;
        [self.flyoutView addSubview:textField];
        _passwordTextField = textField;
    }
    return _passwordTextField;
}

- (SLTextView *)textView {
    if (!_textView) {
        SLTextView *view = [[SLTextView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        view.font = [UIFont systemFontOfSize:SLAlertViewMessageFont];
        view.layer.borderWidth = 1.f;
        view.layer.borderColor = [UIColor colorWithWhite:0.89f alpha:1.f].CGColor;
        view.delegate = self;
        view.inputAccessoryView = [self topView];
        [self.flyoutView addSubview:view];
        _textView = view;
    }
    return _textView;
}

- (UIToolbar *)topView {
    UIToolbar *view = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 35.f)];
    view.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1.f];
    UIBarButtonItem *button1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *button2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTap:)];
    NSArray *items = @[button1, button2, doneButton];
    [view setItems:items];
    
    return view;
}

@end
