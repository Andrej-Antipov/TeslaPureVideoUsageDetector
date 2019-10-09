#!/bin/sh


TITLE="PureVideoHD"

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
        COMMAND="display notification \"${MESSAGE}\" with title \"${TITLE}\" subtitle \"${SUBTITLE}\""
        osascript -e "${COMMAND}"

        else

        SUBTITLE="$client"
        MESSAGE="is using decoding hardware acceleration"
        COMMAND="display notification \"${MESSAGE}\" with title \"${TITLE}\" subtitle \"${SUBTITLE}\""
        osascript -e "${COMMAND}"

        fi

    else

        if [[ $loc = "ru" ]]; then
        
        osascript -e 'display notification "не используется" with title "PureVideoHD"'
        else
        
        osascript -e 'display notification "is not in use now" with title "PureVideoHD"'
        fi
    fi
fi
sleep 1
done
exit 1


