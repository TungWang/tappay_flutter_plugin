//
//  TPDSetup.h
//
//  TPDirect iOS SDK - v2.13.0
//  Copyright © 2016年 Cherri Tech, Inc. All rights reserved.
//
//  Apple Pay Document : https://docs.tappaysdk.com/apple-pay
//  TapPay Document    : https://docs.tappaysdk.com/tutorial

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TPDServerType) {
    TPDServer_SandBox,      // Sand-Box Mode
    TPDServer_Production,   // Production Mode

};

@interface TPDSetup : NSObject

@property (strong, nonatomic) NSString *_Nonnull appKey;      // Your App Authenticator
@property (assign, nonatomic) NSInteger appId;                // Your App Authenticator
@property (assign, nonatomic) TPDServerType serverType;       // Parameter For Switching Between Sand-Box And Production Mode.


#pragma mark - Initialize
/**
 This Class Method Will Set Up And Return A TPDSetup Instance For The Next Operation
 Make Sure You Set Up TPDSetup Instance When App Is On DidFinishLaunch
 Remember To Set Up TPDServerType At The Same Time

 @param appKey     NSString, Your App Authenticator
 @param appId      int, Your App Authenticator
 @param serverType TPDServerType, Parameter For Switching Between Sand-Box And Production Mode.

 @return TPDSetup Instance.
 */
+ (instancetype _Nonnull)setWithAppId:(int)appId
                           withAppKey:(NSString *_Nonnull)appKey
                       withServerType:(TPDServerType)serverType;


+ (instancetype _Nonnull)setWithAppId:(int)appId withAppKey:(NSString *_Nonnull)appKey withRBAAppId:(NSString * _Nullable)RBAAppId withRBAAppKey:(NSString * _Nullable)RBAAppKey withServerType:(TPDServerType)serverType;

#pragma mark - Function
/**
 @return TPDSetup Instance.
 */
+ (instancetype _Nonnull)shareInstance;


/* Return SDK Version */
/**
 @return NSString version // Now SDK Version.
 */
+ (NSString *_Nonnull)version;

- (NSString *_Nonnull)getDeviceId;

@end
