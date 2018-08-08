//
//  SLTextView.h
//  SLAlertView
//
//  Created by sl on 2018/8/8.
//  Copyright © 2018年 WSonglin. All rights reserved.
//

#import <UIKit/UIKit.h>

//因为要重写部分系统方法，所以用子类化而不是分类
@interface SLTextView : UITextView

//占位符文字
@property (nonatomic, copy)   NSString *placeholder;

//占位符文字颜色
@property (nonatomic, strong) UIColor  *placeholderColor;

@end
