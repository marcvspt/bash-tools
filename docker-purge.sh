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

# Check the execution privileges
if [[ $EUID -ne 0 ]] && [[ $(groups | grep -o '\bdocker\b') != "docker" ]]; then
    echo -e "\n${symbol_error} ${col_txt_bld_wht}This script requires root privileges or membership in the docker group.\n"
    echo -en "${colors_end}"
    exit 1
fi

# Functions
## Delete containers
function delete_containers() {
    local containers=$(docker container ls -aq)

    if [[ $containers ]]; then
        echo -e "\n${symbol_progress} ${col_txt_bld_wht}Deleting all containers\n"
        docker container rm -f $containers &>/dev/null
    fi

    echo -en "${colors_end}"
}

## Delete images
function delete_images() {
    local images=$(docker image ls -q)

    if [[ $images ]]; then
        echo -e "\n${symbol_progress} ${col_txt_bld_wht}Deleting all images\n"
        docker image rm -f $images &>/dev/null
    fi

    echo -en "${colors_end}"
}

## Delete volumes
function delete_volumes() {
    local volumes=$(docker volume ls -q)

    if [[ $volumes ]]; then
        echo -e "\n${symbol_progress} ${col_txt_bld_wht}Deleting all volumes\n"
        docker volume rm -f $volumes &>/dev/null
    fi

    echo -en "${colors_end}"
}

## Delete networks (except the defaults)
function delete_networks() {
    local all_networks=$(docker network ls --format "{{.Name}}")
    local default_networks=("bridge" "host" "none")
    local networks=()

    for net in $all_networks; do
        if ! [[ " ${default_networks[@]} " =~ " $net " ]]; then
            networks+=("$net")
        fi
    done

    if [[ ${#networks[@]} -gt 0 ]]; then
        echo -e "\n${symbol_progress} ${col_txt_bld_wht}Deleting networks [except defaults]\n"
        docker network rm "${networks[@]}" &>/dev/null
    fi

    echo -en "${colors_end}"
}

## Show the help panel
function help_panel() {
    local optarg_containers="${col_txt_bld_ylw}-c"
    local optarg_images="${col_txt_bld_ylw}-i"
    local optarg_volumes="${col_txt_bld_ylw}-v"
    local optarg_networks="${col_txt_bld_ylw}-n"
    local optarg_all="${col_txt_bld_ylw}-a"
    local optarg_help="${col_txt_bld_ylw}-h"
    local file_name="${col_txt_bld_pur}$0"

    echo -e "\n${symbol_info} ${col_txt_bld_wht}Usage: ${file_name}"
    echo -e "\n\t${optarg_containers} ${col_txt_bld_wht}\tDelete containers."
    echo -e "\n\t${optarg_images} ${col_txt_bld_wht}\tDelete images."
    echo -e "\n\t${optarg_volumes} ${col_txt_bld_wht}\tDelete volumes."
    echo -e "\n\t${optarg_networks} ${col_txt_bld_wht}\tDelete networks."
    echo -e "\n\t${optarg_all} ${col_txt_bld_wht}\tDelete all (containers, images, volumes, networks)."
    echo -e "\n\t${optarg_help} ${col_txt_bld_wht}\tShow this help message.${colors_end}\n"
}

## Ctrl + c function
function signal_handler() {
    echo -e "\n${symbol_interrupted} Exiting${colors_end}\n"
    tput cnorm
    exit 1
}

### Redirect Ctrl + c to a function
trap signal_handler INT

# Main
## Parse options and arguments
declare -i parameter_counter=0

tput civis
while getopts ":civnah" arg; do
    case $arg in
        c)
            let parameter_counter++
            delete_containers
            ;;
        i)
            let parameter_counter++
            delete_images
            ;;
        v)
            let parameter_counter++
            delete_volumes
            ;;
        n)
            let parameter_counter++
            delete_networks
            ;;
        a)
            let parameter_counter++
            echo -e "\n${symbol_progress} ${col_txt_bld_wht}Deleting all resources\n"
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
            let parameter_counter++
            ### Invalid -option
            echo -e "\n${symbol_error} ${col_txt_bld_wht}Invalid option: ${col_txt_bld_ylw}-$OPTARG\n" >&2
            echo -en "${colors_end}"
            tput cnorm
            exit 1
            ;;
        :)
            let parameter_counter++
            ### Missing value of the -option
            echo -e "\n${symbol_error} ${col_txt_bld_wht}Option ${col_txt_bld_ylw}-$OPTARG ${col_txt_bld_wht}requires an argument.\n" >&2
            echo -en "${colors_end}"
            tput cnorm
            exit 1
            ;;
    esac
done

if [[ $# -eq 0 ]]; then
    help_panel
    tput cnorm
    exit 0
fi

if [[ $parameter_counter -gt 0 ]]; then
    echo -e "\n${symbol_completed} Done!\n"
    echo -en "${colors_end}"
    tput cnorm
else
    echo -e "\n${symbol_error} ${col_txt_bld_wht}Invalid argument.\n"
    echo -en "${colors_end}"
    tput cnorm
    exit 1
fi
