//
//  LANTrans.h
//  WiFiLamp
//
//  Created by Aniapp on 12-9-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PROTOCOL_TYPE_LAMP    4       //协议类型 - 台灯

@class LANTransmission;

@protocol LANTransmissionDelegate <NSObject>

@optional

- (void)lanTransmissionConnected:(LANTransmission *)lanTransmission;
- (void)lanTransmissionDisconnect:(LANTransmission *)lanTransmission;
- (void)lanTransmission:(LANTransmission *)lanTransmission
               recvData:(NSDictionary *)dict;

@end

@interface LANTransmission : NSObject
{
    NSInteger _protocolVer;
    NSInteger _protocolType;
    id <LANTransmissionDelegate> _delegate;
}

@property (nonatomic, assign) NSInteger protocolVer;
@property (nonatomic, assign) NSInteger protocolType;
@property (nonatomic, assign) id delegate;
@property (nonatomic, copy, readonly) NSMutableArray *devicesList; ///< UDP广播获取的设备列表

/**
 *	@brief 	UDP广播
 */
- (void)startUDPBroadcast;

/**
 *	@brief 	停止广播
 */
- (void)stopUDPBroadcast;

/****************** TCP ********************/

/**
 *	@brief 	TCP连接
 *
 *	@param 	ipaddress 	ip地址
 */
- (void)startTCPConnect:(NSString *)ipaddress;

/**
 *	@brief 	断开TCP连接
 */
- (void)stopTCPConnect;

/**
 *	@brief 	发送数据
 *
 *	@param 	data 	数据
 *	@param 	code 	代码指令
 */
- (void)sendTCPData:(NSData *)data code:(int)code;

/**
 *	@brief 	是否建立连接
 *
 *	@return	YES/NO
 */
- (BOOL)isTCPConnected;

@end
