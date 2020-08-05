#!/bin/bash

# FUNCS

CHECK_GVA(){
for i in 1 2 3 4 5 6; do
res=$(ioreg -l | grep "PerformanceStatistics" | tr -d '"' | egrep -o "GPU Video Engine Utilization=[0-9]{1,2}" | awk -F "=" '{print $2}')
if [[ ! $res = 0 ]]; then break; fi
sleep 0.5
done
}

DISPLAY_NOTIFICATION(){
~/Library/Application\ Support/TeslaGVA/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "PureVideoHD" -subtitle "${SUBTITLE}" -message "${MESSAGE}" 
}

GET_CLIENT_INFO(){
while true
    do
         res=""   
         ionv_ioreg=$(ioreg -c IONVGraphicsClientTesla -r | egrep -oE -a2 "NVDVDContextTesla" | grep -m 1 IOUserClientCreator)
         if [[ ! "$ionv_ioreg" = "$ionv_ioreg_old" ]]; then ionv_ioreg_old="$ionv_ioreg"; if [[ ! $ionv_ioreg = "" ]]; then CHECK_GVA ; break; fi; fi
         sleep 1
    done
}

GET_CLIENT_ID(){
client_pid=$(echo "$ionv_ioreg" | awk '{print $4}' | tr -d ",")
    if [[ ! $client_pid = "" ]]; then
        client=$(ps xco pid,command  | grep $client_pid | awk '{print $2}')
         case "${client}" in
           QuickLookUIService)  client="Quick Look" ;;
           mpv-bundle) client="MPV" ;;
         esac
            if [[ ${#client} -gt 41 ]]; then client=$( echo "${client:0:41}"); fi
    fi
}

#INIT
loc=$(defaults read -g AppleLocale | cut -d "_" -f1)

# MAIN
    
   while true
do

GET_CLIENT_INFO


if [[ ! "$ionv_ioreg" = "" ]]; then 

    GET_CLIENT_ID


    if  [[ ! $res = 0 ]]; then 
        
        if [[ $loc = "ru" ]]; then
        SUBTITLE="Клиент ""$client"
        MESSAGE="использует аппаратное ускорение"
        DISPLAY_NOTIFICATION
        else
        SUBTITLE="$client"
        MESSAGE="is using decoding hardware acceleration"
        DISPLAY_NOTIFICATION
        fi

    fi
fi
done

