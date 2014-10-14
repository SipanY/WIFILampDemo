//
//  LANCommunication.m
//  WiFiLamp
//
//  Created by Aniapp on 12-9-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LANTransmission.h"
#import "GlobalDefines.h"
#import "UDPSocket.h"
#import "TCPSocket.h"
#import "ZHClient.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "TBXML.h"

#define PROTOCOL_VERSION        1       //版本1.0
#define PROTOCOL_HEADER_SIZE    8       //包头大小
#define MAX_PACKET_SIZE         1024    //

@interface LANTransmission() <GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate>
{
    NSMutableData *_sendBuffer;
    NSMutableData *_recvBuffer;
    NSMutableData *_recvUDPBuffer;
    
    dispatch_semaphore_t _semBroadcast;
    NSLock *_processLock;
    
    GCDAsyncUdpSocket *_udpSocket;
    GCDAsyncSocket *_tcpSocket;
    
    BOOL _broadcasting;
    BOOL _isTCPConnected;
}

@property (nonatomic, copy) NSMutableArray *devicesList;

- (unsigned int)splitpPacket:(const unsigned char *)pData
                    DataSize:(unsigned int)dataSize;
- (void)parsePacket:(const unsigned char *)pData
           DataSize:(unsigned int)dataSize;
- (void)processSendTCPBuffer;
- (void)processRecvTCPBuffer:(NSData *)data;

@end

@implementation LANTransmission

@synthesize protocolVer = _protocolVer;
@synthesize protocolType = _protocolType;
@synthesize devicesList = _devicesList;
@synthesize delegate = _delegate;

void socketException(int signo)
{
    CLog(@"[socketException] ");
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _semBroadcast = 0;
        _protocolVer = PROTOCOL_VERSION;
        _protocolType = PROTOCOL_TYPE_LAMP;

        if (_sendBuffer == nil)
            _sendBuffer = [[NSMutableData alloc] init];
        if (_recvBuffer == nil)
            _recvBuffer = [[NSMutableData alloc] init];
        if (_recvUDPBuffer == nil)
            _recvUDPBuffer = [[NSMutableData alloc] init];
        
        if (_devicesList == nil)
            _devicesList = [[NSMutableArray alloc] init];
    }
    
    signal(SIGPIPE, socketException);
    
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    [self stopUDPBroadcast];
    [self stopTCPConnect];
    
    [_devicesList release];
    [_sendBuffer release];
    [_recvBuffer release];
    [_recvUDPBuffer release];
    CLog(@"[LANTransmission dealloc]");
    
    [super dealloc];
}

unsigned short checkSum(unsigned short *buffer, int size)
{
    unsigned long sum = 0;
    unsigned short *tmpBuffer = buffer;
    int tmpSize = size;
    
    while (tmpSize > 1)
    {
        /* 按16bit求和 */
        sum += *tmpBuffer++;
        tmpSize -= sizeof(unsigned short);
    }
    
    if (tmpSize > 0)
    {
        /* 处理奇数字节 */
        sum += *(unsigned char*)tmpBuffer;
    }
    
    /* 32位整数 取高16位和低16位进行求和 得到16位的检验和*/
    sum = (sum>>16) + (sum & 0xffff);
    sum += (sum>>16);
    return ~sum;
}

void makeHeader(unsigned char ver, unsigned char type, 
               unsigned char code, unsigned char *pData, 
               unsigned short dataSize)
{
    unsigned short sum = 0;
    if (pData && (dataSize > 0))
    {
        pData[0] = (type << 4) + ver;
        pData[1] = code;
        pData[4] = dataSize & 0x00ff;
        pData[5] = dataSize >> 8;
        
        sum = checkSum((unsigned short*)pData, dataSize);
        
        pData[6] = sum & 0x00ff;
        pData[7] = sum >> 8;
    }
}

- (void)parsePacket:(const unsigned char *)pData DataSize:(unsigned int)dataSize
{
    if (pData && (dataSize > 0))
    {
        if ([_delegate respondsToSelector:@selector(lanTransmission:recvData:)])
        {
            unsigned char code = *(pData+1);
            unsigned short totalSize = *(unsigned short*)(pData+4);
            NSData *data = [[NSData alloc] initWithBytes:pData + PROTOCOL_HEADER_SIZE
                                                  length:totalSize - PROTOCOL_HEADER_SIZE];
            NSNumber *number = [NSNumber numberWithUnsignedChar:code];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:data, number, nil];
            [data release];
            
            [_delegate lanTransmission:self recvData:dict];
        }
    }
}

- (unsigned int)splitpPacket:(const unsigned char *)pData DataSize:(unsigned int)dataSize
{
    if (pData && (dataSize > 0))
    {
        unsigned short totalSize = *(unsigned short*)(pData+4);
        if ((totalSize - PROTOCOL_HEADER_SIZE) >= 0) 
        {
            if (checkSum((unsigned short*)pData, totalSize) == 0)
                return totalSize;
        }
    }
    
    return 0;
}

- (void)processSendTCPBuffer
{
    if (_tcpSocket && [self isTCPConnected])
    {
        if ([_sendBuffer length] > 0)
        {
            NSData *data = [[[NSData alloc] initWithData:_sendBuffer] autorelease];
            [_tcpSocket writeData:data withTimeout:-1 tag:0]; //ARC需要重新构建数据对象
            [_sendBuffer setData:nil];
        }
    }
}

- (void)processRecvTCPBuffer:(NSData *)data
{
    [_processLock lock];
    
    [_recvBuffer appendData:data];
    
    do 
    {
        unsigned int bufferSize = [_recvBuffer length];
        unsigned char *pData = (unsigned char *)[_recvBuffer bytes];
        int packetSize = [self splitpPacket:pData DataSize:bufferSize];
        
        if (packetSize > 0)
        {
            [self parsePacket:pData DataSize:packetSize];
            
            unsigned int remainSize = bufferSize - packetSize;
            NSMutableData *tempBuffer = 
                [[NSMutableData alloc] initWithBytes:pData+packetSize length:remainSize];
            [_recvBuffer release];
            _recvBuffer = tempBuffer;
        }
        else
        {
            break;
        }
    } while (1);
    
    [_processLock unlock];
}

- (NSString *)broadcastAddress
{
    SOCKET mSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (mSocket > 0)
    {
        struct ifreq buff[16];
        struct ifconf conf;
        conf.ifc_len = sizeof(buff);
        conf.ifc_buf = (caddr_t)buff;
        
        if (ioctl(mSocket, SIOCGIFCONF, &conf) == 0)
        {
            int ifcount = conf.ifc_len / sizeof(struct ifreq);
            while (ifcount-- > 0)
            {
                if (ioctl(mSocket, SIOCGIFFLAGS, &buff[ifcount]) == 0)
                {
                    short flags = buff[ifcount].ifr_flags;
                    if (!(flags & IFF_UP) || !(flags & IFF_BROADCAST))
                        continue;
                }
                else
                {
                    continue;
                }
                
                if (ioctl(mSocket, SIOCGIFBRDADDR, &buff[ifcount]) == 0)
                {
                    char *ip = inet_ntoa(((struct sockaddr_in*)&buff[ifcount].ifr_broadaddr)->sin_addr);
                    printf("[broadcast address] is: %s \n", ip);
                    return [[[NSString alloc] initWithBytes:ip length:strlen(ip)
                                                  encoding:[NSString defaultCStringEncoding]] autorelease];
                }
            }
        }
    }
    
    return nil;
}

- (void)setupUDPSocket
{
    if (_udpSocket == nil)
    {
        dispatch_queue_t queue = dispatch_get_main_queue();
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:queue];
    }
    
    NSError *error = nil;
    if (![_udpSocket bindToPort:kUDPPort error:&error])
    {
        CLog(@"Error binding: %@", error);
        return;
    }
    
    if (![_udpSocket enableBroadcast:YES error:&error])
    {
        CLog(@"Error enable broadcast: %@", error);
        return;
    }
    
    if (![_udpSocket beginReceiving:&error])
    {
        CLog(@"Error receiving: %@", error);
        return;
    }
}

- (void)startUDPBroadcast
{
    if (!_broadcasting)
    {
        _broadcasting = YES;
        [_devicesList removeAllObjects];
        [self setupUDPSocket]; //创建并启用一个UDP广播
        
        NSString *host = [self broadcastAddress]; //广播地址
        void (^task)(void) = ^{
            while (_broadcasting)
            {
                unsigned char header[PROTOCOL_HEADER_SIZE] = {0};
                makeHeader(_protocolVer, _protocolType, kCode_Broadcast,
                           header, PROTOCOL_HEADER_SIZE);

                NSData *data = [NSData dataWithBytes:header length:sizeof(header)];
                [_udpSocket sendData:data toHost:host port:kUDPPort withTimeout:-1 tag:0];
                [NSThread sleepForTimeInterval:1];
            }

            dispatch_semaphore_signal(_semBroadcast);
        };

        _semBroadcast = dispatch_semaphore_create(0);
        dispatch_queue_t queue = dispatch_queue_create("Broadcast", NULL);
        dispatch_async(queue, task);
        dispatch_release(queue);
        
//#ifdef DEBUG
//        [self addDeviceToList:@{kXML_ATTR_NAME: @"LampE3EEC",
//                                kXML_ATTR_MAC: @"ccd29b1e3eec",
//                                kXML_ATTR_IP: @"10.0.1.12"}];
//#endif
    }
}

- (void)stopUDPBroadcast
{
    _broadcasting = NO;
    if (_semBroadcast > 0)
    {
        dispatch_semaphore_wait(_semBroadcast, DISPATCH_TIME_FOREVER);
        dispatch_release(_semBroadcast);
        _semBroadcast = 0;
    }
    
    if (_udpSocket)
    {
        [_udpSocket setDelegate:nil];
        [_udpSocket close];
        [_udpSocket release];
        _udpSocket = NULL;
    }
    
    [_recvUDPBuffer setData:nil];
}

- (BOOL)setupTCPSocket:(NSString *)host
{
    if (_tcpSocket == nil)
    {
        dispatch_queue_t queue = dispatch_get_main_queue();
        _tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
        _processLock = [[NSLock alloc] init];
    }
    
    NSError *error = nil;
    if (![_tcpSocket connectToHost:host onPort:kTCPPort withTimeout:5 error:&error])
    {
        CLog(@"Error binding: %@", error);
        return NO;
    }
    
    return YES;
}

- (void)startTCPConnect:(NSString *)ipaddress
{
    if (![self isTCPConnected])
    {
        if (![self setupTCPSocket:ipaddress]) //创建并启用一个TCP连接
        {
            [self stopTCPConnect];
        }
    }
}

- (void)stopTCPConnect
{
    _isTCPConnected = NO;

    if (_tcpSocket)
    {
        [_tcpSocket setDelegate:nil];
        [_tcpSocket disconnect];
        [_tcpSocket release];
        _tcpSocket = NULL;
    }
    
    [_sendBuffer setData:nil];
    [_recvBuffer setData:nil];
    [_processLock release];
    _processLock = nil;
}
//!!!
- (void)sendTCPData:(NSData *)data code:(int)code
{
    if (data == nil) return ;
    [_processLock lock];
    unsigned char header[PROTOCOL_HEADER_SIZE] = {0};
    int dataSize = [data length];
    int totalSize = PROTOCOL_HEADER_SIZE + dataSize;
    
    unsigned char *pData = new unsigned char[totalSize];
    if (pData)
    {
        memmove(pData, header, PROTOCOL_HEADER_SIZE);
        if (dataSize > 0)
        {
            memmove(pData + PROTOCOL_HEADER_SIZE, [data bytes], dataSize);
        }
        makeHeader(_protocolVer, _protocolType, code, pData, totalSize);
        [_sendBuffer appendBytes:pData length:totalSize];
        delete [] pData;
    }
    
    [self processSendTCPBuffer];
    [_processLock unlock];
}

- (BOOL)isTCPConnected
{
    return _isTCPConnected;//(_udpSocket && [_udpSocket isConnected]);
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag
       dueToError:(NSError *)error
{
    CLog(@"%@", error);
}

- (void)addDeviceToList:(NSDictionary *)deviceInfo
{
    if (deviceInfo)
    {
        for (NSDictionary *value in _devicesList)
        {
            if ([[value objectForKey:kXML_ATTR_MAC] isEqualToString:
                 [deviceInfo objectForKey:kXML_ATTR_MAC]])
                return ;
        }
        [_devicesList addObject:deviceInfo];
        CLog(@"%@", deviceInfo);
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSUInteger datalen = [data length] - PROTOCOL_HEADER_SIZE;
    if (datalen > 0)
    {
        NSRange range = NSMakeRange(PROTOCOL_HEADER_SIZE, datalen);
        NSData *xmlData = [data subdataWithRange:range];
        NSError *error = nil;
        
        TBXML *tbxml = [[TBXML alloc] initWithXMLData:xmlData error:&error];
        @try
        {
            if (tbxml && !error)
            {
                TBXMLElement *element = [TBXML childElementNamed:kXML_NODE_VALUE
                                                   parentElement:tbxml.rootXMLElement];
                if (element)
                {
                    NSString *info = [TBXML valueOfAttributeNamed:kXML_ATTR_CODE
                                                       forElement:element];
                   
                    NSArray *values = [info componentsSeparatedByString:@":"];
                   // NSString *s=    [values lastObject];
                    CLog(@"%@--->%@",info,values[0] );
                    if (([values count] >= 3) && ([values[2] integerValue] == 0)) //已经配置过了
                    {
                        NSString *host = nil;
                        [GCDAsyncUdpSocket getHost:&host port:NULL fromAddress:address];
                        [self addDeviceToList:@{kXML_ATTR_NAME: values[0],
                                                kXML_ATTR_MAC: values[1],
                                                kXML_ATTR_IP: host,
                                                @"ifused":values[2]}]; //添加到设备列表 LampE3EEC, ccd29b1e3eec
                    }
                }
            }
        }
        @finally
        {
            [tbxml release];
        }
    }
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    if (error)
    {
        CLog(@"%@", error);
        [self performSelectorOnMainThread:@selector(stopUDPBroadcast)
                               withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - GCDAsyncSocketDelegate

- (void)disconnectAndNotifaction
{
    [self stopTCPConnect];
    if ([_delegate respondsToSelector:@selector(lanTransmissionDisconnect:)])
        [_delegate lanTransmissionDisconnect:self];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    _isTCPConnected = YES;
    if ([_delegate respondsToSelector:@selector(lanTransmissionConnected:)])
        [_delegate lanTransmissionConnected:self];
    [sock performBlock:^{
        [sock enableBackgroundingOnSocket]; //后台运行
    }];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataWithTimeout:-1 tag:tag]; //创建接收数据通道，必须设置!!!
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if ([data length] > 0)
    {
        [self processRecvTCPBuffer:data];
    }
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
    CLog(@"stopProcessing");
    [self performSelectorOnMainThread:@selector(disconnectAndNotifaction)
                           withObject:nil waitUntilDone:NO];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err) //非主动关闭
    {
        CLog(@"%@", err);
        [self performSelectorOnMainThread:@selector(disconnectAndNotifaction)
                               withObject:nil waitUntilDone:NO];
    }
}

@end
