
# squarePi.sh by DokT under MIT License.
Made 20/05/2020, last update 21/05/2020

It's not a true PWM signal, but a square signal. You might use a capacitor with a resistance to get a sinusoidal signal.
WARNING: I'm not responsible for any blown RPIs/IoT devices or electronic components suchs as fans, leds, whatever.
Us it at your own risk!


trap ctrl-c and call ctrl_c() thanks to this website: https://rimuhosting.com/knowledgebase/linux/misc/trapping-ctrl-c-in-bash
dep needed: bc (for maths operations)
install it with pacman -S bc / apt-get install bc to use this programm.

## Known bugs: 
 - "preheating" doesn't seem to care about the $phs var. So at this moment it does not work.

## Todo quickly! :
 - Use "case" instead of "if" conditions

## ROADMAP:
 - Tell what GPIOs are available for a basic raspberry pi (for Pi clones please ask me to add yout platform on this software) (ask me through https://github.com/Dok-T/squarePi/issues/new )
 - Auto detect where the GPIO should be used and export them id they're aren't exported yet and applying offset (issue for ArchLinuxArm users)
 - Supporting .conf files to add feataures and allowing the daemon mode
 - make it as daemon, so this would add the autostart feature
 - making a CLI based for setting up when enabling fans and make the daemon using configurations files

## Functions that (almost?) works:
 - Enable or disable fans
 - Set custom frequency of the output signal
 - Make a clean CTRL+C exit
 - Check if the required ddependencies are satisfied (not a lot of packages are needed, but it prevents from non-working programm on other OSes/systems)


# Basic usage :
 ./squarePi.sh 1 (for enabling) 0.5 (seconds)
 This will enable fans on the GPIO each 0.5 seconds and will stop it again and again. it will also calculate the frequency (for exemple, 0.3 is 2Hz)
 To stop it, use CTRL+C. 
