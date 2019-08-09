#!/bin/sh

loc=`locale | grep LANG | sed -e 's/.*LANG="\(.*\)_.*/\1/'`

lines=3
col=80

osascript -e "tell application \"Terminal\" to set the font size of window 1 to 12"
osascript -e "tell application \"Terminal\" to set background color of window 1 to {1028, 12850, 33240}"
osascript -e "tell application \"Terminal\" to set normal text color of window 1 to {65535, 65535, 65535}"

clear && printf '\e[8;'${lines}';'$col't' && printf '\e[3J' && printf "\033[H"

printf '\n'

#if [ $loc = "ru" ]; then
#printf '******     Детектируем использование аппаратного декодера NVidia Tesla    ******\n\n'
#else
#printf '******      Detecting the usage of NVidia Tesla hardware video decoder    ******\n\n'
#fi

varn=0
while [[ $varn = 0 ]]; do
unset client; unset client_pid
client_pid=$(ioreg -c IONVGraphicsClientTesla -r | grep -i  -A5 NVDVDContextTesla | grep -m 1 IOUserClientCreator | cut -f4 -d '"' | cut -f1 -d "," | cut -c 4- | xargs)
if [[ ! $client_pid = "" ]]; then
client=$(ps xca  | grep $client_pid | cut -f2 -d "." | cut -c 3- | xargs)
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
        else
        printf '\r'"%"$corrl"s"'      \e[36;1mClient \e[33;1m''"'"$client"'"''\e[36;1m is using PureVideoHD\e[0m '
        fi
    else
        if [ $loc = "ru" ]; then
        printf '\r                \e[33;1mАппаратный декодер NVidia сейчас не используется\e[0m                '
        else
        printf '\r                 \e[33;1mTesla hardware video decoder not in use now \e[0m                   '
        fi
fi 
read -s -t 1 -n 1 input
if [[ $input = [Qq] ]]; then break; fi
done
printf "\033[?25h"
 sleep 0.5 && osascript -e 'tell application "Terminal" to close first window' & exit
exit 1


