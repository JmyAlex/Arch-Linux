#!/bin/bash
setxkbmap  -layout "us,ru,ua" -option "grp:ctrl_shift_toggle,grp_led:scroll"
xsetroot -cursor_name left_ptr -solid '#090909' &
feh --bg-scale ~/Downloads/arch88e.jpg &
trayer --edge bottom --align right --expand true --SetDockType true --SetPartialStrut true --tint 0x303030 --alpha 0 --transparent true --height 16 --width 5 --margin 0 &
nm-applet &
exec xmonad
#exec gnome-session
#exec dwm
#exec awesome
#while true
#do
#echo `date``uptime|sed's/.*://;s/,//g'`
#sleep1
#done|dwm
#tint2 &
#launchy &
dmenu &
#exec openbox-session
#xcompmgr &
#xset -b b off
#xrdb -load $HOME/.Xdefaults
#xmodmap -e "keysym Super_R = SunCompose"
#xsetroot -cursor_name left_ptr
#nitrogen --restore
#fbsetbg -b -solid "#0f0f0f"
#nvidia-settings -a GlyphCache=1
#nvidia-settings -a InitialPixmapPlacement=2
#export MPD_HOST=localhost
#export MPD_PORT=6600
#export OOO_FORCE_DESKTOP=gnome
#exec xmonad
#xmobar &
#exec xmonad > ~/.xmonad/pipe





# Start URxvt daemon so we can quickly open the other clients
#urxvtd -q -o -f
#[[ -x "/usr/bin/numlockx" ]] && numlockx &
#[[ -x "/usr/bin/unclutter" -a -z "`pidof unclutter`" ]] && \
#    unclutter -idle 5 -root&
 
# Set Wallpaper with feh
#eval `cat ~/.fehbg` &
 
# Set mouse cursor and background colour
#xsetroot -cursor_name left_ptr -solid '#090909' &
 
# Launch tray and statusbar
#stalonetray -i 16 --max-width 48 --icon-gravity E --geometry 48x16-0+0 -bg '#2e3436' --sticky --skip-taskbar &
#~/.bin/dzen.sh | dzen2 -e 'onstart=lower' -p -ta r -fn '-*-terminus-medium-*-*-*-12-*-*-*-*-*-iso8859-1' -bg '#2e3436' -fg '#babdb6' -h 16 -w 1632 &
 
# Launch WM
#exec xmonad
