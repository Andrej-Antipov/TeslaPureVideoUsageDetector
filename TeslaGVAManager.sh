#!/bin/bash

clear && printf '\e[3J' && printf '\033[0;0H'

osascript -e "tell application \"Terminal\" to set the font size of window 1 to 12"
osascript -e "tell application \"Terminal\" to set background color of window 1 to {1028, 12850, 10240}"
osascript -e "tell application \"Terminal\" to set normal text color of window 1 to {65535, 65535, 65535}"


lines=24
printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H"

printf "\033[?25l"

printf '\e[2m************** \e[0m\e[36mПрограмма управления сервисом Tesla GVA Detector\e[0m\e[2m ****************\e[0m\n'


cd $(dirname $0)

loc=`defaults read -g AppleLocale | cut -d "_" -f1`
if [[ ! $loc = "ru" ]]; then loc="en"; fi 

EXIT_PROGRAM(){
################################## очистка на выходе #############################################################
cat  ~/.bash_history | sed -n '/TeslaGVAManager/!p' >> ~/new_hist.txt; rm ~/.bash_history; mv ~/new_hist.txt ~/.bash_history
#####################################################################################################################

     osascript -e 'tell application "Terminal" to close first window' & exit
}



CLEAR_PLACE(){

                    printf "\033[H"
                    printf "\033['$free_lines';0f"
                    printf ' %.0s' {1..80}
                    printf ' %.0s' {1..80}
                    printf ' %.0s' {1..80}
                    printf ' %.0s' {1..80}
                    printf ' %.0s' {1..80}
                    printf ' %.0s' {1..80}
                    printf ' %.0s' {1..80}
                    printf ' %.0s' {1..80}
                    printf ' %.0s' {1..80}
                    printf '\r\033[9A'

}

SET_INPUT(){

layout_name=`defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | egrep -w 'KeyboardLayout Name' | sed -E 's/.+ = "?([^"]+)"?;/\1/' | tr -d "\n"`
xkbs=1

case ${layout_name} in
 "Russian"          ) xkbs=2 ;;
 "RussianWin"       ) xkbs=2 ;;
 "Russian-Phonetic" ) xkbs=2 ;;
 "Ukrainian"        ) xkbs=2 ;;
 "Ukrainian-PC"     ) xkbs=2 ;;
 "Byelorussian"     ) xkbs=2 ;;
 esac

if [[ $xkbs = 2 ]]; then 
cd $(dirname $0)
    if [[ -f "./tools/xkbswitch" ]]; then 
declare -a layouts_names
layouts=`defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleInputSourceHistory | egrep -w 'KeyboardLayout Name' | sed -E 's/.+ = "?([^"]+)"?;/\1/' | tr  '\n' ';'`
IFS=";"; layouts_names=($layouts); unset IFS; num=${#layouts_names[@]}
keyboard="0"

while [ $num != 0 ]; do 
case ${layouts_names[$num]} in
 "ABC"                ) keyboard=${layouts_names[$num]} ;;
 "US Extended"        ) keyboard="USExtended" ;;
 "USInternational-PC" ) keyboard=${layouts_names[$num]} ;;
 "U.S."               ) keyboard="US" ;;
 "British"            ) keyboard=${layouts_names[$num]} ;;
 "British-PC"         ) keyboard=${layouts_names[$num]} ;;
esac

        if [[ ! $keyboard = "0" ]]; then num=1; fi
let "num--"
done

if [[ ! $keyboard = "0" ]]; then ./tools/xkbswitch -se $keyboard; fi
   else
        
printf '\r               \e[1;33;5m!!!  Смените раскладку на латиницу   !!!\e[0m               '
read -t 2 -s 
printf '\r                                        \r'
       
 fi
fi
}

GET_INPUT(){
unset inputs
while [[ ! ${inputs} =~ ^[0-9qQaAbBcC]+$ ]]; do
printf "\033[?25l"             
printf '  Введите символ от \e[1;33m1\e[0m до \e[1;36m4\e[0m, (или \e[1;35mQ\e[0m - выход ):   ' ; printf '                             '
			
printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
printf "\033[4A"
printf "\r\033[46C"
printf "\033[?25h"
read -n 1 inputs 
if [[ ${inputs} = "" ]]; then printf "\033[1A"; fi
printf "\r"
done
printf "\033[?25l"

}

CHECK_TESLAGVA(){

if [[ $(launchctl list | grep "TeslaGVA.job" | cut -f3 | grep -x "TeslaGVA.job") ]]; then  rs_lan="работает"
        else
if [[ ! -f ~/Library/LaunchAgents/TeslaGVA.plist ]]; then rs_lan="не установлен"
            else
                 rs_lan="остановлен"
        fi
fi
}

SHOW_MENU(){

CHECK_TESLAGVA

free_lines=16

printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H"

printf '\e[2m************** \e[0m\e[36mПрограмма управления сервисом Tesla GVA Detector\e[0m\e[2m ****************\e[0m\n'
printf ' %.0s' {1..80}
printf '.%.0s' {1..80}
printf ' %.0s' {1..80}
if [[ $rs_lan = "работает" ]]; then
printf '               \e[1;32m     Сервис \e[0mTesla GVA Detector \e[1;32m'"$rs_lan"'\e[0m               \n'
else
printf '               \e[1;33m     Сервис \e[0mTesla GVA Detector \e[1;33m'"$rs_lan"'\e[0m               \n'
fi
printf ' %.0s' {1..80}
printf '.%.0s' {1..80}
printf '\n'
printf ' %.0s' {1..80}
printf '          \e[1;33m1.\e[0m Установить сервис Tesla GVA Detector        \n'
printf '          \e[1;33m2.\e[0m Остановить                   \n'
printf '          \e[1;33m3.\e[0m Запустить                 \n'
printf '          \e[1;33m4.\e[0m Удалить сервис Tesla GVA Detector       \n'
printf '          \e[1;35mQ.\e[0m Выйти из программы настройки       \n'
printf ' %.0s' {1..80}
}



######################################## MAIN ##########################################################################################
free_lines=7
var4=0
while [ $var4 != 1 ] 
do
printf '\e[3J' && printf "\033[0;0H" 
printf "\033[?25l"
SHOW_MENU
SET_INPUT
GET_INPUT

if [[ $inputs = 1 ]]; then
            CLEAR_PLACE
            CHECK_TESLAGVA
            if [[ ! $rs_lan = "остановлен" ]] || [[ ! $rs_lan = "работает" ]]; then
            if [[ -f tools/TeslaGVA.plist ]] && [[ -f tools/TeslaGVA.sh ]]; then
                if [[ ! -f ~/Library/LaunchAgents/TeslaGVA.plist ]]; then cp -a tools/TeslaGVA.plist ~/Library/LaunchAgents; fi
                plutil -remove ProgramArguments.0 ~/Library/LaunchAgents/TeslaGVA.plist
                plutil -insert ProgramArguments.0 -string "/Users/$(whoami)/.TeslaGVA.sh" ~/Library/LaunchAgents/TeslaGVA.plist
                if [[ ! -f ~/.TeslaGVA.sh ]]; then cp -a tools/TeslaGVA.sh ~/.TeslaGVA.sh; chmod u+x ~/.TeslaGVA.sh; fi
                if [[ ! $rs_lan = "работает" ]]; then launchctl load -w ~/Library/LaunchAgents/TeslaGVA.plist; fi
        else
        printf '\n   Не найдены файлы для установки. Поместите их в папку tools с установщиком\n'
        printf '\n'
        
        fi
fi

read -n 1 -t 1
CLEAR_PLACE
fi


if [[ $inputs = 2 ]]; then
    CHECK_TESLAGVA
    if [[ $rs_lan = "работает" ]]; then
        if [[ -f ~/Library/LaunchAgents/TeslaGVA.plist ]]; then
            launchctl unload -w ~/Library/LaunchAgents/TeslaGVA.plist; fi
        fi
    CLEAR_PLACE
fi

if [[ $inputs = 3 ]]; then
     CHECK_TESLAGVA
    if [[ $rs_lan = "остановлен" ]]; then
        if [[ -f ~/Library/LaunchAgents/TeslaGVA.plist ]]; then
            launchctl load -w ~/Library/LaunchAgents/TeslaGVA.plist; fi
        fi
    CLEAR_PLACE
fi

if [[ $inputs = 4 ]]; then
    CHECK_TESLAGVA
    if [[ -f ~/.auth/auth.plist ]]; then
        loca=`cat ~/.auth/auth.plist | grep -Eo "Locale"  | tr -d '\n'`
        if [[ $loca = "Locale" ]]; then plutil -remove Locale ~/.auth/auth.plist; fi
    fi
        
    if [[ $(launchctl list | grep "TeslaGVA.job" | cut -f3 | grep -x "TeslaGVA.job") ]]; then launchctl unload -w ~/Library/LaunchAgents/TeslaGVA.plist; fi
    if [[ -f ~/Library/LaunchAgents/TeslaGVA.plist ]]; then rm ~/Library/LaunchAgents/TeslaGVA.plist; fi
    if [[ -f ~/.TeslaGVA.sh ]]; then rm ~/.TeslaGVA.sh; fi
    read -n 1 -t 1
    CLEAR_PLACE
fi



if [[ $inputs = [qQ] ]]; then var4=1; fi

done

clear

EXIT_PROGRAM






