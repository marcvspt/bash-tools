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
## Validate ips, hosts and domains
function validate_host() {
    local host="$1"
    if [[ "$host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ || "$host" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        return 0
    else
        return 1
    fi
}

## Validate ports
function validate_ports() {
    local ports="$1"
    local port_regex='^[0-9]+(-[0-9]+)?(,[0-9]+(-[0-9]+)?)*$'
    if [[ "$ports" =~ $port_regex ]]; then
        return 0
    else
        return 1
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

    timeout 1 bash -c "echo '' > /dev/tcp/$host/$port" &> /dev/null

    if [ $? -eq 0 ]; then
        echo -e "\t${symbol_success} ${color_gray}Port ${color_turquoise}$port${color_gray} - Open"
    fi
}

## Help panel to show
function help_panel() {
    local optarg_dest="${color_yellow}-d"
    local optarg_ports="${color_yellow}-p"
    local optarg_help="${color_yellow}-h"
    local file_name="${color_purple}$0"

    echo -e "\n${symbol_info} ${color_gray}Usage: ${file_name}"
    echo -e "\n\t${optarg_dest} ${color_gray}<ip-address or domain>\tThe IP, name or domain to scan."
    echo -e "\n\t${optarg_ports} ${color_gray}<port(s)>\t\t\tThe ports that want to scan."
    echo -e "\n\t${optarg_help} ${color_gray}\t\t\t\tShow this help pannel."

    echo -e "\n${symbol_info} ${color_gray}Examples:"
    echo -e "\n\t${symbol_example} ${file_name} ${optarg_dest} ${color_gray}192.168.1.150 ${optarg_ports} ${color_gray}80"
    echo -e "\n\t${symbol_example} ${file_name} ${optarg_dest} ${color_gray}192.168.1.150 ${optarg_ports} ${color_gray}1-1000"
    echo -e "\n\t${symbol_example} ${file_name} ${optarg_dest} ${color_gray}192.168.1.150 ${optarg_ports} ${color_gray}22,80,3306"
    echo -e "\n\t${symbol_example} ${file_name} ${optarg_dest} ${color_gray}192.168.1.150 ${optarg_ports} ${color_gray}1-1000,3306${color_end}\n"
}


## Ctrl + c function
function signal_handler() {
    echo -e "\n${symbol_interrupted} Exiting${color_end}\n"
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
            if ! validate_host "$host"; then
                echo -e "\n${symbol_error} ${color_gray}Invalid host: ${color_turquoise}$host\n" >&2
                exit 1
            fi
            ;;
        p)
            ### get value of the argumente -p (ports)
            declare port_args+=("$OPTARG")
            if ! validate_ports "${port_args[@]}"; then
                echo -e "\n${symbol_error} ${color_gray}Invalid port(s): ${color_turquoise}${port_args[@]}\n" >&2
                exit 1
            fi
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
            exit 1
            ;;
        :)
            ### Missing value of the -option
            echo -e "\n${symbol_error} ${color_gray}Option ${color_yellow}-$OPTARG ${color_gray}requires an argument\n" >&2
            exit 1
            ;;
    esac
done

## Perform the port scan
if [[ -z "$host" ]] || [[ ${#port_args[@]} -eq 0 ]]; then
    ### Missing arguments or values
    help_panel
    tput cnorm
    exit 1
else
    tput civis
    echo -e "\n${symbol_progress} ${color_gray}Scanning port(s): ${color_turquoise}${port_args[@]} ${color_gray}of ${color_turquoise}$host\n"

    ### Check each port of the host
    declare -a ports=$(calculate_ports "${port_args[@]}")
    for port in $ports; do
        check_port $host $port &
    done; wait
fi

echo -e "\n${symbol_completed} Scanning completed${color_end}\n"
tput cnorm
