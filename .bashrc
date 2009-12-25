#export PS1='\[\e[1;31m\][\u@\e[1;33m\h \e[1;34m\W\e[1;31m]\$\[\e[0m\] '
export GREP_COLOR="1;33"
alias grep='grep --color=auto'
alias ls='ls --color=auto'
eval `dircolors -b`
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;44;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'


txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
badgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0m'    # Text Reset


# Colour Codes
export Cyan="\[\e[m\]\[\e[0;36m\]"
export Red="\[\e[m\]\[\e[0;31m\]"
export White="\[\e[m\]\[\e[0;37m\]"
export LightCyan="\[\e[m\]\[\e[0;36m\]"
export LightRed="\[\e[m\]\[\e[0;31m\]"

# Code for a cool Prompt
function pre_prompt
{
    newPWD="${PWD}"
    user="whoami"
    host=$(echo -n $HOSTNAME | sed -e "s/[\.].*//")
    datenow=$(date "+%a, %d %b %y")
    let promptsize=$(echo -n "--($user@$host ddd, DD mmm YY)---(${PWD})---" \
                 | wc -c | tr -d " ")

    width=$(tput cols)

    if [ `id -u` -eq 0 ]
    then
        let fillsize=${width}-${promptsize}+1
    else
        let fillsize=${width}-${promptsize}-1
    fi

    fill=""

    while [ "$fillsize" -gt "0" ]
    do
        fill="${fill}─"
        let fillsize=${fillsize}-1
    done

    if [ "$fillsize" -lt "0" ]
    then
        let cutt=3-${fillsize}
        newPWD="...$(echo -n $PWD | sed -e "s/\(^.\{$cutt\}\)\(.*\)/\2/")"
    fi
}

# Set prompt colour
if [ `id -u` -eq 0 ]
then
    cText="${LightRed}"
    cBorder="${Red}"
else
    cText="${LightCyan}"
    cBorder="${Cyan}"
fi

PROMPT_COMMAND=pre_prompt

# Display Prompt
PS1="${cBorder}┌─(${White}\u@\h \$(date \"+%a, %d %b %y\")${cBorder})─\${fill}─(${cText}\$newPWD\
${cBorder})────┐\n${cBorder}└─(${cText}\$(date \"+%H:%M\")${cBorder})─> ${White}"


