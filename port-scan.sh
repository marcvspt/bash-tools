#!/bin/bash

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
## Validate ips, hosts and domains
function validate_host() {
    local host="$1"

    local host_regex_ip='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
    local host_regex_name='^[a-zA-Z0-9.-]+$'
    if [[ ! "$host" =~ $host_regex_ip || ! "$host" =~ $host_regex_name ]]; then
        echo -e "\n${symbol_error} ${col_txt_bld_wht}Invalid host: ${col_txt_bld_cyn}$host\n" >&2
        echo -en "${colors_end}"
        exit 1
    fi
}

## Validate ports
function validate_ports() {
    local ports="$1"

    local port_regex='^[0-9]+(-[0-9]+)?(,[0-9]+(-[0-9]+)?)*$'
    if [[ ! "$ports" =~ $port_regex ]]; then
        echo -e "\n${symbol_error} ${col_txt_bld_wht}Invalid port(s): ${col_txt_bld_cyn}${port_args[@]}\n" >&2
        echo -en "${colors_end}"
        exit 1
    fi
}

## Calculate the total ports to scan
function calculate_ports() {
    local port_specs=("$@")
    local ports=()

    for port_spec in "${port_specs[@]}"; do
        IFS=',' read -ra port_list <<< "$port_spec"
        for port in "${port_list[@]}"; do
            if [[ $port == *-* ]]; then
                local start_port=${port%-*}
                local end_port=${port#*-}
                ports+=($(seq $start_port $end_port))
            else
                ports+=($port)
            fi
        done
    done

    echo "${ports[@]}"
}

## Check if a port is OPEN on a HOST
function check_port() {
    local host=$1
    local port=$2

    timeout 1 bash -c "echo '' > /dev/tcp/$host/$port" &>/dev/null

    if [[ $? -eq 0 ]]; then
        echo -e "\t${symbol_success} ${col_txt_bld_wht}Port ${col_txt_bld_cyn}$port${col_txt_bld_wht} - OPEN"
    fi

    echo -en "${colors_end}"
}

## Help panel to show
function help_panel() {
    local optarg_dest="${col_txt_bld_ylw}-d"
    local optarg_ports="${col_txt_bld_wht}-p"
    local optarg_help="${col_txt_bld_ylw}-h"
    local file_name="${col_txt_bld_pur}$0"

    echo -e "\n${symbol_info} ${col_txt_bld_wht}Usage: ${file_name}"
    echo -e "\n\t${optarg_dest} ${col_txt_bld_wht}<ip-address or domain>\tThe IP, name or domain to scan."
    echo -e "\n\t${optarg_ports} ${col_txt_bld_wht}<port(s)>\t\t\tThe ports that want to scan."
    echo -e "\n\t${optarg_help} ${col_txt_bld_wht}\t\t\t\tShow this help pannel."

    echo -e "\n${symbol_info} ${col_txt_bld_wht}Examples:"
    echo -e "\n\t${symbol_example} ${file_name} ${optarg_dest} ${col_txt_bld_wht}192.168.1.150 ${optarg_ports} ${col_txt_bld_wht}80"
    echo -e "\n\t${symbol_example} ${file_name} ${optarg_dest} ${col_txt_bld_wht}192.168.1.150 ${optarg_ports} ${col_txt_bld_wht}1-1000"
    echo -e "\n\t${symbol_example} ${file_name} ${optarg_dest} ${col_txt_bld_wht}192.168.1.150 ${optarg_ports} ${col_txt_bld_wht}22,80,3306"
    echo -e "\n\t${symbol_example} ${file_name} ${optarg_dest} ${col_txt_bld_wht}192.168.1.150 ${optarg_ports} ${col_txt_bld_wht}1-1000,3306\n"

    echo -en "${colors_end}"
}


## Ctrl + c function
function signal_handler() {
    echo -e "\n${symbol_interrupted} Exiting\n"
    echo -en "${colors_end}"
    tput cnorm
    exit 1
}

### Redirect Ctrl + c to a function
trap signal_handler INT

# Main
## Parse options and arguments
while getopts ":d:p:h" opt; do
    case $opt in
        d)
            ### -d get value of the argumente -d (destination = ip, host, name or domain)
            declare host="$OPTARG"
            validate_host "$host"
            ;;
        p)
            ### get value of the argumente -p (ports)
            declare port_args+=("$OPTARG")
            validate_ports "${port_args[@]}"
            ;;
        h)
            ### show the help panel
            help_panel
            tput cnorm
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
            echo -e "\n${symbol_error} ${col_txt_bld_wht}Option ${col_txt_bld_ylw}-$OPTARG ${col_txt_bld_wht}requires an argument\n" >&2
            echo -en "${colors_end}"
            exit 1
            ;;
    esac
done

## Perform the port scan
if [[ "$host" || ${#port_args[@]} -gt 0 ]]; then
    tput civis
    echo -e "\n${symbol_progress} ${col_txt_bld_wht}Scanning port(s): ${col_txt_bld_cyn}${port_args[@]} ${col_txt_bld_wht}of ${col_txt_bld_cyn}$host\n"

    ### Check each port of the host
    declare -a ports=$(calculate_ports "${port_args[@]}")
    for port in $ports; do
        check_port $host $port &
    done; wait

    echo -e "\n${symbol_completed} Scanning completed\n"
    echo -en "${colors_end}"
    tput cnorm
else
    echo -e "\n${symbol_error} ${col_txt_bld_wht}Invalid argument.\n"
    echo -en "${colors_end}"
    tput cnorm
    exit 1
fi
