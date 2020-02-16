//This code was running on Linux(CentOS 7.6)
//Confirm receive packet by netcat.

#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <cstdio>
#include <arpa/inet.h>
#include <string>
#include <string.h>
#include <stdio.h>
#include <iostream>
#include <sstream>

using namespace std;

class MagicPacket {
    public:
        int sendPacket(){

        }
        
    private:
        const char convertoBit(char c){
            switch(toupper(c)){
                case '0': return 'a';
                case '1': return 'b';
                case '2': return 'c';
                case '3': return 'd';
                case '4': return 'e';
                case '5': return 'f';
                case '6': return 'g';
                case '7': return 'h';
                case '8': return 'i';
                case '9': return 'j';
                case 'A': return 'k';
                case 'B': return 'l';
                case 'C': return 'm';
                case 'D': return 'n';
                case 'E': return 'o';
                case 'F': return 'p';
            }
        }
        //Convert MAC addr to bytearray then add to data array
        void convertMacAddrToByte(char* macaddr, char* data){
            int index = 0;
            for(int i = 0; i < strlen(macaddr); i++){
                char tmp = macaddr[i];
                if(tmp == ':' | tmp == '-') continue;
                data[index] = convertoBit(tmp) - 'a';
                index++;
            }
        }
        //Create MagicPacket Payload from data bytearray
        void createMagicPacket(char* data, char* packet){
            int index = 0;
            while(index < 12) {
                packet[index] = 'a' - 96;
                index++;
            }
            while(index < 204){
                for(int i = 0; i < 12; i++){
                    packet[index] = data[i];
                    index++;
                }
                index--;
            }
        }
}


//Argument which is macaddress convert to binary data.
//Create date gram of magic packet.


//main function.
int main(int argc, char* argv[]){

    struct sockaddr_in destination;
    int port = 9999;
    char packet[204];
    char data[12];
    char* macaddr = argv[1];

    macaddrData(macaddr, (char *)data);
    magicPacket((char *)data, (char *)packet);

    int socketid = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

    if(socketid < 0){
        perror("Make socket is failed!\n");
        return -1;
    }

    destination.sin_family = AF_INET;
    destination.sin_addr.s_addr = htonl(0x0a00de07);
    destination.sin_port = htons(port);

  //for(int i = 0; i < 204; i++) printf("%#x ", packet[i]);

    int status_sendto = sendto(socketid, packet, strlen(packet), 0, (struct sockaddr *)&destination, sizeof(destination));

    if(status_sendto < 0){
        perror("Sending packet is failed!\n");
        return -1;
    }

    return 0;
}
