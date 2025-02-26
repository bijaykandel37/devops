#!/bin/bash

#Reset Colour
RESET='\033[0m'       # Text Reset

#Normal Colours
RED='\033[0;31m'          # Red
GREEN='\033[0;32m'        # Green


# Bold
BRED='\033[1;31m'         # Red
BGREEN='\033[1;32m'       # Green
BBLUE='\033[1;34m'        # Blue

#Read IP from the List
cat ./ip_list.txt | while read ip;do
	#read port from the list
	cat ./port_list.txt | while read port;do
		echo -e "\n${BBLUE}***Testing Connection for IP: $ip on Port: $port*** ${RESET}"
		timeout 3s bash -c "</dev/tcp/$ip/$port" && echo -e "\n${BGREEN}Connected Established successfully\t IP: $ip on Port: $port${RESET}\n" || echo -e "\n${BRED}Connection Timed Out\t IP: $ip on Port: $port ${RESET}\n" >> noaccess.txt
	done
done
