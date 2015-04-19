# cordova-plugin-qq

A Cordova plugin for QQ Open SDK.

## 1. Features

1. 支持QQ开放平台授权登录，以及退出；
2. TODO。

## 2. 插件使用

### IOS/Android添加插件

1. 添加插件

        cordova plugin add https://github.com/baomingba/cordova-plugin-qq

2. 在`config.xml`中添加`preference` `QQAppId`。`QQAppId`是QQ开发平台创建的应用的app id。注意iOS和Android平台都要申请开通，虽然id相同。

        <preference name="QQAppId" value="1234567890" />

3. 编译iOS/Android平台程序

        cordova build ios
        cordova build android
        
4. 对于**IOS平台**，需要额外修改生成的`Resouces/*-Info.plist`文件中的`CFBundleURLTypes`属性:

    `tencent`对应的`CFBundleURLSchemes`从默认的`TENCENT_YOUR_QQ_APP_ID`改为`tencent+appid`。比如app id为`1234567890`，则该属性值为`tencent1234567890`。
    
    `mqqapi`对应的`CFBundleURLSchemes`从默认的`QQ_YOUR_QQ_APP_ID`改为`qq+appid的16进制数`，16进制数不足8位加0补齐。比如app id为`1234567890`，对应16进制为`0x499602d2`，则该属性值为`qq499602d2`；app id为`222222`，对应16进制为0x3640e，则该属性值为`qq0003640e`。`mqqapi`主要用于兼容某些老版本QQ，对于新版本QQ则无用处。

### 移除插件

        cordova plugin remove com.qiudao.cordova.qq


## 3. JS使用说明

### QQ授权登录

    window.QQ.login(function (response) {
        alert(JSON.stringify(response));
    }, function (reason) {
        alert('Failed: ' + JSON.stringify(reason));
    });
    
