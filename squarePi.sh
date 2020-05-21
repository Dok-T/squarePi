#!/bin/bash

# PLEASE READ README.MD (https://github.com/Dok-T/squarePi/blob/master/README.md)

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