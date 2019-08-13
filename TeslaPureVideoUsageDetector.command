#!/bin/sh

loc=`locale | grep LANG | sed -e 's/.*LANG="\(.*\)_.*/\1/'`

lines=3
col=80

osascript -e "tell application \"Terminal\" to set the font size of window 1 to 12"
osascript -e "tell application \"Terminal\" to set background color of window 1 to {1028, 12850, 33240}"
osascript -e "tell application \"Terminal\" to set normal text color of window 1 to {65535, 65535, 65535}"

clear && printf '\e[8;'${lines}';'$col't' && printf '\e[3J' && printf "\033[H"

printf '\n'

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
    corr=${#client}
    let "corr=corr/2"
    let "corrl=20-corr"
    fi
    printf "\033[?25l"
    if [[ ! $client = "" ]]; then 
        printf '\r                                                                                \r'
        if [ $loc = "ru" ]; then

        printf '\r'"%"$corrl"s"'     \e[36;1mКлиент \e[33;1m''"'"$client"'"''\e[36;1m использует PureVideoHD\e[0m'
        SUBTITLE="Клиент ""$client"
        MESSAGE="использует аппаратное ускорение"
        COMMAND="display notification \"${MESSAGE}\" with title \"${TITLE}\" subtitle \"${SUBTITLE}\""
        osascript -e "${COMMAND}"

        else

        printf '\r'"%"$corrl"s"'      \e[36;1mClient \e[33;1m''"'"$client"'"''\e[36;1m is using PureVideoHD\e[0m '
        SUBTITLE="The client ""$client"
        MESSAGE="is using the hardware decoder"
        COMMAND="display notification \"${MESSAGE}\" with title \"${TITLE}\" subtitle \"${SUBTITLE}\" sound name \"${AIFF}\""
        osascript -e "${COMMAND}"
        fi

    else

        if [ $loc = "ru" ]; then
        printf '\r                \e[33;1mАппаратный декодер NVidia сейчас не используется\e[0m                '
        osascript -e 'display notification "не используется" with title "PureVideoHD"'
        else
        printf '\r                 \e[33;1mTesla hardware video decoder not in use now \e[0m                   '
        osascript -e 'display notification "not using" with title "PureVideoHD"'
        fi
    fi
fi
read -s -t 1 -n 1 input
if [[ $input = [QqЙй] ]]; then break; fi
done
printf "\033[?25h"
 sleep 0.5 && osascript -e 'tell application "Terminal" to close first window' & exit
exit 1


