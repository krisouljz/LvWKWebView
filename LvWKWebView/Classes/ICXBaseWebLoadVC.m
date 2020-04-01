//
//  ICXBaseWebLoadVC.m
//  ICXWebViewModule_Example
//
//  Created by TYFanrong on 2018/2/7.
//  Copyright © 2018年  吕佳珍. All rights reserved.
//

#import "ICXBaseWebLoadVC.h"
#import "MBProgressHUD.h"
#import "ICXAuthModule.h"
#import "ICXHTTPKit.h"
#import "ICXWebCookieManager.h"
#import "ICXNetworkMonitor.h"

#define ICXWindow [[[UIApplication sharedApplication] delegate] window]
#define SCREEN_WIDTH  ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
//系统默认的空间高度
#define ICXNaviHeight (((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && (MAX(SCREEN_WIDTH, SCREEN_HEIGHT)) == 812.0) ? 88 : 64)
#define isValidString(obj) (([obj isKindOfClass:[NSString class]])&&((NSString *)obj).length)

#define Web_Active_Color [UIColor colorWithRed:42/255.0 green:169/255.0 blue:247/255.0 alpha:1]



#define Request_WebCode_Path @"auth/web-code/request"
#define Request_WebCode_URL ICXAuthURLString(Request_WebCode_Path)



@interface ICXBaseWebLoadVC ()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic,strong) UIProgressView *progressView;//设置加载进度条

@property (nonatomic,strong) UIButton *netFailBtn;

@end

@implementation ICXBaseWebLoadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self initDataSource];
    
    
    [self loadWebViewPage];
}

- (void)setupUI {
    self.navigationItem.title = self.vctitle;
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.netFailBtn];
}

- (void)initDataSource {
    [self configJSBridge];
}


- (void)configJSBridge
{
    [WebViewJavascriptBridge enableLogging];
    //1.把WKWebView与bridge绑定
    if (!_bridge)
    {
        _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
        [_bridge setWebViewDelegate:self];
    }
    //2.注册OC与JS交互的方法
    [self registerNativeFunctions];
}


- (UIButton *)netFailBtn
{
    if (!_netFailBtn)
    {
        _netFailBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _netFailBtn.frame = CGRectMake((SCREEN_WIDTH - 80)/2, (SCREEN_HEIGHT - 50)/2, 80, 40);
        [_netFailBtn setTitle:@"重新加载" forState:UIControlStateNormal];
        [_netFailBtn setBackgroundColor:Web_Active_Color];
        [_netFailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_netFailBtn addTarget:self action:@selector(loadWebViewPage) forControlEvents:UIControlEventTouchUpInside];
        _netFailBtn.hidden = YES;
    }
    
    return _netFailBtn;
}


- (WKWebView *)webView
{
    if (!_webView)
    {
        
        WKWebViewConfiguration *config = [WKWebViewConfiguration new];
        //初始化偏好设置属性：preferences
        config.preferences = [WKPreferences new];
        //The minimum font size in points default is 0;
        config.preferences.minimumFontSize = 10;
        //是否支持JavaScript
        config.preferences.javaScriptEnabled = YES;
        //不通过用户交互，是否可以打开窗口
        config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        config.processPool = [ICXWebCookieManager sharedInstance].processPool;
        //        config.processPool = [[WKProcessPool alloc]init];
        
        NSString *cookieValue = [self getCookieSets];
        // 加cookie给h5识别，表明在ios端打开该地址
        WKUserContentController* userContentController = WKUserContentController.new;
        WKUserScript * cookieScript = [[WKUserScript alloc]
                                       initWithSource: cookieValue
                                       injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [userContentController addUserScript:cookieScript];
        config.userContentController = userContentController;
        
        
        NSMutableString *javascript = [NSMutableString string];
        [javascript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];//禁止长按
        [javascript appendString:@"document.documentElement.style.webkitUserSelect='none';"];//禁止选择
        WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        //创建webView
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, ICXNaviHeight, SCREEN_WIDTH, SCREEN_HEIGHT - ICXNaviHeight) configuration:config];
        if ([self isKindOfClass:NSClassFromString(@"DigitalLifeVC")])
        {
            _webView.scrollView.scrollEnabled = NO;
        }
        [_webView.configuration.userContentController addUserScript:noneSelectScript];
        
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        // 当前应用软件版本 ----- 比如：1.0.1
        WEAKSELF
        [_webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
            NSString *userAgent = result;
            NSString *newUserAgent = [userAgent stringByAppendingString:[NSString stringWithFormat:@"Icarbonx %@",ICX_UserAgent]];
            weakSelf.webView.customUserAgent = newUserAgent;
        }];
        [_webView addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(title))
                      options:0
                      context:nil];
        [_webView addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
                      options:0
                      context:nil];
        
    }
    NSDate *dateEnd = [NSDate date];
    NSLog(@"webView initial end = %@",dateEnd);
    return _webView;
}


- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    CFDataRef exceptions = SecTrustCopyExceptions (serverTrust);
    SecTrustSetExceptions (serverTrust, exceptions);
    CFRelease (exceptions);
    completionHandler (NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:serverTrust]);
}


- (UIProgressView *)progressView
{
    if (!_progressView)
    {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, ICXNaviHeight, SCREEN_WIDTH, 5 );
        [_progressView setTrackTintColor:[UIColor colorWithRed:240.0/255
                                                         green:240.0/255
                                                          blue:240.0/255
                                                         alpha:1.0]];
        _progressView.progressTintColor = Web_Active_Color;
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 2.0f);
        _progressView.transform = transform;//设定宽高
    }
    return _progressView;
}


// 类似 UIWebView的 -webView: shouldStartLoadWithRequest: navigationType:
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void(^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *strRequest = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    WKNavigationActionPolicy policy = WKNavigationActionPolicyAllow;
    if([[navigationAction.request.URL host] isEqualToString:@"itunes.apple.com"] &&
       [[UIApplication sharedApplication] openURL:navigationAction.request.URL]){
        policy =WKNavigationActionPolicyCancel;
    }
    decisionHandler(policy);
    NSLog(@"strRequest = %@",strRequest);
    NSString *baseUrl = @"https://meum.icarbonx.com/record/#/treatment-upload/save/";
    NSArray *prefixArr = @[@"prescription",@"medicalHistory",@"checkUp",@"inspection",@"cure",@"doctorAdvice",@"dischargeSummary"];
    
    if ([strRequest isEqualToString:@"https://meum.icarbonx.com/record/#/treatment"])
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 60, 40);
        [btn setTitle:@"附件资料" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(registerShowTreatmentNamesDialog) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:Web_Active_Color forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = item;
        
    }
    else if ([strRequest isEqualToString:@"https://meum.icarbonx.com/record/#/treatment-upload"])
    {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 60, 40);
        [btn setTitle:@"保存" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(registerAppSubmitUpload) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:Web_Active_Color forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = item;
        
    }
    else if ([prefixArr containsObject:[strRequest stringByReplacingOccurrencesOfString:baseUrl withString:@""]])
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 60, 40);
        [btn setTitle:@"保存" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(registerAppUploadDataSave) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:Web_Active_Color forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = item;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}






/**
 *  页面加载完成之后调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSDate *date = [NSDate date];
    NSLog(@"webView didFinishNavigation time = %@",date);
    
    
    
    // 禁用选中效果
    [_webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none'" completionHandler:nil];
    [_webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none'" completionHandler:nil];
    
    self.navigationItem.title = webView.title;
    
    if (self.returnTitleBlock) {
        self.returnTitleBlock(webView.title);
    }
    
    
    
}

/* 在JS端调用alert函数时，会触发此代理方法。JS端调用alert时所传的数据可以通过message拿到 在原生得到结果后，需要回调JS，是通过completionHandler回调 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    NSLog(@"%@", message);
    
}

// JS端调用confirm函数时，会触发此方法
// 通过message可以拿到JS端所传的数据
// 在iOS端显示原生alert得到YES/NO后
// 通过completionHandler回调给JS端
- (void)webView:(WKWebView *)webView
runJavaScriptConfirmPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"confirm" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                                                  completionHandler(YES);
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                      {
                          completionHandler(NO);
                      }]];
    [self presentViewController:alert animated:YES completion:NULL];
    NSLog(@"%@", message);
}
// JS端调用prompt函数时，会触发此方法
// 要求输入一段文本
// 在原生输入得到文本内容后，通过completionHandler回调给JS
- (void)webView:(WKWebView *)webView
runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(nullable NSString *)defaultText
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(NSString * __nullable result))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:prompt message:defaultText preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                  completionHandler([[alert.textFields lastObject] text]);
                                              }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}




- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        if (object == _webView) {
            [self.progressView setAlpha:1.0f];
            BOOL animated = _webView.estimatedProgress > self.progressView.progress;
            [self.progressView setProgress:_webView.estimatedProgress
                                  animated:animated];
            
            if (_webView.estimatedProgress >= 1.0f)
            {
                if (![self isKindOfClass:NSClassFromString(@"DigitalLifeVC")] && ![self isKindOfClass:NSClassFromString(@"FunnyTestVC")]  )
                {
                    self.navigationItem.title = _webView.title;
                    NSLog(@"title = %@",_webView.title);
                }
                
                [UIView animateWithDuration:0.3f
                                      delay:0.3f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [_progressView setAlpha:0.0f];
                                 }
                                 completion:^(BOOL finished) {
                                     [_progressView setProgress:0.0f animated:NO];
                                 }];
            }
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
        
    }
    else if ([keyPath isEqualToString:@"title"])
    {
        if (object == _webView)
        {
            if (![self isKindOfClass:NSClassFromString(@"HealthRecordVC")] && ![self isKindOfClass:NSClassFromString(@"FunnyTestVC")]  && _webView.estimatedProgress >= 1.0f)
            {
                self.navigationItem.title = _webView.title;
                NSLog(@"title = %@",_webView.title);
            }
            
            //            if(!_webView.title || _webView.title.length == 0) {
            //                NSLog(@"webView.title is nil");
            //
            //                [_webView reload];
            //            }
            
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else
    {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}






#pragma mark - private method
- (void)registerNativeFunctions
{
    [self registRequestWebCodeFunction];
    [self registGetPersonIDFunction];
    [self registBackActivityFunction];
    [self registStartLoadingActivityFunction];
    [self registFinishLoadingActivityFunction];
    [self regitstSetLoadingStateFunction];
    [self rigistFinishFucntion];
    [self registPushProductDetail];
    [self openLogin];
    [self popToRootVC];
}

//- (void)routerGo
//{
//    [_bridge registerHandler:@"routergo" handler:^(id data, WVJBResponseCallback responseCallback) {
//        if (!isValidString(data)) {
//            return;
//        }
//        NSString *url = data;
//        [TPRouter pushViewControllerWithRemoteURL:url animated:YES];
//  
//    }];
//}

- (void)popToRootVC
{
    WEAKSELF
    [_bridge registerHandler:@"backToMeum" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)openLogin
{
    WEAKSELF
    [_bridge registerHandler:@"jsAppLogin" handler:^(id data, WVJBResponseCallback responseCallback) {
        //现在与H5交互的方式是：在loadRequest的时候，将token传给H5，当token失效的时候，H5会回调这个方法，这个方法里面会去刷新token并且在refreshToken失效的时候跳转到登录页面，刷新成功以后会重新加载当前页面
        [ICXAuthManager refreshTokenWithBlock:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error, BOOL isValid) {
            if (isValid) {
                [weakSelf loadWebViewPage];
            }
        }];
        

    }];
}

- (void)registBackActivityFunction
{
    // 注册的handler是供JS调用Native使用的
    WEAKSELF
    [_bridge registerHandler:@"jsStartWebViewActivityWithBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        ICXBaseWebLoadVC *secondVc = [ICXBaseWebLoadVC new];
        if ([data isKindOfClass:[NSString class]]) {
            secondVc.loadUrl = (NSString *)data;
        }
        secondVc.personID = weakSelf.personID;
        [weakSelf.navigationController pushViewController:secondVc animated:YES];
    }];
}




- (void)registStartLoadingActivityFunction
{
    [_bridge registerHandler:@"jsStartLoadingActivity" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@"Show Loding");
    }];
}

- (void)registFinishLoadingActivityFunction
{
    [_bridge registerHandler:@"jsFinishLoadingActivity" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@"Hide Loading");
    }];
}

- (void)regitstSetLoadingStateFunction
{
    [_bridge registerHandler:@"jsSetLoadingState" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@"loadingState");
    }];
}

- (void)registRequestWebCodeFunction
{
    WEAKSELF
    [_bridge registerHandler:@"jsRequestWebCode" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf getWebCode:responseCallback];
    }];
}

- (void)registGetPersonIDFunction
{
    [_bridge registerHandler:@"jsGetCurrentPersonId" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@(self.personID));
    }];
}

-(void)rigistFinishFucntion
{
    WEAKSELF
    [_bridge registerHandler:@"finishSurvey" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        //        [[NSNotificationCenter defaultCenter] postNotificationName:TYH5CALLBACKDATANOTIFICATION object:nil userInfo:@{TYH5CALLBACKKEY:data}];
        [weakSelf finishSurvey:responseCallback withData:(id)data];
    }];
}

- (void)registPushProductDetail
{
    //WEAKSELF
    [_bridge registerHandler:@"jsGoProductDetail" handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isKindOfClass:[NSDictionary class]] )
        {
            //跳转到商详页面
            //            NSDictionary *dic = data;
            //            ShopChartVC *shopVC = [ShopChartVC new];
            //            shopVC.byBiGuWay = YES;
            //            shopVC.produceId = dic[@"productId"];
            //            shopVC.title = dic[@"title"];
            //            [weakSelf.navigationController pushViewController:shopVC animated:YES];
        }
        else
        {
        }
        
    }];
}




-(void)finishSurvey:(WVJBResponseCallback)responseCallback withData:(id)data{
    self.surveyFinishState = YES;
    if (self.surveyFinishBlock)
    {
        self.surveyFinishBlock(data);
    }
    NSLog(@"------------finishVc-------------");
    if (self.nextVc)
    {
        if ([self.navigationController.viewControllers containsObject:self.nextVc]) {
            [self.navigationController popToViewController:self.nextVc animated:YES];
        } else {
            [self.navigationController pushViewController:self.nextVc animated:YES];
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)getWebCode:(WVJBResponseCallback)responseCallback
{
    AFHTTPSessionManager *manager = [ICXHTTPKit httpKit].defaultManager;
    [manager.requestSerializer setValue:ICX_Authrization forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:ICX_UserAgent forHTTPHeaderField:@"User-Agent"];

    
    [MBProgressHUD showHUDAddedTo:ICXWindow animated:YES];
    
    [ICXHTTPKit requestByPostWithURLMethod:@"https://api.icarbonx.com/auth/web-code/request" params:nil success:^(id responseObject) {
        [MBProgressHUD hideHUDForView:ICXWindow animated:YES];
        NSString *webCode = responseObject[@"code"];
        NSLog(@"webCode = %@",webCode);
        responseCallback(webCode);
    } failed:^(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:ICXWindow animated:YES];
        responseCallback(@"error");
    }];
}


- (void)loadWebViewPage
{
    if (_loadUrl == nil || [_loadUrl isKindOfClass:[NSNull class]] || ![_loadUrl isKindOfClass:[NSString class]])   return;
    
    if (![ICXNetworkMonitor networkOn])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.netFailBtn.hidden = NO;
        });
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.netFailBtn.hidden = YES;
    });

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_loadUrl]];
    [request addValue:[self getCookieSets] forHTTPHeaderField:@"Cookie"];
    [request addValue:ICX_Authrization forHTTPHeaderField:@"Authorization"];
    [_webView loadRequest:request];
    
    
    NSLog(@"当前页面VC = %@", NSStringFromClass([self class]));
    NSLog(@"当前页面cookie缓存 = %@", [self getCookieSets]);
    NSLog(@"当前页面加载URL = %@", _loadUrl);
    
    
}

- (NSString *)getCookieSets
{
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    NSMutableString *cookieValue = [NSMutableString stringWithFormat:@""];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        [cookieDic setObject:cookie.value forKey:cookie.name];
    }
    
    /*
     Cookie重复,先放到字典里面进行去重,再进行拼接,拼接格式为:
     NSString *cookieValue = @"document.cookie = 'fromapp=ios';document.cookie = 'channel=appstore';";
     */
    
    for (NSString *key in cookieDic) {
        NSString *appendString = [NSString stringWithFormat:@"document.cookie = '%@=%@';", key, [cookieDic valueForKey:key]];
        [cookieValue appendString:appendString];
    }
    
    return cookieValue;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
