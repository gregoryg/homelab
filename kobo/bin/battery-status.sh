#!/bin/sh 
battery_dir=/sys/class/power_supply/bd71827_bat
echo "$(cat ${battery_dir}/status) $(cat ${battery_dir}/capacity)%"
