#!/bin/bash

# FUNCS

STREAM_LOG(){
while true; do
log stream --style compact --predicate 'eventMessage CONTAINS "GVA"' | grep -m 1 "PhysicalAccelerator create error" | awk '{print $NF}' >> ~/Library/Application\ Support/TeslaGVA/temp01.txt 
sleep 1
done
}

START_GVA_DEBUG(){
defaults write com.apple.AppleGVA enableSyslog -boolean true
if [[ -f ~/Library/Application\ Support/TeslaGVA/temp01.txt ]]; then rm ~/Library/Application\ Support/TeslaGVA/temp01.txt; fi
if [[ -f ~/Library/Application\ Support/TeslaGVA/temp02.txt ]]; then rm ~/Library/Application\ Support/TeslaGVA/temp02.txt; fi
pstring=$(ps -ax | grep bash | grep -v grep | cut -f1 -d' ' | tr '\n' ';'); IFS=';'; old_pid=($pstring); unset IFS
STREAM_LOG &
pstring=$(ps -ax | grep bash | grep -v grep | cut -f1 -d' ' | tr '\n' ';'); IFS=';'; new_pid=($pstring); unset IFS
IFS=';'; diff_list=(`echo ${new_pid[@]} ${old_pid[@]} | tr ' ' '\n' | sort | uniq -u | tr '\n' ';'`); unset IFS;
echo "${diff_list}" >> ~/Library/Application\ Support/TeslaGVA/temp02.txt
}

CHECK_GVA_DEBUG(){
res=$( cat ~/Library/Application\ Support/TeslaGVA/temp01.txt )
rm -f ~/Library/Application\ Support/TeslaGVA/temp01.txt 
}

DISPLAY_NOTIFICATION(){
~/Library/Application\ Support/TeslaGVA/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "PureVideoHD" -subtitle "${SUBTITLE}" -message "${MESSAGE}" 
}

GET_CLIENT_INFO(){
while true
    do
         res=""   
         ionv_ioreg=$(ioreg -c IONVGraphicsClientTesla -r | egrep -oE -a2 "NVDVDContextTesla" | grep -m 1 IOUserClientCreator)
         if [[ ! "$ionv_ioreg" = "$ionv_ioreg_old" ]]; then ionv_ioreg_old="$ionv_ioreg"; if [[ ! $ionv_ioreg = "" ]]; then CHECK_GVA_DEBUG ; break; fi; fi
         sleep 1
    done
}

GET_CLIENT_ID(){
client_pid=$(echo "$ionv_ioreg" | cut -f4 -d '"' | cut -f1 -d "," | cut -c 4- | xargs)
    if [[ ! $client_pid = "" ]]; then
        client=$(ps xca  | grep $client_pid | cut -f2 -d ":" | cut -c 6- | xargs)
            if [[ ${#client} -gt 41 ]]; then client=$( echo "${client:0:41}"); fi
    fi
}

# INIT
gva_debug=$( defaults read com.apple.AppleGVA enableSyslog 2>/dev/null )
if [[ ! $gva_debug = 1 ]]; then defaults write com.apple.AppleGVA enableSyslog -boolean true ; fi

loc=`defaults read -g AppleLocale | cut -d "_" -f1`; if [[ ! $loc = "ru" ]]; then loc="en"; fi 
ionv_ioreg_old="0"

START_GVA_DEBUG

# MAIN
    
   while true
do

GET_CLIENT_INFO

if [[ ! "$ionv_ioreg" = "" ]]; then 

    GET_CLIENT_ID

    if  [[ $res = 0 ]]; then 
        
        if [[ $loc = "ru" ]]; then
        SUBTITLE="Клиент ""$client"
        MESSAGE="использует аппаратное ускорение"
        DISPLAY_NOTIFICATION
        else
        SUBTITLE="$client"
        MESSAGE="is using decoding hardware acceleration"
        DISPLAY_NOTIFICATION
        fi

    elif  [[ $res -lt 0 ]]; then 

        if [[ $loc = "ru" ]]; then
        SUBTITLE="Клиент ""$client"
        MESSAGE="НЕ ИСПОЛЬЗУЕТСЯ декодирование через GPU"
        DISPLAY_NOTIFICATION
        else
        SUBTITLE="$client"
        MESSAGE="This video NOT SUPPORTED by GPU decoder"
        DISPLAY_NOTIFICATION
        fi
    fi
fi
done

