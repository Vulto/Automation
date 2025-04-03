#!/bin/bash

RED="\[\033[01;31m\]"
GREEN="\[\033[01;32m\]"
CLEAR="\[\033[00m\]"

PS1="[[ $UID = 1000 ]] && PS1="\n $GREEN \h $CLEAR \w  \n      → " || PS1="\n \e[1;31m # [ \w ] \e[m \n    "
