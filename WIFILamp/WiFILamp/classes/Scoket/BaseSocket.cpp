//
//  BaseSocket.m
//  
//
//  Created by Aniapp on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#include "BaseSocket.h"
#include <stdio.h>

BaseSocket::BaseSocket():mSocket(-1), mPort(-1)
{
//    printf("BaseSocket::BaseSocket() \n");
}

bool BaseSocket::Connect(char *ipaddr, unsigned short port)
{
    return false;
}

bool BaseSocket::Bind(char *ipaddr, unsigned short port)
{
    return false;
}

BaseSocket::~BaseSocket()
{
//    printf("BaseSocket::~BaseSocket() \n");
}

void BaseSocket::Disconnect()
{
    //
}

