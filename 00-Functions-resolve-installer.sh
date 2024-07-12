#!/bin/bash

# Import Functions & Variables
source "./00-Variables-resolve-installer.sh"

command_exists () {
	command -v "$1" >/dev/null 2>&1
}

install_curl () {
	# Check if CURL is installed
	if command_exists curl; then
	    echo "curl is already installed."
	else
	    echo "curl is not installed. Installing..."

	    # check which package manager is used
	    if command_exists apt; then
		sudo apt update
		sudo apt install -y curl
	    elif command_exists snap; then
		sudo snap install curl
	    else
		echo "No package manager for this system found. Install curl manualy."
		exit 1
	    fi

	    # Final check if CURL is installed
	    if command_exists curl; then
		echo "curl has successfully been installed."
	    else
		echo "Installation of curl failed"
		exit 1
	    fi
	fi
}

install_libs() {
	sudo apt install libapr1 -y
	sudo apt install libaprutil1 -y
	sudo apt install libxcb-cursor0 -y
	sudo apt install libxcb-damage0 -y
	sudo apt install libasound2 -y
	sudo apt install libglib2.0-0 -y
	sudo cp "./Libs/libgdk_pixbuf-2.0.so.0" "/opt/resolve/libs"
	sudo cp "./Libs/libgdk_pixbuf-2.0.so.0.4200.10" "/opt/resolve/libs"
	
	# Workaround for the faulty default libs. By removing the provided libs, Resolve will automatically use the system libs.
	# But first we make a backup of the default libs
	sudo cp /opt/resolve/libs/libglib-2.0.so /opt/resolve/libs/libglib-2.0.so-BU
	sudo cp /opt/resolve/libs/libglib-2.0.so.0 /opt/resolve/libs/libglib-2.0.so.0-BU
	sudo cp /opt/resolve/libs/libglib-2.0.so.0.6800.4 /opt/resolve/libs/libglib-2.0.so.0.6800.4-BU
		        
	# Then we remove them
	sudo rm /opt/resolve/libs/libglib-2.0.so
	sudo rm /opt/resolve/libs/libglib-2.0.so.0
	sudo rm /opt/resolve/libs/libglib-2.0.so.0.6800.4
	
	#  Now we added the newer libraries
	sudo cp "./Libs/libglib-2.0.so.0" "/opt/resolve/libs"
	sudo cp "./Libs/libglib-2.0.so.0.7800.0" "/opt/resolve/libs"
	
}


centralizing_LUTS() {
	# Centralizing the LUTS folder. This is used in a network setting. 
	# With this enabled you create one central LUTS folder in the network where users can add or remove LUTS.
	# Davinci Resolve then automatically loads these LUTS on start up. 
	sudo chown root:users -R /opt/resolve/LUT/
	sudo chmod 775 -R /opt/resolve/LUT/
				
	sudo ln -s "$resolve_luts_source" "$resolve_luts_destination"

	sudo chown root:users -R "$resolve_transitions_destination"
	sudo chmod 775 -R "$resolve_transitions_destination"
}


install_apps() {
	if [[ -n "$selectedApps" ]]; then
	    # Loop through the selected apps and install them
	    IFS=":" read -ra apps <<< "$selectedApps"
	    for app in "${apps[@]}"; do
		case "$app" in
		    "Fusion")
		        # Logic for installing Fusion
		        if [ -d "/opt/BlackmagicDesign/Fusion18" ]; then
			
				# if Fusion18 folder is present then uninstall old version
				zenity --info --title "Fusion" --text "STEP 01: Uninstall old Fusion\n\n STEP 02: Install new Fusion\n\n"
				
				### REMOVE OLD VERSION ###
				sudo /opt/BlackmagicDesign/Fusion18/./FusionInstaller
				sudo /opt/BlackmagicDesign/FusionRenderNode18/./FusionInstaller
				
				### INSTALL FUSION ###
				sudo ./Install-app-packages/./Fusion.run
				sudo ./Install-app-packages/./Fusion_render.run
			else
				# if Fusion18 folder is NOT present then just install fusion
				
				### INSTALL FUSION ###
				sudo ./Install-app-packages/./Fusion.run
				sudo ./Install-app-packages/./Fusion_render.run
			fi
		        ;;
		    "Resolve")
			# Logic for installing Resolve
			if [ -d "/opt/resolve" ]; then
				
				# if Fusion18 folder is present then uninstall old version
				zenity --info --title "Resolve" --text "STEP 01: Uninstall old Resolve\n\n STEP 02: Install new Resolve\n\n"
				
				### REMOVE OLD VERSION ###
				sudo /opt/resolve/./installer 
				
				### INSTALL RESOLVE ###
				sudo ./Install-app-packages/./Resolve.run
				
				### Centralized LUTS. Turn on or off by commenting ###
				centralizing_LUTS
			else
				### INSTALL RESOLVE ###
				sudo ./Install-app-packages/./Resolve.run
				
				### Centralized LUTS. Turn on or off by commenting ###
				centralizing_LUTS
			fi
		        ;;
		    *)
		        echo "Invalid app: $app"
		        ;;
		esac
	    done

	    zenity --info --title "Installation" --text "\n\n Installation completed.\n\n"
	else
	    echo "No apps selected. Installation terminated."
	fi
}

grab_blackmagic_packages() {
	#zenity --tittle "Save locations" --text "Please enter " --entry
	if [ ! -d "Install-app-packages" ]; then
		mkdir "Install-app-packages"
		wget resolve-install.henkraam.nl -O ./Install-app-packages/Install-app-packages.zip
	else
		wget resolve-install.henkraam.nl -O ./Install-app-packages/Install-app-packages.zip
	fi
	
}

# This pauses the script after running it as a program from nautilus
pause_script_keyboard_feedback() {
	echo "Druk op Enter om af te sluiten."
	read -r
	echo "Het script gaat verder."
}

test_code() {
	sudo cp "./Libs/libgdk_pixbuf-2.0.so.0" "./"
	sudo cp "./Libs/libgdk_pixbuf-2.0.so.0.4200.10" "./"
}
