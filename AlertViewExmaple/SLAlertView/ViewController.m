//
//  ViewController.m
//  SLAlertView
//
//  Created by sl on 2018/8/8.
//  Copyright © 2018年 WSonglin. All rights reserved.
//

#import "ViewController.h"
#import "SLAlertView.h"

static NSString * const kReuseIdentifier = @"Cell";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, SLAlertViewDelegate>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSArray *tableDatas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.tableView setFrame:(CGRect){0.f, 200.f, CGRectGetWidth(self.view.bounds), 500.f}];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.tableDatas[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (5 == indexPath.row) {
        NSString *title = self.tableDatas[indexPath.row];
        NSInteger delay = 1;
        NSString *message = [NSString stringWithFormat:@"弹窗将在%lds后消失!", (long)delay];
        SLAlertView *alertView = [[SLAlertView alloc] initAutoDismissAlertViewWithTitle:title
                                                                                message:message
                                                                      dismissAfterDelay:delay
                                  ];
        [alertView show];
    } else if (6 == indexPath.row) {
        NSString *message = [NSString stringWithFormat:@"弹窗将在2s后消失!"];
        SLAlertView *alertView = [[SLAlertView alloc] initAutoDismissAlertViewWithMessage:message];
        [alertView show];
    } else {
        NSString *title = self.tableDatas[indexPath.row];
        NSString *message = [NSString stringWithFormat:@"我是你要的%@", title];
        
        SLAlertView *alertView = [[SLAlertView alloc] initWithTitle:title
                                                            message:message
                                                              style:indexPath.row
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确认",
                                  nil];
        [alertView show];
    }
}

#pragma mark - SLAlertViewDelegate
- (void)alertView:(SLAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.tableFooterView = [UIView new];
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReuseIdentifier];
        [self.view addSubview:tableView];
        
        _tableView = tableView;
    }
    
    return _tableView;
}

- (NSArray *)tableDatas {
    return @[@"默认风格", @"密码输入框风格", @"普通输入框风格", @"账号密码框风格", @"富文本风格", @"指定时间消失", @"2s后消失"];
}

@end
