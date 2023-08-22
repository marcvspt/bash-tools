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

# Check if the user is root or is in the docker group
if [[ $EUID -ne 0 ]] && [[ $(groups | grep -o '\bdocker\b') != "docker" ]]; then
    echo -e "\n${symbol_error} ${color_gray}This script requires root privileges or membership in the docker group.${color_end}\n"
    exit 1
fi

# Functions
## Delete containers
function delete_containers() {
    local containers="$(docker container ls -aq 2>/dev/null)"

    if [[ $containers ]]; then
        echo -e "\n${symbol_progress} ${color_gray}Deleting all containers\n"
        docker container rm -f $containers &>/dev/null
    fi
}

## Delete images
function delete_images() {
    local images="$(docker image ls -q 2>/dev/null)"

    if [[ $images ]]; then
        echo -e "\n${symbol_progress} ${color_gray}Deleting all images\n"
        docker image rm -f $images &>/dev/null
    fi
}

## Delete volumes
function delete_volumes() {
    local volumes="$(docker volume ls -q 2>/dev/null)"

    if [[ $volumes ]]; then
        echo -e "\n${symbol_progress} ${color_gray}Deleting all volumes\n"
        docker volume rm -f $volumes &>/dev/null
    fi
}

## Delete networks (except the defaults)
function delete_networks() {
    local all_networks="$(docker network ls --format '{{.Name}}' 2>/dev/null)"
    local default_networks=("bridge" "host" "none")
    local networks=()

    for net in $all_networks; do
        if ! [[ " ${default_networks[@]} " =~ " $net " ]]; then
            networks+=("$net")
        fi
    done

    if [[ ${#networks[@]} -gt 0 ]]; then
        echo -e "\n${symbol_progress} ${color_gray}Deleting networks [except defaults]\n"
        docker network rm "${networks[@]}" &>/dev/null
    fi
}

## Help panel to show
function help_panel() {
    local optarg_containers="${color_yellow}-c"
    local optarg_images="${color_yellow}-i"
    local optarg_volumes="${color_yellow}-v"
    local optarg_networks="${color_yellow}-n"
    local optarg_all="${color_yellow}-a"
    local optarg_help="${color_yellow}-h"
    local file_name="${color_purple}$0"

    echo -e "\n${symbol_info} ${color_gray}Usage: ${file_name}"
    echo -e "\n\t${optarg_containers} ${color_gray}\tDelete containers."
    echo -e "\n\t${optarg_images} ${color_gray}\tDelete images."
    echo -e "\n\t${optarg_volumes} ${color_gray}\tDelete volumes."
    echo -e "\n\t${optarg_networks} ${color_gray}\tDelete networks."
    echo -e "\n\t${optarg_all} ${color_gray}\tDelete all (containers, images, volumes, networks)."
    echo -e "\n\t${optarg_help} ${color_gray}\tShow this help message.${color_end}\n"
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
tput civis
while getopts ":civnah" arg; do
    case $arg in
        c)
            delete_containers
            ;;
        i)
            delete_images
            ;;
        v)
            delete_volumes
            ;;
        n)
            delete_networks
            ;;
        a)
            echo -e "\n${symbol_progress} ${color_gray}Deleting all resources\n"
            delete_containers
            delete_images
            delete_volumes
            delete_networks
            ;;
        h)
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

if [[ $# -eq 0 ]]; then
    help_panel
    tput cnorm
    exit 0
else
    echo -e "\n${symbol_completed} Done${color_end}\n"
    tput cnorm
fi
