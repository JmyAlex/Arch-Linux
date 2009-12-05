#!/bin/bash
setxkbmap  -layout "us,ru,ua" -option "grp:ctrl_shift_toggle,grp_led:scroll" &
feh --bg-scale ~/Downloads/archlinux-simplyblack.png &
xsetroot -cursor_name left_ptr -solid '#090909' &
exec xmonad
dmenu &