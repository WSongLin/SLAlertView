//
//  SLAlertView.h
//  SLAlertView
//
//  Created by sl on 2018/8/8.
//  Copyright © 2018年 WSonglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLTextView;

typedef NS_ENUM(NSInteger, SLAlertViewStyle) {
    SLAlertViewStyleDefault = 0,           //默认风格
    SLAlertViewStyleSecureTextInput,       //密码输入框风格
    SLAlertViewStylePlainTextInput,        //普通输入框风格
    SLAlertViewStyleLoginAndPasswordInput, //账号密码框风格
    SLAlertViewStyleTextViewInput          //富文本风格
};

@class SLAlertView;

@protocol SLAlertViewDelegate <NSObject>

@optional
/**
 点击按钮触发代理
 
 @param alertView   告警框
 @param buttonIndex 按钮下标索引(从0开始)
 */
- (void)alertView:(SLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface SLAlertView : UIView

/**
 初始化弹窗

 @param title 标题
 @param message 提示信息
 @param style 弹窗风格
 @param delegate 委托对象
 @param cancelButtonTitle 取消按钮
 @param otherButtonTitles 可变动按钮
 @return SLAlertView对象
 */
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                        style:(SLAlertViewStyle)style
                     delegate:(id)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ...NS_REQUIRES_NIL_TERMINATION;

/**
 在给定的时间(delay)后自动消失（显示标题）

 @param title 标题
 @param message 提示信息
 @param delay 延迟消失时间
 @return SLAlertView对象
 */
- (instancetype)initAutoDismissAlertViewWithTitle:(NSString *)title message:(NSString *)message dismissAfterDelay:(NSTimeInterval)delay;

/**
 2s后自动消失

 @param message 提示信息
 @return SLAlertView对象
 */
- (instancetype)initAutoDismissAlertViewWithMessage:(NSString *)message;

/**
 显示弹窗
 */
- (void)show;

/**
 根据索引检索文本字段
 
 @param textFieldIndex 若索引值为0，则为第一个文本字段（单个文本字段或登录文本字段），若为1，则为密码文本字段
 @return UITextField
 */
- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex;

/**
 根据索引检索富文本
 
 @param textViewIndex 索引值--0
 @return UITextView
 */
- (SLTextView *)textViewAtIndex:(NSInteger)textViewIndex;


@end
