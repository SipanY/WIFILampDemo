//
//  TCPSocket.h
//  WiFiLamp
//
//  Created by Aniapp on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef WiFiLamp_TCPSocket_h
#define WiFiLamp_TCPSocket_h

#include "BaseSocket.h"

class TCPSocket: public BaseSocket
{    
public:
    TCPSocket(UDPType type);
    ~TCPSocket();
    
    bool Connect(char *ipaddr, unsigned short port);
    bool Bind(unsigned short port);
    int Accept();
    void Disconnect();
    
    int Recv(char *pOutData, int size);
    int Send(const char *pData, int size);
    
    static int Recv(int socket, char *pOutData, int size);
    static int Send(int socket, const char *pData, int size);
public:
    
private:
    UDPType mType;
};


#endif
