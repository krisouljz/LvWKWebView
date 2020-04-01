//
//  ICXBaseWebLoadVC.h
//  ICXWebViewModule_Example
//
//  Created by TYFanrong on 2018/2/7.
//  Copyright © 2018年  吕佳珍. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"

@interface ICXBaseWebLoadVC : UIViewController

@property (nonatomic,assign) long personID;

@property (nonatomic,copy) NSString *loadUrl;

@property (nonatomic,copy) NSString *planID;

@property (nonatomic,copy) NSString *vctitle;


/**
 点击完成跳转的vc
 */
@property (nonatomic,strong) UIViewController *nextVc;

@property (nonatomic,strong) WKWebView *webView;

@property (nonatomic,copy) void(^surveyFinishBlock)(id data);

@property (nonatomic,copy) void(^returnTitleBlock)(id data);

@property (nonatomic,strong) WebViewJavascriptBridge *bridge;
    
@property (nonatomic,assign) BOOL surveyFinishState;

- (void)loadWebViewPage;


@end
