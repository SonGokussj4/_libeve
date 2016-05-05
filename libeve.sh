#!/usr/bin/env bash

# Name: libeve
# Author: Tomas Knot (tknot@evektor.cz) /co-op: Jan Verner (jverner@evektor.cz)
# Created: 12.04.2016
# Last Updated: 02.05.2016
#
# Description:
# This script contains common function for shell scripts used in Evektor
#


#==================
# COLORS are MAGIC!
#==================
colors="true"  # default: true | opt: false ... output messages in colors
if [[ $colors == "true" ]]; then
    Btext='\033[1m'     # Bold
    BBlack='\e[1;30m'   # Black
    NC='\e[m'           # Color Reset
else
    Btext=''
    BBlack=''
    NC=''
fi


function getUserIdentity () {
    # Will get user(name, e-mail) and git(name, e-mail)

    user_email="$(id -un)@evektor.cz"
    git_email="$(git config --list | grep user.email | cut -d "=" -f 2)"
    user_name="$(getent passwd $(id -un) | \
              awk 'BEGIN {FS=":"}{print $5}' | iconv -f utf8 -t ascii//TRANSLIT)"
    git_name="$(git config --list | grep user.name | cut -d "=" -f 2)"
}


function checkOtherOptions () {
    # Check other options described in this function

    push_settings=$(git config --list | grep "push.default=simple" || echo "false")
    color_ui=$(git config --list | grep "color.ui=true" || echo "false")
}


function checkIdentity () {
    # Checks if user has a wrong default (git) form of e-mail and user name.
    # If yes, git config is automatically configured to:
    # E-mail: whoami@evektor.cz | User-name: in form LASTname FIRSTname

    # Initial variables
    identity_change=false

    # Variable for optional "no echo" report
    opt_no_verbal=${1:-unset}

    echo "Checking your GIT identity..."
    getUserIdentity
    checkOtherOptions

    # Git name should be in form: Surname Name
    if [[ "$user_name" != "${git_name[@]}" ]]; then
        echo
        echo -e "${Btext}USER-NAME...${NC}"
        echo -e "Your user name has a default git form: ${Btext}$git_name${NC}"
        echo -e "Modifying git config to a new user name..."
        git config --global user.name "$user_name"
        echo -e "→ ${Btext}$user_name${NC} has been set as new user name"
        identity_change=true
    elif [[ "$opt_no_verbal" == true ]]; then
        :
    else
        echo
        echo -e "${Btext}USER-NAME... OK${NC}"
    fi

    # Git e-mail should be in form: username@evektor.cz
    if [[ "$user_email" != "$git_email" ]]; then
        echo
        echo -e "${Btext}E-MAIL...${NC}"
        echo -e "Your e-mail has a default git form: ${Btext}$git_email${NC}"
        echo -e "Modifying git config to a new e-mail..."
        git config --global user.email "$user_email"
        echo -e "New e-mail has been set ${Btext}$user_email${NC}"
        identity_change=true
    elif [[ "$opt_no_verbal" == true ]]; then
        :
    else
        echo
        echo -e "${Btext}E-MAIL... OK${NC}"
    fi

    # Set git push.default setting
    if [[ "$push_settings" == "false" ]]; then
        git config --global push.default simple
        echo -e "\nGit ${Btext}push.default${NC} setting was set to: ${Btext}simple${NC}"
    fi

    # Set git color.ui setting
    if [[ "$color_ui" == "false" ]]; then
        git config --global color.ui true
        echo -e "\n${Btext}Git color.ui${NC} setting was set to: ${Btext}true${NC}"
    fi

    # If no change was made - proceed, if any change - write new user Name/E-mail
    if [[ "$opt_no_verbal" == true && "$identity_change" == false ]]; then
        echo -e "${Btext}Git identity check... OK${NC}"
        echo
    else
        echo
        getUserIdentity
        echo -e "Your ${Btext}git identity${NC} is fine:"
        echo -e " - User Name: ${Btext}$git_name${NC}"
        echo -e " - User E-mail: ${Btext}$git_email${NC}"
    fi
}
