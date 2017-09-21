//
//  HUDHelper.m
//  
//
//  Created by Alexi on 12-11-28.
//  Copyright (c) 2012年 . All rights reserved.
//

//导入AVFoundation是因为添加了一个获取视频截图的方法
#import <AVFoundation/AVFoundation.h>
//--------------------------------------

#import "HUDHelper.h"


#define RootVC  [[UIApplication sharedApplication] keyWindow].rootViewController
#define CommonRelease(__v)

//添加
@interface HUDHelper ()
{
    MBProgressHUD *HUD;
}

@property (nonatomic, copy) AlertViewBlock block;
@property (copy) MBProgressHUDCompletionBlock completionBlock;

@end


@implementation HUDHelper

static HUDHelper *_instance = nil;





+ (HUDHelper *)sharedInstance
{
    @synchronized(_instance)
    {
        if (_instance == nil)
        {
            _instance = [[HUDHelper alloc] init];
        }
        return _instance;
    }
}



- (MBProgressHUD *)loading
{
    return [self loading:nil];
}

- (MBProgressHUD *)loading:(NSString *)msg
{
    return [self loading:msg inView:nil];
}

- (MBProgressHUD *)loading:(NSString *)msg inView:(UIView *)view
{
    UIView *inView = view ? view : [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:inView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (msg.length)
        {
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = msg;
        }
        [inView addSubview:hud];
        [hud show:YES];
        // 超时自动消失
         [hud hide:YES afterDelay:20.0];
    });
    return hud;
}

- (void)loading:(NSString *)msg delay:(CGFloat)seconds execute:(void (^)())exec completion:(void (^)())completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *inView = [UIApplication sharedApplication].keyWindow;
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:inView];
        if (msg.length)
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = msg;
        }
        
        [inView addSubview:hud];
        [hud show:YES];
        if (exec)
        {
            exec();
        }
        
        // 超时自动消失
        [hud hide:YES afterDelay:seconds];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion();
            }
        });
    });
}


- (void)stopLoading:(MBProgressHUD *)hud
{
    [self stopLoading:hud message:nil];
}

- (void)stopLoading:(MBProgressHUD *)hud message:(NSString *)msg
{
    [self stopLoading:hud message:msg delay:0 completion:nil];
}
- (void)stopLoading:(MBProgressHUD *)hud message:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)())completion
{
    if (hud && hud.superview)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (msg.length)
            {
                hud.labelText = msg;
                hud.mode = MBProgressHUDModeText;
            }
            
            [hud hide:YES afterDelay:seconds];
            _syncHUD = nil;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (completion)
                {
                    completion();
                }
            });
        });
    }
    
}


- (void)tipMessage:(NSString *)msg
{
    [self tipMessage:msg delay:2];
}

- (void)tipMessage:(NSString *)msg delay:(CGFloat)seconds
{
    [self tipMessage:msg delay:seconds completion:nil];
    
}

- (void)tipMessage:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)())completion
{
    if (!msg.length)
    {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
        [[UIApplication sharedApplication].keyWindow addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = msg;
        [hud show:YES];
        [hud hide:YES afterDelay:seconds];
        CommonRelease(HUD);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion();
            }
        });
    });
}

- (void)tipMessageSmall:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)())completion
{
    if (!msg.length)
    {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
        [[UIApplication sharedApplication].keyWindow addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = msg;
        [hud show:YES];
        [hud hide:YES afterDelay:seconds];
        CommonRelease(HUD);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion();
            }
        });
    });
}


#define kSyncHUDStartTag  100000

// 网络请求
- (void)syncLoading
{
    [self syncLoading:nil];
}
- (void)syncLoading:(NSString *)msg
{
    [self syncLoading:msg inView:nil];
}
- (void)syncLoading:(NSString *)msg inView:(UIView *)view
{
    if (_syncHUD)
    {
        _syncHUD.tag++;
        
        if (msg.length)
        {
            _syncHUD.labelText = msg;
            _syncHUD.mode = MBProgressHUDModeText;
        }
        else
        {
            _syncHUD.labelText = nil;
            _syncHUD.mode = MBProgressHUDModeIndeterminate;
        }
        
        return;
    }
    _syncHUD = [self loading:msg inView:view];
    _syncHUD.tag = kSyncHUDStartTag;
}

- (void)syncStopLoading
{
    [self syncStopLoadingMessage:nil delay:0 completion:nil];
}
- (void)syncStopLoadingMessage:(NSString *)msg
{
    [self syncStopLoadingMessage:msg delay:1 completion:nil];
}
- (void)syncStopLoadingMessage:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)())completion
{
    _syncHUD.tag--;
    if (_syncHUD.tag > kSyncHUDStartTag)
    {
        if (msg.length)
        {
            _syncHUD.labelText = msg;
            _syncHUD.mode = MBProgressHUDModeText;
        }
        else
        {
            _syncHUD.labelText = nil;
            _syncHUD.mode = MBProgressHUDModeIndeterminate;
        }

    }
    else
    {
        [self stopLoading:_syncHUD message:msg delay:seconds completion:completion];
    }
}


#pragma mark - 家校同方法
-(UIWindow *) getCurrentKeyWindow
{
    return [UIApplication sharedApplication].keyWindow;
}

-(void) showDialog :(NSString *)text time:(int) time
{
    if (HUD){
        [HUD removeFromSuperview];
        HUD = nil;
    }
    
    HUD = [[MBProgressHUD alloc] initWithView:[self getCurrentKeyWindow]];
    [[self getCurrentKeyWindow] addSubview:HUD];
    HUD.labelText = text;
    HUD.mode = MBProgressHUDModeText;
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(time);
    } completionBlock:^{
        [HUD removeFromSuperview];
        HUD = nil;
    }];
}
-(void) showDialog :(NSString *)text time:(int) time completionBlock:(void (^)())completion
{
    if (HUD){
        [HUD removeFromSuperview];
        HUD = nil;
    }
    if (completion) {
        self.completionBlock = completion;
    }
    
    HUD = [[MBProgressHUD alloc] initWithView:[self getCurrentKeyWindow]];
    [[self getCurrentKeyWindow] addSubview:HUD];
    HUD.labelText = text;
    HUD.mode = MBProgressHUDModeText;
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(time);
    } completionBlock:^{
        [HUD removeFromSuperview];
        HUD = nil;
        if (self.completionBlock) {
            self.completionBlock();
            self.completionBlock = NULL;
        }
    }];
}


/**
 *  拨打电话
 *
 *  @param phoneNum 号码
 */
-(void) makeCallTo :(NSString *)phoneNum
{
    static UIWebView *phoneCallWebView = nil;
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNum]];
    
    if ( !phoneCallWebView ) {
        
        phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];// 这个webView只是一个后台的UIWebView 不需要add到页面上来  效果跟方法二一样 但是这个方法是合法的
    }
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    
}



#pragma mark - 对外方法

/**
 *  创建提示框
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param titleArray   标题字符串数组(为nil,默认为"确定")
 *  @param vc           VC
 *  @param confirm      点击确认按钮的回调
 */
- (void)showAlert:(NSString *)title
          message:(NSString *)message
      cancelTitle:(NSString *)cancelTitle
       titleArray:(NSArray *)titleArray
   viewController:(UIViewController *)vc
          confirm:(AlertViewBlock)confirm {
    //
    if (!vc) vc = RootVC;
    
    [self p_showAlertController:title message:message
                    cancelTitle:cancelTitle titleArray:titleArray
                 viewController:vc confirm:^(NSInteger buttonTag) {
                     if (confirm)confirm(buttonTag);
                 }];
}


/**
 *  创建提示框(可变参数版)
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param vc           VC
 *  @param confirm      点击按钮的回调
 *  @param buttonTitles 按钮(为nil,默认为"确定",传参数时必须以nil结尾，否则会崩溃)
 */
- (void)showAlert:(NSString *)title
          message:(NSString *)message
      cancelTitle:(NSString *)cancelTitle
   viewController:(UIViewController *)vc
          confirm:(AlertViewBlock)confirm
     buttonTitles:(NSString *)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    
    // 读取可变参数里面的titles数组
    NSMutableArray *titleArray = [[NSMutableArray alloc] initWithCapacity:0];
    va_list list;
    if(buttonTitles) {
        //1.取得第一个参数的值(即是buttonTitles)
        [titleArray addObject:buttonTitles];
        //2.从第2个参数开始，依此取得所有参数的值
        NSString *otherTitle;
        va_start(list, buttonTitles);
        while ((otherTitle = va_arg(list, NSString*))) {
            [titleArray addObject:otherTitle];
        }
        va_end(list);
    }
    
    if (!vc) vc = RootVC;
    
    [self p_showAlertController:title message:message
                    cancelTitle:cancelTitle titleArray:titleArray
                 viewController:vc confirm:^(NSInteger buttonTag) {
                     if (confirm)confirm(buttonTag);
                 }];
    
}


/**
 *  创建菜单(Sheet)
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param titleArray   标题字符串数组(为nil,默认为"确定")
 *  @param vc           VC
 *  @param confirm      点击确认按钮的回调
 */
- (void)showSheet:(NSString *)title
          message:(NSString *)message
      cancelTitle:(NSString *)cancelTitle
       titleArray:(NSArray *)titleArray
   viewController:(UIViewController *)vc
          confirm:(AlertViewBlock)confirm {
    
    if (!vc) vc = RootVC;
    
    [self p_showSheetAlertController:title message:message cancelTitle:cancelTitle
                          titleArray:titleArray viewController:vc confirm:^(NSInteger buttonTag) {
                              if (confirm)confirm(buttonTag);
                          }];
}

/**
 *  创建菜单(Sheet 可变参数版)
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param vc           VC iOS8及其以后会用到
 *  @param confirm      点击按钮的回调
 *  @param buttonTitles 按钮(为nil,默认为"确定",传参数时必须以nil结尾，否则会崩溃)
 */
- (void)showSheet:(NSString *)title
          message:(NSString *)message
      cancelTitle:(NSString *)cancelTitle
   viewController:(UIViewController *)vc
          confirm:(AlertViewBlock)confirm
     buttonTitles:(NSString *)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    // 读取可变参数里面的titles数组
    NSMutableArray *titleArray = [[NSMutableArray alloc] initWithCapacity:0];
    va_list list;
    if(buttonTitles) {
        //1.取得第一个参数的值(即是buttonTitles)
        [titleArray addObject:buttonTitles];
        //2.从第2个参数开始，依此取得所有参数的值
        NSString *otherTitle;
        va_start(list, buttonTitles);
        while ((otherTitle= va_arg(list, NSString*))) {
            [titleArray addObject:otherTitle];
        }
        va_end(list);
    }
    
    if (!vc) vc = RootVC;
    
    // 显示菜单提示框
    [self p_showSheetAlertController:title message:message cancelTitle:cancelTitle
                          titleArray:titleArray viewController:vc confirm:^(NSInteger buttonTag) {
                              if (confirm)confirm(buttonTag);
                          }];
    
}


#pragma mark - ----------------内部方法------------------

//UIAlertController(iOS8及其以后)
- (void)p_showAlertController:(NSString *)title
                      message:(NSString *)message
                  cancelTitle:(NSString *)cancelTitle
                   titleArray:(NSArray *)titleArray
               viewController:(UIViewController *)vc
                      confirm:(AlertViewBlock)confirm {
    
    UIAlertController  *alert = [UIAlertController alertControllerWithTitle:title
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    // 下面两行代码 是修改 title颜色和字体的代码
//        NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f], NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
//        [alert setValue:attributedMessage forKey:@"attributedTitle"];
    
    if (cancelTitle) {
        // 取消
        UIAlertAction  *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  if (confirm)confirm(cancelIndex);
                                                              }];
        [alert addAction:cancelAction];
    }
    // 确定操作
    if (!titleArray || titleArray.count == 0) {
        UIAlertAction  *confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
                                                                   if (confirm)confirm(0);
                                                               }];
        
        [alert addAction:confirmAction];
    } else {
        
        for (NSInteger i = 0; i<titleArray.count; i++) {
            UIAlertAction  *action = [UIAlertAction actionWithTitle:titleArray[i]
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                if (confirm)confirm(i);
                                                            }];
            // [action setValue:UIColorFrom16RGB(0x00AE08) forKey:@"titleTextColor"]; // 此代码 可以修改按钮颜色
            [alert addAction:action];
        }
    }
    
    [vc presentViewController:alert animated:YES completion:nil];
    
}


// ActionSheet的封装
- (void)p_showSheetAlertController:(NSString *)title
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        titleArray:(NSArray *)titleArray
                    viewController:(UIViewController *)vc
                           confirm:(AlertViewBlock)confirm {
    
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    if (!cancelTitle) cancelTitle = @"取消";
    // 取消
    UIAlertAction  *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              if (confirm)confirm(cancelIndex);
                                                          }];
    [sheet addAction:cancelAction];
    
    if (titleArray.count > 0) {
        for (NSInteger i = 0; i<titleArray.count; i++) {
            UIAlertAction  *action = [UIAlertAction actionWithTitle:titleArray[i]
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                if (confirm)confirm(i);
                                                            }];
            [sheet addAction:action];
        }
    }
    
    [vc presentViewController:sheet animated:YES completion:nil];
}



//自定义

- (void)showError:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)())completion
{
    if (!msg.length)
    {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
        [[UIApplication sharedApplication].keyWindow addSubview:hud];
        
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"MBProgressHUD.bundle/mv_error"]];
        hud.labelText = msg;
        hud.labelFont = [UIFont systemFontOfSize:14.0];
        [hud show:YES];
        [hud hide:YES afterDelay:seconds];
        CommonRelease(HUD);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion();
            }
        });
    });
    
}

- (void)showSuccess:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)())completion
{
    if (!msg.length)
    {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
        [[UIApplication sharedApplication].keyWindow addSubview:hud];
        
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"MBProgressHUD.bundle/mv_yes"]];
        hud.labelText = msg;
        hud.labelFont = [UIFont systemFontOfSize:14.0];
        [hud show:YES];
        [hud hide:YES afterDelay:seconds];
        CommonRelease(HUD);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion();
            }
        });
    });
}
#pragma mark 显示信息
- (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:1.2];
}

#pragma mark 显示错误信息
- (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

- (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

#pragma mark 显示一些信息
- (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
    return hud;
}

- (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

- (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

- (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
}

- (void)hideHUDForView:(UIView *)view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
}

- (void)hideHUD
{
    [self hideHUDForView:nil];
}





//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    NSLog(@"topViewControllerresult====%@",result);
    return result;
}

#pragma mark - 添加个人方法
- (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:nil];
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : [UIImage imageNamed:@"icon_video_default"];
    
    return thumbnailImage;
}


//倒序输出一个数组啊啊啊啊😡
- (NSMutableArray *)reverseMutableArray:(NSMutableArray *)array
{
    return (NSMutableArray *)[[array reverseObjectEnumerator] allObjects];
}


//当前APP是否允许推动送
- (BOOL)isAllowedNotification
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {// system is iOS8 +
            UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
            if
                (UIUserNotificationTypeNone != setting.types) {
                    return YES;
                }
        }
    else
    {// iOS7
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        
        if(UIRemoteNotificationTypeNone != type)
            return YES;
    }
    return NO;
}

//字典转Json字符串
- (NSString*)convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}

//JSON字符串转化为字典
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


//调用开灯关灯
- (void)turnTorchOn:(BOOL)on
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                on = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                on = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

@end
