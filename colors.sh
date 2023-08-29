#!/bin/bash

# Colors
declare -r colors_init="\e[" # Initialization

## Options
declare -r txt_regul="${colors_init}0"
declare -r txt_bold="${colors_init}1"
declare -r txt_under="${colors_init}4"

## Base colors
declare -r color_black=";30m"
declare -r color_red=";31m"
declare -r color_green=";32m"
declare -r color_yellow=";33m"
declare -r color_blue=";34m"
declare -r color_purple=";35m"
declare -r color_cyan=";36m"
declare -r color_white=";37m"

declare -r colors_end="${txt_regul}m" # RESET-END COLORS

# Regular text colors
declare -r col_txt_reg_blk="${txt_regul}${color_black}"
declare -r col_txt_reg_red="${txt_regul}${color_red}"
declare -r col_txt_reg_grn="${txt_regul}${color_green}"
declare -r col_txt_reg_ylw="${txt_regul}${color_yellow}"
declare -r col_txt_reg_blu="${txt_regul}${color_blue}"
declare -r col_txt_reg_pur="${txt_regul}${color_purple}"
declare -r col_txt_reg_cyn="${txt_regul}${color_cyan}"
declare -r col_txt_reg_wht="${txt_regul}${color_white}"

# Bold text colors
declare -r col_txt_bld_blk="${txt_bold}${color_black}"
declare -r col_txt_bld_red="${txt_bold}${color_red}"
declare -r col_txt_bld_grn="${txt_bold}${color_green}"
declare -r col_txt_bld_ylw="${txt_bold}${color_yellow}"
declare -r col_txt_bld_blu="${txt_bold}${color_blue}"
declare -r col_txt_bld_pur="${txt_bold}${color_purple}"
declare -r col_txt_bld_cyn="${txt_bold}${color_cyan}"
declare -r col_txt_bld_wht="${txt_bold}${color_white}"

# Underlined text colors
declare -r col_txt_und_blk="${txt_under}${color_black}"
declare -r col_txt_und_red="${txt_under}${color_red}"
declare -r col_txt_und_grn="${txt_under}${color_green}"
declare -r col_txt_und_ylw="${txt_under}${color_yellow}"
declare -r col_txt_und_blu="${txt_under}${color_blue}"
declare -r col_txt_und_pur="${txt_under}${color_purple}"
declare -r col_txt_und_cyn="${txt_under}${color_cyan}"
declare -r col_txt_und_wht="${txt_under}${color_white}"

# Background colors
declare -r col_bg_blk="${colors_init}40m" # Black
declare -r col_bg_red="${colors_init}41m" # Red
declare -r col_bg_grn="${colors_init}42m" # Green
declare -r col_bg_ylw="${colors_init}43m" # Yellow
declare -r col_bg_ble="${colors_init}44m" # Blue
declare -r col_bg_pur="${colors_init}45m" # Purple
declare -r col_bg_cyn="${colors_init}46m" # Cyan
declare -r col_bg_wht="${colors_init}47m" # White

# Symbols
declare -r symbol_success="${col_txt_bld_grn}[+]"
declare -r symbol_info="${col_txt_bld_cyn}[o]"
declare -r symbol_error="${col_txt_bld_red}[x]"
declare -r symbol_example="${col_txt_bld_ylw}[%]"
declare -r symbol_progress="${col_txt_bld_ylw}[#]"
declare -r symbol_interrupted="${col_txt_bld_blu}[!]"
declare -r symbol_completed="${col_txt_bld_grn}[*]"
declare -r symbol_money="${col_txt_bld_grn}\$"
declare -r symbol_question="${col_txt_bld_ylw}[?]"