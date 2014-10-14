//
//  TCPSocket.cpp
//  WiFiLamp
//
//  Created by Aniapp on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#include "TCPSocket.h"
#include <unistd.h>
TCPSocket::TCPSocket(UDPType type)
{
//    printf("TCPSocket::TCPSocket() \n");
    mType = type;
    mSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (mSocket > 0)
    {
        int flag = 1;
        if (ioctl(mSocket, FIONBIO, &flag) != 0)
            goto failed;
        
        if (mType == utServer)
        {
            int opt = 1;
            if (setsockopt(mSocket, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0)
                goto failed;
        }
    }
    
    return ;
    
failed:
    Disconnect();    
}

bool TCPSocket::Bind(unsigned short port)
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

int TCPSocket::Accept()
{
    int result = -1;
    if (mSocket > 0)
    {
        int res = listen(mSocket, 30);
        if (res == 0)
        {
            struct sockaddr_in addr;
            socklen_t len = sizeof(addr);
            res = accept(mSocket, (struct sockaddr *)&addr, &len);
            if (res > 0)
            {
                result = res;
                printf("[TCPSocket::Accept] %s (%d) \n", inet_ntoa(addr.sin_addr), res);
            }
        }
    }
    
    return result;
}

bool TCPSocket::Connect(char *ipaddr, unsigned short port)
{
    bool result = false;
    mPort = port;
    if (mSocket > 0)
    {
        struct sockaddr_in addr;
        socklen_t len = sizeof(addr);
        addr.sin_port = htons(port);
        addr.sin_family = AF_INET;
        inet_pton(AF_INET, ipaddr, &addr.sin_addr);
        
        int flag = 1;
        ioctl(mSocket, FIONBIO, &flag);
        
        if (connect(mSocket, (const struct sockaddr *)&addr, len) < 0)
        {
            fd_set fdr;
            fd_set fdw;
            fd_set fderr;
            _timeval tv;
            tv.tv_sec = 0;
            tv.tv_usec = 100;
            int retrytimes = 0;
            int maxretrytimes = 30;
            
            do 
            {
                FD_ZERO(&fdr);
                FD_ZERO(&fdw);
                FD_ZERO(&fderr);
                FD_SET(mSocket, &fdr);
                FD_SET(mSocket, &fdw);
                FD_SET(mSocket, &fderr);
                
                int res = select(mSocket+1, &fdr, &fdw, &fderr, (struct timeval *)&tv);
                printf("select result = %d \n", res);
                if (res != 0)
                {
                    if (FD_ISSET(mSocket, &fdr) || FD_ISSET(mSocket, &fdw))
                    {
                        int error;
                        socklen_t len = sizeof(error);
                        res = getsockopt(mSocket, SOL_SOCKET, SO_ERROR, &error, (socklen_t *)&len);
                        printf("getsockopt result = %d", res);
                        if (res >= 0)
                        {
                            result = true;
                            break;
                        }
                        printf("getsockopt result = %d", res);
                    }
                }
                
                if (++retrytimes >= maxretrytimes) break;
            } while (1);
        }
        else
        {
            result = true;
        }
    }
    return result;
}

int TCPSocket::Send(const char *pData, int size)
{
    if (mSocket > 0)
    {
        return send(mSocket, pData, size, 0);
    }
    
    return 0;
}

int TCPSocket::Recv(char *pOutData, int size)
{
    if (mSocket > 0)
    {
        return recv(mSocket, pOutData, size, 0);
    }
    
    return 0;
}

int TCPSocket::Send(int socket, const char *pData, int size)
{
    if (socket > 0)
    {
        return send(socket, pData, size, 0);
    }
    
    return 0;
}

int TCPSocket::Recv(int socket, char *pOutData, int size)
{
    if (socket)
    {
        return recv(socket, pOutData, size, 0);
    }
    
    return 0;
}

void TCPSocket::Disconnect()
{
    if (mSocket >= 0)
    {
        shutdown(mSocket, SHUT_RDWR);
        close(mSocket);
        mSocket = -1;
    }
}

TCPSocket::~TCPSocket()
{
    Disconnect();
//    printf("TCPSocket::~TCPSocket() \n");
}
