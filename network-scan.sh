#!/bin/bash

# Globarl vars
## Colors
declare -r color_red="\e[0;31m\033[1m"
declare -r color_green="\e[0;32m\033[1m"
declare -r color_blue="\e[0;34m\033[1m"
declare -r color_yellow="\e[0;33m\033[1m"
declare -r color_purple="\e[0;35m\033[1m"
declare -r color_turquoise="\e[0;36m\033[1m"
declare -r color_gray="\e[0;37m\033[1m"
declare -r color_end="\033[0m\e[0m"

## Symbols
declare -r symbol_success="${color_green}[+]"
declare -r symbol_info="${color_turquoise}[o]"
declare -r symbol_error="${color_red}[x]"
declare -r symbol_example="${color_yellow}[%]"
declare -r symbol_progress="${color_yellow}[#]"
declare -r symbol_interrupted="${color_blue}[!]"
declare -r symbol_completed="${color_green}[*]"

# Functions
## Validate the network CIRD
function validate_network() {
    local network_cidr="$1"

    if [[ ! $network_cidr =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        echo -e "\n${symbol_error} ${color_gray}Invalid network format: ${color_turquoise}$network_cidr${color_end}\n"
        exit 1
    fi

    IFS='/.' read -ra cidr_parts <<< "$network_cidr"
    local prefix_bits="${cidr_parts[4]}"

    if (( prefix_bits < 0 || prefix_bits > 32 )); then
        echo -e "\n${symbol_error} ${color_gray}Invalid prefix bits: ${color_turquoise}$prefix_bits${color_end}\n"
        exit 1
    fi
}

## Calculate the total hosts in a network
function calculate_hosts() {
    local network_cidr="$1"
    IFS='/' read -ra net_info <<< "$network_cidr"
    local base_network="${net_info[0]}"
    local netmask_bits="${net_info[1]}"

    IFS='.' read -ra octets <<< "$base_network"
    local network_prefix="${octets[0]}.${octets[1]}.${octets[2]}"

    local first_host=$((${octets[3]} + 1))
    local total_hosts=$((2 ** (32 - $netmask_bits) - 2))

    declare -a hosts=()

    for (( host=first_host; host < total_hosts + first_host; host++ )); do
        local target="$network_prefix.$host"
        hosts+=("$target")
    done

    echo "${hosts[@]}"
}

## Check if a host is ACTIVE in a NETWORK
function check_host() {
    local host=$1

    timeout 1 bash -c "ping -c 1 $host" &>/dev/null

    if [[ $? -eq 0 ]]; then
        echo -e "\t${symbol_success} ${color_gray}Host ${color_turquoise}$host ${color_gray}- ACTIVE"
    fi
}

## Help panel to show
function help_panel() {
    local optarg_network="${color_yellow}-n"
    local optarg_help="${color_yellow}-h"
    local file_name="${color_purple}$0"

    echo -e "\n${symbol_info} ${color_gray}Usage: ${file_name}"
    echo -e "\n\t${optarg_network} ${color_gray}<ip-network/prefix-mask>\tThe network with prefix to scan."
    echo -e "\n\t${optarg_help} ${color_gray}\t\t\t\tShow this help pannel."


    echo -e "\n${symbol_info} ${color_gray}Examples:"
    echo -e "\n\t${symbol_example} ${file_name} ${optarg_network} ${color_gray}10.0.0.0/11"
    echo -e "\n\t${symbol_example} ${file_name} ${optarg_network} ${color_gray}172.16.32.0/16"
    echo -e "\n\t${symbol_example} ${file_name} ${optarg_network} ${color_gray}192.168.1.0/29${color_end}\n"
}

## Ctrl + C function
function signal_handler() {
    echo -e "\n${symbol_interrupted} Exiting${color_end}\n"
    tput cnorm
    exit 1
}

### Redirect Ctrl + C to a function
trap signal_handler INT

# Main
## Parse options and arguments
while getopts ":n:h" arg; do
    case $arg in
        n)
            ### get value of the argumente -n (network)
            validate_network "$OPTARG"
            declare network_cidr="$OPTARG"
            ;;
        h)
            ### show the help panel
            help_panel
            tput cnorm
            exit 0
            ;;
        \?)
            ### Invalid -option
            echo -e "\n${symbol_error} ${color_gray}Invalid option: ${color_yellow}-$OPTARG\n" >&2
            tput cnorm
            exit 1
            ;;
        :)
            ### Missing value of the -option
            echo -e "\n${symbol_error} ${color_gray}Option ${color_yellow}-$OPTARG ${color_gray}requires an argument\n" >&2
            tput cnorm
            exit 1
            ;;
    esac
done

## Perform the network scan
if [[ -z "$network_cidr" ]]; then
    ### Missing arguments or values
    help_panel
    tput cnorm
    exit 1
else
    tput civis
    echo -e "\n${symbol_progress} ${color_gray}Scanning network: ${color_turquoise}$network_cidr\n"

    ### Check each host
    declare -a hosts=($(calculate_hosts "$network_cidr"))
    for host in ${hosts[@]}; do
        check_host "$host" &
    done; wait
fi

echo -e "\n${symbol_completed} Scanning completed${color_end}\n"
tput cnorm
