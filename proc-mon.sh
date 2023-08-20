#!/bin/bash

# Globarl vars
## Colors
declare -r color_blue="\e[0;34m\033[1m"

## Symbols
declare -r symbol_interrupted="${color_blue}[!]"

## Ctrl + c function
function signal_handler() {
    echo -e "\n${symbol_interrupted} Exiting${color_end}\n"
    tput cnorm
    exit 1
}

function main () {
    # Redirect Ctrl + c to a function
    trap signal_handler INT

    tput civis
    local old_process=$(ps -eo user,command)

    while true; do
        local new_process=$(ps -eo user,command)

        diff <(echo "$old_process") <(echo "$new_process") | grep "[\>\<]" | grep -vE "procmon|command|kworker"

        old_process=$new_process
    done
    tput cnorm
}

main
