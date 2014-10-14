//
//  GlobalDefines.h
//  WiFiLamp
//
//  Created by Aniapp on 12-9-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef WiFiLamp_GlobalDefines_h
#define WiFiLamp_GlobalDefines_h

#define kConfiguredLamp @"ConfiguredLamp"

static NSInteger const kUDPPort                 = 12712;
static NSInteger const kTCPPort                 = 12711;

static NSInteger const kCode_Broadcast          = 80;
static NSInteger const kCode_KeepAlive          = 31;

static NSInteger const kCode_SetSyncTime        = 32;
static NSInteger const kCode_GetLampName        = 60;
static NSInteger const kCode_SetLampName        = 61;
static NSInteger const kCode_GetBrightness      = 62;
static NSInteger const kCode_SetBrightness      = 63;
static NSInteger const kCode_GetLampTimer       = 64;
static NSInteger const kCode_SetLampTimer       = 65;

static NSInteger const kCode_GetExtenderAuth    = 21;
static NSInteger const kCode_GetExtenderTimer   = 22;
static NSInteger const kCode_SetExtenderTimer   = 23;

static NSInteger const kCode_GetMacAddress      = 40;
static NSInteger const kCode_GetExtenderState   = 41;

static NSInteger const kCode_GetVersion         = 50;   ///< 获取灯的软件版本号
static NSInteger const kCode_Update             = 51;   ///< 升级指令
static NSInteger const kCode_UpdateStatus       = 52;   ///< 升级状态指令

static NSInteger const kCode_ReqSucceed         = 100;
static NSInteger const kCode_ReqFailed          = 101;
static NSInteger const kCode_EmptyList          = 103;

#define kCODE_REQ_FAILED        @"101"
#define kCODE_REQ_SEC           @"100"
#define kXML_NODE_ITEMS         @"items"
#define kXML_NODE_ITEM          @"item"
#define kXML_NODE_VALUE         @"value"
#define kXML_NODE_DAY           @"day"
#define kXML_NODE_LED           @"led"
#define kXML_NODE_TIMER         @"timer"
#define kXML_NODE_WLAN          @"wlan"
#define kXML_NODE_WIFI          @"wifi"

#define kXML_ATTR_ID            @"id"
#define kXML_ATTR_STATE         @"state"
#define kXML_ATTR_TIMER         @"timer"
#define kXML_ATTR_STIME         @"stime"
#define kXML_ATTR_ETIME         @"etime"
#define kXML_ATTR_CODE          @"code"
#define kXML_ATTR_NAME          @"name"
#define kXML_ATTR_TRIGGER       @"trigger"
#define kXML_ATTR_RULE          @"rule"
#define kXML_ATTR_MAC           @"mac"
#define kXML_ATTR_IP            @"ip"
#define kXML_ATTR_BRIGHTNESS    @"brightness"
#define kXML_ATTR_REPEAT        @"repeat"
#define kXML_ATTR_VERSION       @"version"
#define kXML_ATTR_RSSI          @"rssi"
#define kXML_ATTR_SSID          @"ssid"
#define kXML_LAMP_PASSWORD      @"lamppassword"
#define kXML_ATTR_LEDSTIME      @"ledstime"
#define kXML_ATTR_LEDETIME      @"ledetime"
#define kXML_ATTR_WLANSTIME     @"wlanstime"
#define kXML_ATTR_WLANETIME     @"wlanetime"

#endif
