#!/bin/bash


# Import Functions & Variables
source "./00-Functions-resolve-installer.sh"

# Check app if installed
# ARGUMENTS: "app name" apt name
check_app_if_installed "python3-venv"

pause_script_keyboard_feedback

if [ ! -d "venv" ]; then
    echo -e "\nCreating virtual environment...\n"
    python3 -m venv venv
    echo -e "\nVirtual environment created.\n"
fi

source venv/bin/activate
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "Virtual environment activated."
else
    echo "Failed to activate virtual environment."
    exit 1
fi

if ! python -c "import selenium" &> /dev/null; then
    python3 -m pip install selenium
else
    echo -e "\nSelenium is already installed.\n"
fi



pause_script_keyboard_feedback

### general variables ###
#resolve_luts
#resolve_transitions
#fusion_scripting

# Asks the user to select the app to install
#BM_app_selector

#find_download_link
python python.py

# Getting Resolve and Fusion install packages
#grab_blackmagic_packages
              
# Installs depending libraries and apps before running the Resolve and/or Fusion packages
#install_libs_pre_BM_installer

# Install the apps Resolve and/or Fusion
#install_apps

# Installs depending libraries after running the Resolve and/or Fusion packages
#install_libs_post_BM_installer

#test_code

pause_script_keyboard_feedback
