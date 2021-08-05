//
//  ZBRouteManager.h
//  TCM_Product
//
//  Created by Zhang Bruce on 2021/8/4.
//  Copyright © 2021 ShellUni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZBPageTransitionStyle) {
    ZBPageTransitionStyle_Push = 0,
    ZBPageTransitionStyle_Present
};

/// 路由参数基类，扩展时请继承此类
@interface ZBBaseRouteParamsObject : NSObject

/// 来源页面
@property (nonatomic, strong) UIViewController *fromViewController;

/// 切换方式（默认Push）
@property (nonatomic, assign) ZBPageTransitionStyle transitionStyle;

/// transitionStyle为Present时使用
@property (nonatomic, assign) UIModalPresentationStyle modalPresentationStyle;

//新界面push时，是否隐藏底部Bar（仅transitionStyle为Push时有效，默认YES）
@property (nonatomic, assign) BOOL hidesBottomBarWhenPushed;

//是否有过渡动画（默认YES）
@property (nonatomic, assign) BOOL animated;

@end

/// 页面配置回调
/// params为相关参数
typedef UIViewController * _Nullable (^ZBPageConfigHandler)(__kindof ZBBaseRouteParamsObject *params);

/// 参数配置回调
/// params为相关参数
typedef void (^ZBPageParamsConfigHandler)(__kindof ZBBaseRouteParamsObject *params);

/// 错误信息回调
typedef void(^ZBErrorHandler)(NSString *log);

/// 路由管理类
@interface ZBRouteManager : NSObject

@property (nonatomic, copy) ZBErrorHandler errorHandler;

+ (instancetype)sharedInstance;

/// 注册路由
/// @param identifier 路由唯一标识
/// @param pageConfigHandler 页面配置回调【通过参数对象，配置页面参数及相关逻辑】
- (void)registerRouteWithIdentifier:(NSString *)identifier
                  pageConfigHandler:(ZBPageConfigHandler)pageConfigHandler;

/// 执行路由
/// @param indentifier 路由唯一标识
/// @param paramsConfigHandler 参数配置回调【通过参数对象，设置需要的参数】
- (void)executeRouteWithIndentifier:(NSString *)indentifier
                paramsConfigHandler:(ZBPageParamsConfigHandler)paramsConfigHandler;

@end

NS_ASSUME_NONNULL_END
