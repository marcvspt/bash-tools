#!/usr/bin/bash

# Globarl vars
## Colors
declare -r colors_init="\e[" # Initialization

### Options
declare -r txt_regul="${colors_init}0"
declare -r txt_bold="${colors_init}1"

### Base colors
declare -r color_red=";31m"
declare -r color_green=";32m"
declare -r color_yellow=";33m"
declare -r color_blue=";34m"
declare -r color_purple=";35m"
declare -r color_cyan=";36m"
declare -r color_white=";37m"

declare -r colors_end="${txt_regul}m" # RESET-END COLORS

### Bold text colors
declare -r col_txt_bld_red="${txt_bold}${color_red}"
declare -r col_txt_bld_grn="${txt_bold}${color_green}"
declare -r col_txt_bld_ylw="${txt_bold}${color_yellow}"
declare -r col_txt_bld_blu="${txt_bold}${color_blue}"
declare -r col_txt_bld_pur="${txt_bold}${color_purple}"
declare -r col_txt_bld_cyn="${txt_bold}${color_cyan}"
declare -r col_txt_bld_wht="${txt_bold}${color_white}"

## Symbols
declare -r symbol_success="${col_txt_bld_grn}[+]"
declare -r symbol_info="${col_txt_bld_cyn}[o]"
declare -r symbol_error="${col_txt_bld_red}[x]"
declare -r symbol_example="${col_txt_bld_ylw}[%]"
declare -r symbol_progress="${col_txt_bld_ylw}[#]"
declare -r symbol_interrupted="${col_txt_bld_blu}[!]"
declare -r symbol_completed="${col_txt_bld_grn}[*]"

# Functions
## Validate the network CIRD
function validate_network() {
    local network_cidr="$1"

    IFS='/.' read -ra cidr_parts <<< "$network_cidr"
    local prefix_bits="${cidr_parts[4]}"

    local prefix_bits_regex='^[0-9]{1,2}$'
    if [[ $prefix_bits -lt 0 || $prefix_bits -gt 32 ]] || [[ ! $prefix_bits =~ $prefix_bits_regex ]]; then
        echo -e "\n${symbol_error} ${col_txt_bld_wht}Invalid prefix bits: ${col_txt_bld_cyn}$prefix_bits${colors_end}\n"
        exit 1
    fi

    local network_cidr_regex='^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$'
    if [[ ! $network_cidr =~ $network_cidr_regex ]]; then
        echo -e "\n${symbol_error} ${col_txt_bld_wht}Invalid network format: ${col_txt_bld_cyn}$network_cidr${colors_end}\n"
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

    for (( host=$first_host; $host < $total_hosts + $first_host; host++ )); do
        local target="$network_prefix.$host"
        hosts+=("$target")
    done

    echo "${hosts[@]}"
}

## Check if a host is ACTIVE in a NETWORK
function check_host() {
    local host="$1"

    /usr/bin/timeout 1 bash -c "ping -c 1 $host" &>/dev/null

    if [[ $? -eq 0 ]]; then
        echo -e "\t${symbol_success} ${col_txt_bld_wht}Host ${col_txt_bld_cyn}$host ${col_txt_bld_wht}- ACTIVE"
    fi

    echo -en "${colors_end}"
}

## Help panel to show
function help_panel() {
    local optarg_network="${col_txt_bld_ylw}-n"
    local optarg_help="${col_txt_bld_ylw}-h"
    local file_name="${col_txt_bld_pur}$0"

    echo -e "\n${symbol_info} ${col_txt_bld_wht}Usage: ${file_name}"
    echo -e "\n\t${optarg_network} ${col_txt_bld_wht}<ip-network/prefix-mask>\tThe network with prefix to scan."
    echo -e "\n\t${optarg_help} ${col_txt_bld_wht}\t\t\t\tShow this help pannel."


    echo -e "\n${symbol_info} ${col_txt_bld_wht}Examples:"
    echo -e "\n\t${symbol_example} ${file_name} ${optarg_network} ${col_txt_bld_wht}10.0.0.0/11"
    echo -e "\n\t${symbol_example} ${file_name} ${optarg_network} ${col_txt_bld_wht}172.16.32.0/16"
    echo -e "\n\t${symbol_example} ${file_name} ${optarg_network} ${col_txt_bld_wht}192.168.1.0/29\n"

    echo -en "${colors_end}"
}

## Ctrl + C function
function signal_handler() {
    echo -e "\n${symbol_interrupted} Exiting\n"
    echo -en "${colors_end}"
    /usr/bin/tput cnorm
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
            declare network_cidr="$OPTARG"
            validate_network "$network_cidr"
            ;;
        h)
            ### show the help panel
            help_panel
            exit 0
            ;;
        \?)
            ### Invalid -option
            echo -e "\n${symbol_error} ${col_txt_bld_wht}Invalid option: ${col_txt_bld_ylw}-$OPTARG\n" >&2
            echo -en "${colors_end}"
            exit 1
            ;;
        :)
            ### Missing value of the -option
            echo -e "\n${symbol_error} ${col_txt_bld_wht}Option ${col_txt_bld_ylw}-$OPTARG ${col_txt_bld_wht}requires an argument.\n" >&2
            echo -en "${colors_end}"
            exit 1
            ;;
    esac
done

if [[ $# -eq 0 ]]; then
    help_panel
    exit 0
fi

## Perform the network scan
if [[ "$network_cidr" ]]; then
    /usr/bin/tput civis
    echo -e "\n${symbol_progress} ${col_txt_bld_wht}Scanning network: ${col_txt_bld_cyn}$network_cidr\n"

    ### Check each host
    declare -a hosts=($(calculate_hosts "$network_cidr"))
    for host in ${hosts[@]}; do
        check_host "$host" &
    done; wait

    echo -e "\n${symbol_completed} Scanning completed.\n"
    /usr/bin/tput cnorm

    echo -en "${colors_end}"
else
    echo -e "\n${symbol_error} ${col_txt_bld_wht}Invalid argument.\n"
    echo -en "${colors_end}"
    exit 1
fi
