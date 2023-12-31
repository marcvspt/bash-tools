#!/usr/bin/bash

# Globarl vars
## Colors
declare -r colors_init="\e[" # Initialization

### Options
declare -r txt_regul="${colors_init}0"
declare -r txt_bold="${colors_init}1"

### Base colors
declare -r color_blue=";34m"

declare -r colors_end="${txt_regul}m" # RESET-END COLORS

### Bold text colors
declare -r col_txt_bld_blu="${txt_bold}${color_blue}"

## Symbols
declare -r symbol_interrupted="${col_txt_bld_blu}[!]"

## Ctrl + c function
function signal_handler() {
    echo -e "\n${symbol_interrupted} Exiting\n"
    echo -en "${color_end}"
    /usr/bin/tput cnorm
    exit 1
}

function main() {
    # Redirect Ctrl + c to a function
    trap signal_handler INT

    /usr/bin/tput civis
    local old_process=$(/usr/bin/ps -eo user,command)

    while true; do
        local new_process=$(/usr/bin/ps -eo user,command)

        /usr/bin/diff <(echo "$old_process") <(echo "$new_process") | /usr/bin/grep "[\>\<]" | /usr/bin/grep -vE "procmon|command|kworker"

        old_process=$new_process
    done
    /usr/bin/tput cnorm
}

main
