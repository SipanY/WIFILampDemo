//
//  UDPSocket.h
//  WiFiLamp
//
//  Created by Aniapp on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef WiFiLamp_UDPSocket_h
#define WiFiLamp_UDPSocket_h

#include "BaseSocket.h"

class UDPSocket: public BaseSocket
{    
public:
    UDPSocket(UDPType type);
    ~UDPSocket();
    
    bool Bind(unsigned short port);
    void Disconnect();
    
    int Recvfrom(char *pOutData, int size);
    int Recvfrom(char *pOutData, int size, char **ipaddr);
    int Sendto(const char*ipaddr, const char *pData, int size);
    
    char* BroadcastAddress();
private:
    UDPType mType;
    char mBroadcastAddr[16];
};

#endif
