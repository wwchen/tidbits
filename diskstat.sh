#!/bin/sh

# http://forums.nas4free.org/viewtopic.php?f=70&t=3513
# this is used with NAS4Free

date
echo
echo "-------------------------------------------------------------------------------------------------------"
echo "Disk    Disk State   Temp  MB/s  Hours  Load Count  Pending  Offline   Health   Last Test Result"
echo "-------------------------------------------------------------------------------------------------------"
camcontrol devlist | awk -F\( '{print $2'} | awk -F\, '{print $1}' | grep ada|while read LINE
do
   CM=$(camcontrol cmd $LINE -a "E5 00 00 00 00 00 00 00 00 00 00 00" -r - | awk '{print $10}')
   if [ "$CM" = "FF" ] ; then
      STATE="++ SPINNING ++"
   elif [ "$CM" = "00" ] ; then
      STATE="   STANDBY    "
   else
      STATE="** UNKNOWN ** "
   fi
   smartctl -a /dev/$LINE > /tmp/$LINE.txt
   BUS=`camcontrol inquiry ada0 -R | cut -f2 -d " " | cut -b1-3`
   TEMP=`grep Temperature /tmp/$LINE.txt | cut -b88-90`
        HOURS=`grep Power_On_Hours /tmp/$LINE.txt | cut -b88-99`
   PEND=`grep Pending /tmp/$LINE.txt | cut -b88-99`
   LOAD=`grep Load_Cycle_Count /tmp/$LINE.txt | cut -b88-99`
   OFFLINE=`grep Offline_Uncorrectable /tmp/$LINE.txt | cut -b88-99`
        HEALTH=`grep overall-health /tmp/$LINE.txt | cut -b51-99`
   LAST=`grep "# 1" /tmp/$LINE.txt | grep -v newer | cut -b26-51`
   printf "%-5s %-13s %3sc %4s %7s %11s %8s %8s %8s %s %s\n" $LINE "$STATE" $TEMP $BUS $HOURS $LOAD $PEND $OFFLINE $HEALTH "  $LAST"
done
echo "-------------------------------------------------------------------------------------------------------"
echo
