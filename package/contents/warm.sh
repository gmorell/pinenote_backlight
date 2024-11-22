#!/usr/bin/env bash
echo -n "$1" > /sys/class/backlight/backlight_warm/brightness
