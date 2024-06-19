#!/bin/bash


# Import Functions & Variables
source "./00-Functions-resolve-installer.sh"

### general variables ###
resolve_luts
resolve_transitions
fusion_scripting

#  check is curl is installed. If not install
install_curl

# Ask the user to select the app to install
selectedApps=$(zenity --list --checklist --column "Select" --column "Item" \
              TRUE "Fusion" \
              TRUE "Resolve" \
              --separator=":" --title "Installatie" --text "Welke wil je installeren?")

              
# INSTALL libraries
install_libs

# Install logic for the apps Resolve and/or Fusion
install_apps

#test_code
