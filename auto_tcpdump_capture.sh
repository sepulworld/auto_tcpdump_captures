#-------------------------------------------------------------------------------
# Name:        	auto_tcpdump_capture
# Purpose:	monitor interfaces for incrementing NIC errors, auto tcpdump
#
# Author:      zane williamson
#
# Created:     12/5/2011
# Copyright:   (c) zane 2011
# Licence:     GPL
#-------------------------------------------------------------------------------

#!/bin/bash



# Establish initial baseline error output on both interfaces, assuming system has just 2 interfaces.  I should make this more intelligent to create additional
# base lines based upon actual number of interfaces up on the system the script is running on.
  
INITIAL_ETH1_COUNTER=`ifconfig eth1 | grep RX | grep errors | cut -d: -f3 | awk '{print $1}'`
INITIAL_ETH0_COUNTER=`ifconfig eth0 | grep RX | grep errors | cut -d: -f3 | awk '{print $1}'`

# while loop to continually check ifconfig interface error messages and output to temp file

x=1

while [ $x == 1 ]
do
	ifconfig eth1 | grep RX | grep errors | cut -d: -f3 | awk '{print $1}' > temp_error_count_eth1.txt
        ifconfig eth0 | grep RX | grep errors | cut -d: -f3 | awk '{print $1}' > temp_error_count_eth0.txt

COUNTER_eth0=`cat temp_error_count_eth0.txt`
COUNTER_eth1=`cat temp_error_count_eth1.txt`

if [ $COUNTER_eth0 -gt $INITIAL_ETH0_COUNTER ] ;
        then tcpdump -vv -i eth1 ! port 22 -C5MB -w eth1_error_increment_capture.pcap
	x=0
	echo "`date`: error increment on eth0, tcpdump capture run.  See pcap located in directory of script. Restart script if needed." >> /var/log/message
	exit	


elif [ $COUNTER_eth1 -gt $INITIAL_ETH1_COUNTER ] ; 
	then tcpdump -vv -i eth0 ! port 22 -C5MB -w eth0_error_increment_capture.pcap
	echo "`date`: error increment on eth1, tcpdump capture run.  See pcap located in directory of script. Restart script if needed." >> /var/log/message
	x=0
	exit


else
sleep 2 ;

fi

done







