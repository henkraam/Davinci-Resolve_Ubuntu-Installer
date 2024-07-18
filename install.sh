#!/bin/bash


# Import Functions & Variables
source "./00-Functions-resolve-installer.sh"

### general variables ###
#resolve_luts
#resolve_transitions
#fusion_scripting

# Asks the user to select the app to install
BM_app_selector

# Getting Resolve and Fusion install packages
#grab_blackmagic_packages
              
# Installs depending libraries and apps before running the Resolve and/or Fusion packages
install_libs_pre_BM_installer

# Install the apps Resolve and/or Fusion
install_apps

# Installs depending libraries after running the Resolve and/or Fusion packages
install_libs_post_BM_installer

#test_code

pause_script_keyboard_feedback
