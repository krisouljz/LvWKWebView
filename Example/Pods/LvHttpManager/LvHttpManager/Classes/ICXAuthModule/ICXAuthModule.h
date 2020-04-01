//
//  ICXAuthManager.h
//  LvHttpManager
//
//  Created by 吕佳珍 on 2020/3/31.
//
#import "ICXAuthManager.h"



#ifndef ICXAuthModule_h
#define ICXAuthModule_h


#define ICX_Token_Save_Path @"icx_token_save_path"

#define Meum_Auth_Domin (@"api.icarbonx.com")

#define Meum_Report_Domin (@"report.icarbonx.com")

#define Meum_Main_Domin (@"mainapi.icarbonx.com")

#define Meum_Sample_Main_Domin (@"main.icarbonx.com")

#define Meum_AI_Domin (@"bxai.icarbonx.com")

#define Meum_Dap_Domin (@"dap-api.icarbonx.com")

#define Meum_Exam_Domin (@"exam.icarbonx.com")

#define Meum_EIM_Domin (@"eim.icarbonx.com")

#define Meum_Meun_Domin (@"meum.icarbonx.com")

#define Meum_Auth_Domin_Test (@"118.89.54.64")

#define TEST_ENVIRONMENT [[NSUserDefaults standardUserDefaults] boolForKey:@"TestMeum"]

#define Test_Address(methods) [NSString stringWithFormat:@"https://%@/%@",Meum_Auth_Domin_Test,methods]

#define ICXAuthURLString(methods) (TEST_ENVIRONMENT ? Test_Address(methods) : [NSString stringWithFormat:@"https://%@/%@",Meum_Auth_Domin,methods])

#define ICXReportURLString(methods)  (TEST_ENVIRONMENT ? Test_Address(methods) : [NSString stringWithFormat:@"https://%@/%@",Meum_Report_Domin,methods])

#define ICXURLString(methods)  (TEST_ENVIRONMENT ? Test_Address(methods) : [NSString stringWithFormat:@"https://%@/%@",Meum_Main_Domin,methods])

#define ICXSampleUrlString(methods)  (TEST_ENVIRONMENT ? Test_Address(methods) : [NSString stringWithFormat:@"https://%@/%@",Meum_Sample_Main_Domin,methods])

#define ICXAIUrlString(methods )  (TEST_ENVIRONMENT ? Test_Address(methods): [NSString stringWithFormat:@"https://%@/%@",Meum_AI_Domin,methods])

#define ICXDAPUrlString(methods)  (TEST_ENVIRONMENT ? Test_Address(methods) : [NSString stringWithFormat:@"https://%@/%@",Meum_Dap_Domin,methods])

#define ICXExamUrlString(methods)  (TEST_ENVIRONMENT ? Test_Address(methods): [NSString stringWithFormat:@"https://%@/%@",Meum_Exam_Domin,methods])

#define ICXMeumUrlString(methods)  (TEST_ENVIRONMENT ? Test_Address(methods) : [NSString stringWithFormat:@"https://%@/%@",Meum_Meun_Domin,methods])

//未登录前的Basic_Authrization字符串，是由AppID和AppSecret通过Base64编码得到的
#define ICX_Basic_Authorization [ICXAuthManager getBasicAuthorization]


//登录后的Authorization字符串
#define ICX_Authrization [NSString stringWithFormat:@"Bearer %@",[ICXAuthManager getToken]]


//User-Agent字符串
#define ICX_UserAgent [ICXAuthManager getUserAgent]


//合并了Basic_Authrization请求头和User-Agent请求头，可以直接作为网络请求的请求头，用于未登录的授权
#define ICX_Basic_HTTPHeaderField_Headers @{@"Authorization":ICX_Basic_Authorization,@"User-Agent":ICX_UserAgent}


//合并了Authorization请求头和User-Agent请求头，可以直接作为网络请求的请求头，用于登录后的授权
#define ICX_General_HTTPHeaderField_Headers @{@"Authorization":ICX_Authrization,@"User-Agent":ICX_UserAgent}













/*
 
 //User-Agent请求头
 #define ICX_UserAgent_Headers @{@"User-Agent":ICX_UserAgent}
 
 
 //未登录前的Basic_Authrization请求头
 #define ICX_Basic_Authorization_Headers @{@"Authorization":ICX_Basic_Authorization}
 
 
 //登录后的Authorization请求头
 #define ICX_Authrization_Headers @{@"Authorization":ICX_Authrization}

 */


#endif /* ICXAuthModule_h */
