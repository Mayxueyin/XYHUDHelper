//
//  HUDHelper.h
//  
//
//  Created by Alexi on 12-11-28.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "MBProgressHUD.h"

//添加xy
#define cancelIndex    (-1)
typedef void(^AlertViewBlock)(NSInteger buttonTag);


@interface HUDHelper : NSObject
{
@private
    MBProgressHUD *_syncHUD;
}

+ (HUDHelper *)sharedInstance;


// 网络请求
- (MBProgressHUD *)loading;
- (MBProgressHUD *)loading:(NSString *)msg;
- (MBProgressHUD *)loading:(NSString *)msg inView:(UIView *)view;


- (void)loading:(NSString *)msg delay:(CGFloat)seconds execute:(void (^)())exec completion:(void (^)())completion;

- (void)stopLoading:(MBProgressHUD *)hud;
- (void)stopLoading:(MBProgressHUD *)hud message:(NSString *)msg;
- (void)stopLoading:(MBProgressHUD *)hud message:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)())completion;

- (void)tipMessage:(NSString *)msg;
- (void)tipMessage:(NSString *)msg delay:(CGFloat)seconds;
- (void)tipMessage:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)())completion;
- (void)tipMessageSmall:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)())completion;

// 网络请求
- (void)syncLoading;
- (void)syncLoading:(NSString *)msg;
- (void)syncLoading:(NSString *)msg inView:(UIView *)view;

- (void)syncStopLoading;
- (void)syncStopLoadingMessage:(NSString *)msg;
- (void)syncStopLoadingMessage:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)())completion;

//自定义
- (void)showSuccess:(NSString *)success toView:(UIView *)view;
- (void)showError:(NSString *)error toView:(UIView *)view;
- (void)showError:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)())completion;
- (void)showSuccess:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)())completion;
- (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;


- (void)showSuccess:(NSString *)success;
- (void)showError:(NSString *)error;

- (MBProgressHUD *)showMessage:(NSString *)message;

- (void)hideHUDForView:(UIView *)view;
- (void)hideHUD;

//家校通方法
-(void) showDialog :(NSString *)text time:(int) time;
-(void) showDialog :(NSString *)text time:(int) time completionBlock:(void (^)())completion;
-(void) makeCallTo :(NSString *)phoneNum;


//添加UIAlertController
/**
 *  创建提示框
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param titleArray   标题字符串数组(为nil,默认为"确定")
 *  @param vc           VC iOS8及其以后会用到
 *  @param confirm      点击按钮的回调(取消按钮的Index是cancelIndex -1)
 */
- (void)showAlert:(NSString *)title
          message:(NSString *)message
      cancelTitle:(NSString *)cancelTitle
       titleArray:(NSArray *)titleArray
   viewController:(UIViewController *)vc
          confirm:(AlertViewBlock)confirm;

/**
 *  创建提示框(可变参数版)
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param vc           VC iOS8及其以后会用到
 *  @param confirm      点击按钮的回调(取消按钮的Index是cancelIndex -1)
 *  @param buttonTitles 按钮(为nil,默认为"确定",传参数时必须以nil结尾，否则会崩溃)
 */
- (void)showAlert:(NSString *)title
          message:(NSString *)message
      cancelTitle:(NSString *)cancelTitle
   viewController:(UIViewController *)vc
          confirm:(AlertViewBlock)confirm
     buttonTitles:(NSString *)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  创建菜单(Sheet)
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param titleArray   标题字符串数组(为nil,默认为"确定")
 *  @param vc           VC iOS8及其以后会用到
 *  @param confirm      点击确认按钮的回调(取消按钮的Index是cancelIndex -1)
 */
- (void)showSheet:(NSString *)title
          message:(NSString *)message
      cancelTitle:(NSString *)cancelTitle
       titleArray:(NSArray *)titleArray
   viewController:(UIViewController *)vc
          confirm:(AlertViewBlock)confirm;

/**
 *  创建菜单(Sheet 可变参数版)
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param vc           VC
 *  @param confirm      点击按钮的回调(取消按钮的Index是cancelIndex -1)
 *  @param buttonTitles 按钮(为nil,默认为"确定",传参数时必须以nil结尾，否则会崩溃)
 */
- (void)showSheet:(NSString *)title
          message:(NSString *)message
      cancelTitle:(NSString *)cancelTitle
   viewController:(UIViewController *)vc
          confirm:(AlertViewBlock)confirm
     buttonTitles:(NSString *)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION ;


- (UIViewController *)getCurrentVC;



//添加个人方法
/**
 *  获取视频的一个截图
 *
 *  @param videoURL 视频URL
 *  @param time     获取视频截图时间
 *
 *  @return UIImage
 */
- (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

/**
 *  倒序数组
 *
 *  @param array 要倒序的数组
 *
 *  @return 返回一个倒序的数组
 */
- (NSMutableArray *)reverseMutableArray:(NSMutableArray *)array;

/**
 *  是否允许推送
 *
 *  @return BOOL
 */
- (BOOL)isAllowedNotification;

//字典转Json字符串
- (NSString*)convertToJSONData:(id)infoDict;
//JSON字符串转化为字典
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
//开灯关灯
- (void)turnTorchOn:(BOOL)on;
@end
