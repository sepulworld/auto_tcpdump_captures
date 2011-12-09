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

## User Input ##  
# The first data input should be the number of packets you would like tcpdump
# to capture when an interface error occurs. I would recommend atleast 2000

# If no arguments given
function USAGE ()
{
	echo ""
	echo "USAGE: "
	echo "	auto_tcpdump.sh [-?p]"
	echo ""
	echo "OPTIONS:"
	echo "	-p number of packets to capture when error is detected"
	echo "	-? this usage information"
	echo ""
	echo "	auto_tcpdump.sh -p 2000"
	echo " this will capture 2000 packets"
	echo ""
	exit $E_OPTERROR	# exit with explaination given.

}

# if no packet number paramet specified print usage for user
if [ $# -lt 1 ]
	then USAGE;
exit 0 
fi

#Process Arguments
while getopts ":p:?" Option
do
	case $Option in
		p	) PortNumber=$OPTARG;;
		?	) USAGE 
			  exit 0;;
		*	) echo ""
			  echo "Unimplemented option chosen."
			USAGE  
	esac
done


shift $(($OPTIND - 1))
#  Decrements the argument pointer so it points to next argument.
#  $1 now references the first non option item supplied on the command line
#+ if one exists.


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
        then tcpdump -vv -i eth1 ! port 22 -c$PortNumber -w eth1_error_increment_capture.pcap
	echo "`date`: error increment on eth0, tcpdump capture run.  See pcap located in directory of script. Restart script if needed." >> /var/log/message
	x=0
	exit	


elif [ $COUNTER_eth1 -gt $INITIAL_ETH1_COUNTER ] ; 
	then tcpdump -vv -i eth0 ! port 22 -c$PortNumber -w eth0_error_increment_capture.pcap
	echo "`date`: error increment on eth1, tcpdump capture run.  See pcap located in directory of script. Restart script if needed." >> /var/log/message
	x=0
	exit


else
sleep 2 ;

fi


done

echo "`date`: auto_tcpdump_capture.sh process has stopped and initiated the tcpdump" >> /var/log/messages

done
