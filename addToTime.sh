#!/bin/bash

#declare -i theHour
declare -i offset

offset=8

# read from std in and while loop through if time in range add 6 hours
while read line
do
  read commitish time <<< $line
  #echo  "  OOOO  commitish= $commitish  and time= $time"
  xhour=`date --date "$time" +'%H'`
#  echo "xhour is $xhour"
  theHour=$((10#$xhour))
  #echo "theHour is $theHour" # strip the leading zeros
  if [ "$theHour" -ge 9 ] && [ "$theHour" -lt 18 ]
  then
    echo "${commitish}~"`date --date "${time}+ $offset Hours" +'%Y-%m-%d %H:%M:%S %z'`
  else
    echo "${commitish}~"`date --date "$time" +'%Y-%m-%d %H:%M:%S %z'`
  fi
done <&0
