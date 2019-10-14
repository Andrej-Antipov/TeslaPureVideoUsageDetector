#!/bin/sh

loc=`defaults read -g AppleLocale | cut -d "_" -f1`; if [[ ! $loc = "ru" ]]; then loc="en"; fi 

DISPLAY_NOTIFICATION(){
~/Library/Application\ Support/TeslaGVA/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "PureVideoHD" -subtitle "${SUBTITLE}" -message "${MESSAGE}" 
}


ionv_ioreg_old="0"

varn=0
while [[ $varn = 0 ]]; do
unset client; unset client_pid
ionv_ioreg=$(ioreg -c IONVGraphicsClientTesla -r | egrep -oE -a2 "NVDVDContextTesla" | grep -m 1 IOUserClientCreator)
if [[ ! "$ionv_ioreg" = "$ionv_ioreg_old" ]]; then  
ionv_ioreg_old="$ionv_ioreg"
client_pid=$(echo "$ionv_ioreg" | cut -f4 -d '"' | cut -f1 -d "," | cut -c 4- | xargs)
    if [[ ! $client_pid = "" ]]; then
        client=$(ps xca  | grep $client_pid | cut -f2 -d ":" | cut -c 6- | xargs)
            if [[ ${#client} -gt 41 ]]; then client=$( echo "${client:0:41}"); fi
    fi
    if [[ ! $client = "" ]]; then 
        loc=`defaults read -g AppleLocale | cut -d "_" -f1`; if [[ ! $loc = "ru" ]]; then loc="en"; fi 
        if [[ $loc = "ru" ]]; then

        SUBTITLE="Клиент ""$client"
        MESSAGE="использует аппаратное ускорение"
        DISPLAY_NOTIFICATION

        else

        SUBTITLE="$client"
        MESSAGE="is using decoding hardware acceleration"
        DISPLAY_NOTIFICATION

        fi

    else

        if [[ $loc = "ru" ]]; then
        
        ~/Library/Application\ Support/TeslaGVA/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "PureVideoHD" -message "не используется" 
        else
        
        ~/Library/Application\ Support/TeslaGVA/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "PureVideoHD" -message "is not in use now" 
        fi
    fi
fi
sleep 1
done
exit 1


