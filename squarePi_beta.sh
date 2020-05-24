#!/bin/bash
# squarePi beta 0.2 - (c) DokT (under MIT License, please check LICENSE.md)
# Fully rewritten programm because of the mess I did on the alpha one lmao
#
# PLEASE READ README.MD (https://github.com/Dok-T/squarePi/blob/master/README.md)

# needed dependecies: bc, libxml2; xmlstarlet

# WHATS'S NEW? (squarePi_beta): 
# - Almost fixed the "preheat" function to allow low frequencies to be set on fans
# - Fully rewritten code (clearer than it was) 
# - Using "case" instead of "if" as main menu
# - Detects if the GPIO is unexported (working on it!)
# - Add logging function to log files and add color to output (working on it!)
# - Using "printf" instead of "echo" to get closer to C langage
# - Using XML for configs files. (libxml2 and xmlstarlet are required!)
# - A better way to check if required dependencies is satisfied and ask user to install them if they aren't  installed
# - Fixed --dep/-d if incorrect input, do a loop to re-lunch check dependencies
# Var
export config_path="./config.xml";
export config_path_tmp="./config.xml.tmp";
export freq=$2;
# At this moment, GPIO detection doesn't work. Please see future update.
export GPIO_target="/sys/class/gpio/gpio460/value"

# Strings (may allowing translates?)
about=" \n squarePi by DokT (v0.2)\n\n (c)DokT 2020 under MIT License. Please check LICENSE.md\n\n USE:\n\n -h --help show help.\n\n"
help=" \n squarePi by DokT (v0.2)\n\n (c)DokT 2020 under MIT License. Please check LICENSE.md\n\n USAGE:\n\n -h --help show this help\n -f --full full speed fan\n -o --off turn off fans\n -c --custom set custom frequency to the GPIO output (value in Second) \n -e --edit enable/disable logging type [1/0] \n -p --path [PATH] changing path directory of logs output\n\n"

# Functions
function color_printf () {
    # prints colored text (help from https://stackoverflow.com/questions/5412761/using-colors-with-printf)
    if [ "$2" == "info" ] ; then
        COLOR="96m";
    elif [ "$2" == "ok" ] ; then
        COLOR="92m";
    elif [ "$2" == "warning" ] ; then
        COLOR="93m";
    elif [ "$2" == "danger" ] ; then
        COLOR="91m";
    else
        # default shell color
        COLOR="0m";
    fi

    STARTCOLOR="\e[$COLOR";
    ENDCOLOR="\e[0m";

    printf "$STARTCOLOR%b$ENDCOLOR" "$1";
}
function color_info () {
    color_printf "[INFO] " "info";
}
function color_warning () {
    color_printf "[ERROR] " "danger";
}
function color_ok () {
    color_printf "[OK!] " "ok";
}
function dots () {
     for i in `seq 1 5`; do
          sleep 0.5;
          printf ".";
     done
     printf "\n";

}
function shutthisdown () {
    # Find a way to create a function thaht find, apply offset and export/unexport GPIO from /sys/class/gpio! 
    # Is "printf" a proper way to set a value in /sys/class/gpio?
          echo 0 > $GPIO_target;
          printf "\n\nExiting...\n";
          exit 0;
}
function depcheck () {
    color_info;
    printf "Checking dependencies and required files...\n";
        if [ -e "$config_path" ]; then
            color_ok;
            printf "config.xml found. OK!\n";
        else
            color_warning;
            printf "config.xml not found! please make sure %s is present.\n" "$config_path"
    fi

    if [ -e "/usr/bin/xmllint" ]; then
            color_ok;
            printf "libxml2 is installed!\n";
        else
            color_warning;
            printf " libxml2 is not installed!!!\n";
            read -r -p "Attemping to install libxml2? (ARCH !!) (Y/N) " dep_ask1
            case "$dep_ask1" in
                y|Y)
                    sudo pacman -S libxml2;
                ;;
                n|N)
                    printf "No...\n";
                ;;
                *)
                    printf "Use N/Y! please re-run -d --dep!\n";
                    $0 -d;
                ;;
            esac
    fi
    if [ -e "/usr/bin/xmlstarlet" ]; then
            color_ok;
            printf "xmlstarlet is installed!\n";
        else
            color_warning;
            printf " xmlstarlet is not installed!!!\n";
            read -r -p "Attemping to install xmlstarlet? (ARCH !!) (Y/N) " dep_ask1
            case "$dep_ask1" in
                y|Y)
                    sudo pacman -S xmlstarlet;
                ;;
                n|N)
                    printf "No...\n";
                ;;
                *)
                    printf "Use N/Y! please re-run -d --dep!\n";
                    $0 -d;

                ;;
            esac
    fi
    if [ -e "/usr/bin/bc" ]; then
            color_ok;
            printf "bc is installed!\n";
        else
            color_warning;
            printf "bc is not installed!!!\n";
            read -r -p "Attemping to install bc? (ARCH ONLY!!) (Y/N) " dep_ask2
            case "$dep_ask2" in
                y|Y)
                    sudo pacman -S bc;
                ;;
                n|N)
                    printf "No...\n";
                ;;
                *)
                    printf "Use N/Y! please re-run -d --dep!\n";
                    $0 -d;
                ;;
                
            esac
    fi

}
function log_this () {
    if [ $(xmllint --xpath '/root/config/log/enabled/text()' ./config.xml) = 1 ]; then
            $1 $2 | tee -a $(xmllint --xpath '/root/config/log/log_path/text()' ./config.xml)
        else
            $1 $2
    fi

}
function update_xml_logging () {
    if [ $1 -gt 1 ]; then
            printf "Wrong value! Type 1 or 0.\n";
            exit 1;
        else
            printf "Setting %s to config.xml...\n" "$1";
            xml ed -u '/root/config/log/enabled' -v $1 $config_path >> $config_path_tmp;
            mv $config_path_tmp $config_path;
            chmod 777 $config_path;        
    fi
}
function update_log_path () {
    if [ -d "$1" ]; then
            printf "%s exists! fine.\n" "$1";
                printf "Changing log dir to '%s'\n" "$1";
                xml ed -u '/root/config/log/log_path' -v "$1" $config_path >> $config_path_tmp;
                mv $config_path_tmp $config_path;
                chmod 777 $config_path;
        else
            printf "%s does not exists :(\n";
            read -r -p "Create it? Create it? [Y/N] " awnser;
            case "$awnser" in

            y|Y)
                printf "yes! :)\n";
                sudo mkdir -p $1;
                printf "Folder should be created. ";
                printf "Changing log dir to '%s'\n" "$1";
                xml ed -u '/root/config/log/log_path' -v "$1" $config_path >> $config_path_tmp;
                mv $config_path_tmp $config_path;
                chmod 777 $config_path;
            ;;
            n|N)
                printf "Exiting...\n";
                exit 1;
            ;;
            *)
                printf "Invalid input!\n";
                exit 1;
            ;;
            esac
    fi
}
function preheat () {
    color_info;
    printf "Reaching full speed before setting frequency...\n";
    echo 1 > $GPIO_target;
    dots;
}
function full_speed () {
    color_info;
    printf "Reaching full speed! Go to the moon! (unless you CTR+C to stop...)\n";
    dots;
    # still don't use a GPIO ecport!! beware.
    echo 1 > $GPIO_target;
}
function stop_fans () {
    color_info;
    printf "Stopping fans... Go back to the earth!\n";
    dots;
    echo 0 > $GPIO_target;
}
function spin! () {
     if [ $1 = 0 ]; then
            color_warning;
            printf "Please input a correct value (lower or higher than 0)\n";
           # exit
     else
         preheat;
          while [ true ]; do
          # Pushing math operations to allow live showing of MHz frequency
         Hz="$(echo "scale=3; 1/$1" | bc -l)" # F=1/T(s)
         echo 1 > $GPIO_target
         sleep $1
         echo 0 > $GPIO_target
         sleep $1
         echo "$Hz Hz ($1 s)"
        # To increment each loop 0.000555 seconds. It will allow to edit this in a future version of this software
        # freq=$(echo "$1 + 0.000555" | bc);

     done
    fi
}
# Chaging CTRL+C routine
trap shutthisdown INT;

case "$1" in

    -h|--help)
        printf "$help";
    ;;
    -e|--edit)
        printf "Changing logging state...\n";
        update_xml_logging $2;
    ;;    

    -d|--dep)
        depcheck;
    ;;

    -p|--path)
        printf "changing log path: %s\n" "$2";
        update_log_path $2;
    ;;
    -f|--full)
        full_speed;
    ;;
    -o|--off)
        stop_fans;
    ;;
    -c|--custom)
        spin! $2;
    ;;
    *)
        printf "$about";
    ;;
esac
#EOF