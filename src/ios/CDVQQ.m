#include <sys/types.h>
#include <sys/sysctl.h>

#import <Cordova/CDV.h>
#import <Cordova/CDVViewController.h>
#import <TencentOpenAPI/QQApiInterface.h>


#import "CDVQQ.h"

@implementation CDVQQ {
    TencentOAuth* _oauth;
    NSString* _currentCallbackId;
    NSString* _appId;
}

#pragma mark "Public"

- (void)registerApp:(NSString*)appId {
    _appId = [NSString stringWithString:appId];
    
    _oauth = [[TencentOAuth alloc] initWithAppId:_appId andDelegate:self];
}

- (void)login:(CDVInvokedUrlCommand*)command {
    NSArray* permissions = [NSArray arrayWithObjects:
                     kOPEN_PERMISSION_GET_USER_INFO,
                     kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                     kOPEN_PERMISSION_ADD_SHARE,
                      nil];
	

    [_oauth authorize:permissions inSafari:NO];

    _currentCallbackId = [NSString stringWithString:command.callbackId];
}

- (void)logout:(CDVInvokedUrlCommand*)command {
    [_oauth logout:self];
    
    _currentCallbackId = [NSString stringWithString:command.callbackId];
}

#pragma mark "TencentLoginDelegate"

/**
 * Called when the user successfully logged in.
 */
- (void)tencentDidLogin {
    NSString* token = _oauth.accessToken;
    if (token && [token length] != 0) {
        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:_oauth.openId, @"uid", token, @"token", nil];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        
       
        [self.commandDelegate sendPluginResult:result callbackId:_currentCallbackId];
    }
    else {
        // no access token
        [self handleFail:_currentCallbackId withLoginStatus:CDVLoginStatus_NO_ACCESS_TOKEN];
    }
    
    _currentCallbackId = nil;
}


/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)tencentDidNotLogin:(BOOL)cancelled {
	if (cancelled) {
        [self handleFail:_currentCallbackId withLoginStatus:CDVLoginStatus_USER_CANCELLED];
	}
	else {
        [self handleFail:_currentCallbackId withLoginStatus:CDVLoginStatus_LOGIN_ERROR];
	}

    _currentCallbackId = nil;
}

/**
 * Called when the notNewWork.
 */
-(void)tencentDidNotNetWork {
    [self handleFail:_currentCallbackId withLoginStatus:CDVLoginStatus_NO_NETWORK];
    
    _currentCallbackId = nil;
}

#pragma mark "TencentSessionDelegate"

/**
 * Called when the logout.
 */
-(void)tencentDidLogout {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    
    [self.commandDelegate sendPluginResult:result callbackId:_currentCallbackId];
    
    _currentCallbackId = nil;
}

#pragma mark "CDVPlugin Overrides"

- (void)handleOpenURL:(NSNotification*)notification {
    NSURL* url = [notification object];
    
    if ([url isKindOfClass:[NSURL class]] && [TencentOAuth CanHandleOpenURL:url]) {
        [TencentOAuth HandleOpenURL:url];
    }
}

#pragma mark "private"

- (void)handleFail:(NSString*)callbackID withLoginStatus:(int)loginStatus {
    NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:loginStatus], @"code", nil];
    
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:info];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

@end
