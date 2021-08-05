//
//  ZBRouteManager.m
//  TCM_Product
//
//  Created by Zhang Bruce on 2021/8/4.
//  Copyright © 2021 ShellUni. All rights reserved.
//

#import "ZBRouteManager.h"

@interface ZBBaseRouteParamsObject()

@property (nonatomic, strong) UIViewController *destinationViewController;
@property (nonatomic, copy) ZBPageConfigHandler pageConfigHandler;

- (void)showWithResult:(void (^)(BOOL success, NSString *message))result;

@end

@implementation ZBBaseRouteParamsObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _hidesBottomBarWhenPushed = YES;
        _animated = YES;
    }
    return self;
}

- (void)showWithResult:(void (^)(BOOL, NSString *))result {

    //尝试修复
    [self fixFromViewController];
    
    if (!_fromViewController) {
        
        if (result) {
            result(NO, @"无法执行此功能，无效的来源页面");
        }else {
            NSLog(@"%s, 无法执行此功能，无效的来源页面", __FUNCTION__);
        }
        return;
    }
    
    if (_transitionStyle == ZBPageTransitionStyle_Push) {

        //Push
        _destinationViewController.hidesBottomBarWhenPushed = _hidesBottomBarWhenPushed;
        
        //获取导航控制器
        UINavigationController *navigationController = nil;
        
        if ([_fromViewController isKindOfClass:[UINavigationController class]]) {
            navigationController = (UINavigationController *)_fromViewController;
        }else{
            navigationController = _fromViewController.navigationController;
        }
        
        if (!navigationController) {
            
            if (result) {
                result(NO, @"无法执行此功能，Push方式下，未能获取到有效的UINavigationController");
            }else {
                NSLog(@"%s, 无法执行此功能，Push方式下，未能获取到有效的UINavigationController", __FUNCTION__);
            }
            
            return;
        }
        
        [navigationController pushViewController:_destinationViewController animated:_animated];
    }else{
        //Present
        UIViewController *viewController = _destinationViewController;
        
        if (![_destinationViewController isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:_destinationViewController];
            viewController = navc;
        }
        
        viewController.modalPresentationStyle = _modalPresentationStyle;
        [_fromViewController presentViewController:viewController animated:_animated completion:nil];
    }
    
    if (result) {
        result(YES, @"执行成功");
    }else {
        NSLog(@"%s, 执行成功", __FUNCTION__);
    }
}

- (void)fixFromViewController {

    if (_fromViewController) {

        return;
    }

    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;

    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        //UITabBarController
        UIViewController *selectedVC = [(UITabBarController *)rootViewController selectedViewController];

        if ([selectedVC isKindOfClass:[UINavigationController class]]) {

            if (_transitionStyle == ZBPageTransitionStyle_Push) {

                _fromViewController = selectedVC;
            }else {
                _fromViewController = [(UINavigationController *)selectedVC topViewController];
            }
        }
    }else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        //UINavigationController
        if (_transitionStyle == ZBPageTransitionStyle_Push) {

            _fromViewController = rootViewController;
        }else {
            _fromViewController = [(UINavigationController *)rootViewController topViewController];
        }
    }else {
        //UIViewController
        if (_transitionStyle == ZBPageTransitionStyle_Present) {

            _fromViewController = rootViewController;
        }
    }
}

@end

@interface ZBRouteManager()

@property (nonatomic, strong) NSMutableDictionary *infos;

@end

@implementation ZBRouteManager

+ (instancetype)sharedInstance {
    
    static ZBRouteManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [ZBRouteManager new];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _infos = [NSMutableDictionary new];
    }
    return self;
}

- (void)registerRouteWithIdentifier:(NSString *)identifier
                  pageConfigHandler:(ZBPageConfigHandler)pageConfigHandler{
    
    if (!identifier || !pageConfigHandler) {
        
        if (_errorHandler) {
            _errorHandler(@"无效的参数");
        }else {
            
            NSLog(@"%s 无效的参数", __FUNCTION__);
        }
        return;
    }
    
    //初始化
    ZBBaseRouteParamsObject *paramsObject = [ZBBaseRouteParamsObject new];
    
    //配置处理
    paramsObject.pageConfigHandler = pageConfigHandler;
    
    //保存
    [_infos setObject:paramsObject forKey:identifier];
}

- (void)executeRouteWithIndentifier:(NSString *)indentifier
                paramsConfigHandler:(ZBPageParamsConfigHandler)paramsConfigHandler{
    
    //获取
    ZBBaseRouteParamsObject *paramsObject = [_infos objectForKey:indentifier];
    
    if (!paramsObject) {
         
        if (_errorHandler) {
            _errorHandler(@"请先注册相关路由");
        }else {
            
            NSLog(@"%s 请先注册相关路由", __FUNCTION__);
        }
        
        return;
    }
    
    if (!paramsConfigHandler) {
         
        if (_errorHandler) {
            _errorHandler(@"请设置参数配置回调");
        }else {
            
            NSLog(@"%s 请设置参数配置回调", __FUNCTION__);
        }
        
        return;
    }
    
    //设置参数
    paramsConfigHandler(paramsObject);
    
    //调用回调，获取页面
    paramsObject.destinationViewController = paramsObject.pageConfigHandler(paramsObject);
    
    //展示
    __weak typeof(self) weakSelf = self;
    
    [paramsObject showWithResult:^(BOOL success, NSString *message) {
        
        if (!success) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (!strongSelf) {
                return;
            }
            
            if (strongSelf.errorHandler) {
                strongSelf.errorHandler(message);
            }else {
                
                NSLog(@"%s %@", __FUNCTION__, message);
            }
        }
    }];
}

@end
