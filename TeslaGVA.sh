#!/bin/sh

#MyPID=`echo $$`
##string=$(ps -xa | grep TeslaPureVideoUsageDetector | awk '{ print $1 }' | tr '\n' ';')
#IFS=";"; ResLan=($string); unset IFS; pos=${#ResLan[@]}
#if [[ ! $pos = 0 ]]; then
#for (( i=0; i<$pos; i++ )); do 
#if [[ ! ${ResLan[i]} = $MyPID ]]; then kill ${ResLan[i]} &>/dev/null; fi
#done
#fi

#loc=`locale | grep LANG | sed -e 's/.*LANG="\(.*\)_.*/\1/'`
loc=$(cat ~/.auth/auth.plist | grep -A 1 "Locale" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n')

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
        printf '\r                                                                                \r'
        if [ $loc = "ru" ]; then

        SUBTITLE="Клиент ""$client"
        MESSAGE="использует аппаратное ускорение"
        COMMAND="display notification \"${MESSAGE}\" with title \"${TITLE}\" subtitle \"${SUBTITLE}\""
        osascript -e "${COMMAND}"

        else

        SUBTITLE="The client ""$client"
        MESSAGE="is using the hardware decoder"
        COMMAND="display notification \"${MESSAGE}\" with title \"${TITLE}\" subtitle \"${SUBTITLE}\"\""
        osascript -e "${COMMAND}"
        fi

    else

        if [ $loc = "ru" ]; then
        
        osascript -e 'display notification "не используется" with title "PureVideoHD"'
        else
        
        osascript -e 'display notification "not using" with title "PureVideoHD"'
        fi
    fi
fi
sleep 1
done
 sleep 0.5 && osascript -e 'tell application "Terminal" to close first window' & exit
exit 1


