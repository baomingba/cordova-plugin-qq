#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import <TencentOpenAPI/TencentOAuth.h>

typedef enum {
    CDVLoginStatus_SUCCESS = 0,
    CDVLoginStatus_NO_ACCESS_TOKEN,
    CDVLoginStatus_USER_CANCELLED,
    CDVLoginStatus_LOGIN_ERROR,
    CDVLoginStatus_NO_NETWORK
} CDVLoginStatus;

@interface CDVQQ : CDVPlugin<TencentSessionDelegate, TencentLoginDelegate>

- (void)registerApp:(NSString*)appId;
- (void)login:(CDVInvokedUrlCommand*)command;
- (void)logout:(CDVInvokedUrlCommand*)command;

@end
