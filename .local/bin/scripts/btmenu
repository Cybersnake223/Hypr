#!/bin/bash

############################################################################################################
##   ______  __      __  _______   ________  _______    ______   __    __   ______   __    __  ________   ##
##  /      \|  \    /  \|       \ |        \|       \  /      \ |  \  |  \ /      \ |  \  /  \|        \  ##
## |  $$$$$$\\$$\  /  $$| $$$$$$$\| $$$$$$$$| $$$$$$$\|  $$$$$$\| $$\ | $$|  $$$$$$\| $$ /  $$| $$$$$$$$  ##
## | $$   \$$ \$$\/  $$ | $$__/ $$| $$__    | $$__| $$| $$___\$$| $$$\| $$| $$__| $$| $$/  $$ | $$__      ##
## | $$        \$$  $$  | $$    $$| $$  \   | $$    $$ \$$    \ | $$$$\ $$| $$    $$| $$  $$  | $$  \     ##
## | $$   __    \$$$$   | $$$$$$$\| $$$$$   | $$$$$$$\ _\$$$$$$\| $$\$$ $$| $$$$$$$$| $$$$$\  | $$$$$     ##
## | $$__/  \   | $$    | $$__/ $$| $$_____ | $$  | $$|  \__| $$| $$ \$$$$| $$  | $$| $$ \$$\ | $$_____   ##
##  \$$    $$   | $$    | $$    $$| $$     \| $$  | $$ \$$    $$| $$  \$$$| $$  | $$| $$  \$$\| $$     \  ##
##   \$$$$$$     \$$     \$$$$$$$  \$$$$$$$$ \$$   \$$  \$$$$$$  \$$   \$$ \$$   \$$ \$$   \$$ \$$$$$$$$  ##
##                                                                                                        ##
## Bluetooth Script                                                                                       ##
## Created by Cybersnake                                                                                  ##
############################################################################################################

rfkill unblock bluetooth
bluetoothctl power on

get_device_mac() {
    local devices
    devices=$(bluetoothctl devices)

    if [ "$(echo "$devices" | wc -l)" -eq 1 ]; then
        MAC=$(echo "$devices" | awk '{print $2}')
    else
        select=$(echo "$devices" | awk '{print $3}' | rofi -dmenu -p "Select Device" -l 3)
        MAC=$(echo "$devices" | grep "$select" | awk '{print $2}')
    fi

    [ -z "$MAC" ] && MAC=NoDeviceFound
}

get_device_mac

connect=$(bluetoothctl info "$MAC" | grep "Connected:" | awk '{print $2}')

if [ "$connect" = "no" ]; then
    notify-send "Attempting to Connect" "$select"
    bluetoothctl connect "$MAC" || notify-send "Failed to Connect"
elif [ "$connect" = "yes" ]; then
    notify-send "Attempting to Disconnect" "$select"
    bluetoothctl disconnect "$MAC"
fi
