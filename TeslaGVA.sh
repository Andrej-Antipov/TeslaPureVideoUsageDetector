#!/bin/bash

# FUNCS

DISPLAY_NOTIFICATION(){
~/Library/Application\ Support/TeslaGVA/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "PureVideoHD" -subtitle "${SUBTITLE}" -message "${MESSAGE}" 
}

MESSAGE_HARDWARE(){
        if [[ $loc = "ru" ]]; then
        SUBTITLE="Клиент ""$client"
        MESSAGE="использует аппаратное ускорение"
        DISPLAY_NOTIFICATION &
        else
        SUBTITLE="$client"
        MESSAGE="is using decoding hardware acceleration"
        DISPLAY_NOTIFICATION &
        fi
}

MESSAGE_SOFTWARE(){
        if [[ $loc = "ru" ]]; then
        SUBTITLE="Клиент ""$client"
        MESSAGE="НЕ ИСПОЛЬЗУЕТСЯ декодирование через GPU"
        DISPLAY_NOTIFICATION &
        else
        SUBTITLE="$client"
        MESSAGE="This video NOT SUPPORTED by GPU decoder"
        DISPLAY_NOTIFICATION &
        fi
}

# INIT
gva_debug=$( defaults read com.apple.AppleGVA enableSyslog 2>/dev/null )
if [[ ! $gva_debug = 1 ]]; then defaults write com.apple.AppleGVA enableSyslog -boolean true ; fi

loc=`defaults read -g AppleLocale | cut -d "_" -f1`; if [[ ! $loc = "ru" ]]; then loc="en"; fi 

# MAIN
    
  while true
do 

unset a
res=$( log stream --style compact --predicate 'eventMessage CONTAINS "GVA"' | egrep -b5 -m 1 "PhysicalAccelerator create error" )
a=$( echo "$res" | grep -m 1 "PhysicalAccelerator create error" | awk '{print $NF}' )
client=$( echo "$res" | grep -m 1 "plugin is" | cut -f1 -d '[' | cut -f3 -d: | cut -c 11- ); if [[ ${#client} -gt 41 ]]; then client=$( echo "${client:0:41}"); fi
if [[ $a -lt 0 ]]; then MESSAGE_SOFTWARE; elif [[ $a = 0 ]]; then MESSAGE_HARDWARE; fi

done