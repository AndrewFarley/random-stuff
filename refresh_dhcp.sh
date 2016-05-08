#!/bin/bash

echo "Starting up..."

while [ 1 ]; do
  
  echo "Checking if we are at home..."
  WIRELESSNET=`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep -i "SSID" | grep -v "BSSID"`
  
  # You must edit your wireless network name in here if you only want it to work for your network
  if [[ $WIRELESSNET == *"Purple Rocks"* ]]; then
    echo "Checking if we have an IP address..."
    WIRELESSIP=`ifconfig en0 | grep -i inet | grep -v inet6 | awk '{ print $2 }'`
    
    # You must edit your wireless network's IP range in here so it can check for it
    if [[ $WIRELESSIP == *"192.168.178."* ]]; then
      echo "We have an IP: $WIRELESSIP"
    
      echo "Performing checks if we have internet..."
      ping -t 1 4.2.2.1 2>&1 > /dev/null
   
      if [ $? -gt 0 ]; then 
        afplay /System/Library/Sounds/Basso.aiff
        echo "Failed once, checking again..."
        sleep 2
        ping -t 1 8.8.8.8 2>&1 > /dev/null
        if [ $? -gt 0 ]; then 
          afplay /System/Library/Sounds/Basso.aiff
          echo "Failed twice... checking one more time... "
          sleep 2
          ping -t 1 4.2.2.1 2>&1 > /dev/null
          if [ $? -gt 0 ]; then 
            afplay /System/Library/Sounds/Sosumi.aiff
            WIRELESSIP=`ifconfig en0 | grep -i inet | grep -v inet6 | awk '{ print $2 }'`
            growlnotify "Internet appears to not work" -m "Now refreshing DHCP: Old IP: $WIRELESSIP" -n "DHCP Refresh"
            sudo ipconfig set en0 DHCP
            # TODO: Wait here for new IP to tell us internet is back
          else
            echo "We have internet again the third try, yay!"
          fi
        else
          echo "We have internet again, yay!"
        fi
      
      else
        echo "We have internet, yay!"
      fi
    else 
      echo "We do not have an IP, skipping..."
    fi
    
  else
    echo "We are not on purple rocks network"
  fi
  
  sleep 10;
done;
