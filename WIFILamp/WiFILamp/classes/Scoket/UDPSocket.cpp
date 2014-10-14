//
//  UDPSocket.cpp
//  Padseen
//
//  Created by Aniapp on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#include "UDPSocket.h"
#include <unistd.h>
UDPSocket::UDPSocket(UDPType type)
{
//    printf("UDPSocket::UDPSocket() \n");
    mType = type;
    mSocket = socket(AF_INET, SOCK_DGRAM, 0);
    if (mSocket > 0)
    {
//        if (mType == utServer)
        {
            int opt = 1;
            if (setsockopt(mSocket, SOL_SOCKET, SO_BROADCAST, &opt, sizeof(opt)) < 0)
                goto failed;
            
            if (setsockopt(mSocket, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0)
                goto failed;
        }
    }
    
    return;
failed:
    Disconnect();
}

bool UDPSocket::Bind(unsigned short port)
{
    mPort = port;
    bool result = false;
    if (mSocket > 0)
    {
        struct sockaddr_in addr;
        addr.sin_len = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_port = htons(port);
        addr.sin_addr.s_addr = htonl(INADDR_ANY);
        
        if (bind(mSocket, (const struct sockaddr *)&addr, sizeof(addr)) == 0)
        {
            result = true;
        }
    }
    
    return result;
}

int UDPSocket::Recvfrom(char *pOutData, int size)
{
    struct sockaddr_in addr;
    return recvfrom(mSocket, pOutData, size, 0, (struct sockaddr *)&addr, 
                    (socklen_t *)sizeof(addr));
}

int UDPSocket::Recvfrom(char *pOutData, int size, char **ipaddr)
{
    struct sockaddr_in addr;
    ssize_t nSize = recvfrom(mSocket, pOutData, size, 0, (struct sockaddr *)&addr,
                             (socklen_t *)sizeof(addr));
    if (nSize > 0)
    {
        char *paddr = inet_ntoa(addr.sin_addr);
        memmove(*ipaddr, paddr, strlen(paddr));
//        [NSString stringWithCString:inet_ntoa(addr.sin_addr)
//                           encoding:[NSString defaultCStringEncoding]];
    }
    return nSize;
}

int UDPSocket::Sendto(const char*ipaddr, const char *pData, int size)
{
    int result = -1;
    if ((mSocket > 0) && ipaddr)
    {
        struct sockaddr_in addr;
        addr.sin_len = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_port = htons(mPort);
        inet_pton(AF_INET, ipaddr, &addr.sin_addr);
        
        result = sendto(mSocket, pData, size, 0, (const struct sockaddr *)&addr, sizeof(addr));
    }
    
    return result;
}

char* UDPSocket::BroadcastAddress()
{
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
//                if (buff[ifcount].ifr_addr.sa_family == AF_LINK) 
//                {
//                    struct sockaddr_dl *sdl = (struct sockaddr_dl*)&(buff[ifcount].ifr_addr);
//                    unsigned char *ptr = (unsigned char *)LLADDR(sdl);
//                    char temp[13] = {0};
                    
//                    printf("%02x%02x%02x%02x%02x%02x \n", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5));
//                    ::sprintf(temp, "%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5));
//                    printf("%s", temp);
//                }

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
                    memset(mBroadcastAddr, 0, sizeof(mBroadcastAddr));
                    strcpy(mBroadcastAddr, ip);
                }
                
                if (ioctl(mSocket, SIOCGIFNETMASK, &buff[ifcount]) == 0) 
                {
//                    char *ip = inet_ntoa(((struct sockaddr_in*)&buff[ifcount].ifr_addr)->sin_addr);
//                    printf("[subnet mask] is: %s \n", ip);
                }
            }
        }
    }
    
    return mBroadcastAddr;
}

void UDPSocket::Disconnect()
{
    if (mSocket >= 0)
    {
        shutdown(mSocket, SHUT_RDWR);
        close(mSocket);
        mSocket = -1;
    }
}

UDPSocket::~UDPSocket()
{
    Disconnect();
//    printf("UDPSocket::~UDPSocket() \n");
}
