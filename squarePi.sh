#!/bin/bash

#
# squarePi.sh by DokT under MIT License. Made 20/05/2020, last update 21/05/2020
#
# It's not a true PWM signal, but a square signal. You might use a capacitor with a resistance to get a sinusoidal signal.
# WARNING: I'm not responsible for any blown RPIs/IoT devices or electronic components suchs as fans, leds, whatever.
# Us it at your own risk!

# ls /sys/class/gpio/ | egrep -Eo "[0-9]{2,4}" >> $INTVAR
# printf "$INTVAR\n"
# Use case instead of if conditions


# trap ctrl-c and call ctrl_c() thanks to this website: https://rimuhosting.com/knowledgebase/linux/misc/trapping-ctrl-c-in-bash
# dep needed: bc (for maths operations)
# install it with pacman -S bc / apt-get install bc to use this programm.

# Known bugs: "preheating" doesn't seem to care about the $phs var. So at this moment it does not work.
#
# ROADMAP:
# - Tell what GPIOs are available for a basic raspberry pi (for Pi clones please ask me to add yout platform on this software)
# - Auto detect where the GPIO should be used and export them id they're aren't exported yet and applying offset (issue for ArchLinuxArm users)
# - Supporting .conf files to add feataures and allowing the daemon mode
# - make it as daemon, so this would add the autostart feature
# - making a CLI based for setting up when enabling fans and make the daemon using configurations files
#
# Functions that (almost?) works:
# - Enable or disable fans
# - Set custom frequency of the output signal
# - Make a clean CTRL+C exit
# - Check if the required ddependencies are satisfied (not a lot of packages are needed, but it prevents from non-working programm on other OSes/systems)


# Basic usage :
# ./squarePi.sh 1 (for enabling) 0.5 (seconds)
# This will enable fans on the GPIO each 0.5 seconds and will stop it again and again. it will also calculate the frequency (for exemple, 0.3 is 2Hz)
# To stop it, use CTRL+C. 

if [ -e "/usr/bin/bc" ]; then
          echo "[Log] Dependencies satisfied. (BC)";
     else
          echo " _______________________________________________________________________________________";
          echo "| Missing dependencies.. (BC is not installed or not in the right place as it should be!|";
          echo "| This might be fixed by doing a symlink from original bc to /usr/bin/bc                |";
          echo "|_______________________________________________________________________________________|";
          exit 0;
fi

function preheat () {
     if (( $phs == 0 )); then
                echo "PRAHEATING...";
                echo 1 > /sys/class/gpio/gpio460/value;
                dots;
     else
           echo "preheating is not needed."
     fi
}

function dots () {
     for i in `seq 1 5`; do
          sleep 1;
          echo -n ".";
     done

}

function ctrl_c() {
     dots;
     echo "Shutting down...";
     shutthisdown;
}

function shutthisdown () { 
          echo 0 > /sys/class/gpio/gpio460/value
          phs=0
          exit 0
}

export input=$1
export freq=$2
export GPIOstate=$(cat /sys/class/gpio/gpio460/value)
export Hz="$(echo "scale=3; 1/$freq" | bc -l)" # F=1/T(s)
export phs=1

# If CTRL+C Is pressed, then do a proper way to quit this and shutting down the gpio/fans
trap ctrl_c INT


if [ $input = 1 ]; then
     
     if [ $freq == 0 ]; then
           echo "Please input a correct value";
           shutdown;
     else
         phs=1
         preheat;
          while [ true ]; do
         echo 1 > /sys/class/gpio/gpio460/value
         sleep $freq
         echo "$Hz Hz ($freq s)"
         echo 0 > /sys/class/gpio/gpio460/value
         sleep $freq
         echo "$Hz Hz ($freq s)"
     done
     fi

     
elif [ $input = 0 ]; then
     echo "Force shutting down fans";
     shutthisdown;
else
     printf "Usage: squarePi.sh [1 = enable / 0 = disabe] [freq in s (int value)]\n\n";
     shutthisdown;
fi

#
# squarePi.sh by DokT under MIT License. Made 20/05/2020, last update 21/05/2020
#
# It's not a true PWM signal, but a square signal. You might use a capacitor with a resistance to get a sinusoidal signal.
# WARNING: I'm not responsible for any blown RPIs/IoT devices or electronic components suchs as fans, leds, whatever.
# Us it at your own risk!

# ls /sys/class/gpio/ | egrep -Eo "[0-9]{2,4}" >> $INTVAR
# printf "$INTVAR\n"
# Use case instead of if conditions


# trap ctrl-c and call ctrl_c() thanks to this website: https://rimuhosting.com/knowledgebase/linux/misc/trapping-ctrl-c-in-bash
# dep needed: bc (for maths operations)
# install it with pacman -S bc / apt-get install bc to use this programm.

# Known bugs: "preheating" doesn't seem to care about the $phs var. So at this moment it does not work.
#
# ROADMAP:
# - Auto detect where the GPIO should be used and export them id they're aren't exported yet.
# - make it as daemon, so this would add the autostart feature
# - making a CLI based for setting up when enabling fans and make the daemon using configurations files