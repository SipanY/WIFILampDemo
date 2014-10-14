//
//  BaseSocket.h
//  
//
//  Created by Aniapp on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef _BASESOCKET_H_
#define _BASESOCKET_H_

#include <iostream>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/select.h>

#include <net/if.h>
#include <net/if_dl.h>

typedef timeval _timeval;

typedef enum UDPTYPE {
    utClient = 0,
    utServer = 1
} UDPType;


class BaseSocket
{
public:
    BaseSocket();
    virtual ~BaseSocket();
    
    virtual bool Connect(char *ipaddr, unsigned short port);
    virtual bool Bind(char *ipaddr, unsigned short port);
    virtual void Disconnect();
    
public:
    int mSocket;
    unsigned short mPort;
};

#endif
