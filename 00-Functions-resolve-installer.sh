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

install_libs_pre_BM_installer() {
	# dependencies
	sudo apt install ocl-icd-opencl-dev -y
	sudo apt install xorriso -y
	sudo apt install ffmpeg -y
	sudo apt install libfdk-aac1 -y
	sudo apt install gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly  -y
	sudo apt install ubuntu-restricted-extras -y
	sudo apt install libfuse2 -y
	
	
	# libraries
	sudo apt install libapr1 -y
	sudo apt install libaprutil1 -y
	sudo apt install libxcb-cursor0 -y
	sudo apt install libxcb-damage0 -y
	sudo apt install libxcb-composite0 -y #temporarly
	sudo apt install libasound2 -y
	sudo apt install libglib2.0-0 -y
}

install_libs_post_BM_installer() {
	# Workaround for the faulty default libs. Installing newer libs.
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

BM_app_selector() {
	selectedApps=$(zenity --list --checklist --column "Select" --column "Item" \
              TRUE "Fusion" \
              TRUE "Resolve" \
              --separator=":" --title "Installation" --text "Select app(s) to install")
}

loop_through_BMpackages() {
	# Loop through all .run-files in the directory
	for file in "$install_package_folder"/*.run; do
	    if [ -f "$file" ] && [[ "$file" == *$selectedApps* ]]; then
		echo "Installing $file..."
		# Make executable
		chmod +x "$file"
		# Run .run-file
		sudo "$file"
		# Check if run was succesfull
		if [ $? -eq 0 ]; then
		    echo "$file succesfully installed."
		else
		    echo "Error while running $file."
		fi
	    fi
	done

	# Check if there was no file found
	if [ $? -ne 0 ]; then
	    echo "No .run-file containing 'Fusion' found in $install_package_folder"
	fi
}

install_apps() {
	if [[ -n "$selectedApps" ]]; then
	    # Loop through the selected apps and install them
	    IFS=":" read -ra apps <<< "$selectedApps"
	    for app in "${apps[@]}"; do
		case "$app" in
		    "Fusion")
		        # Logic for installing Fusion
		        if [ -d "/opt/BlackmagicDesign/Fusion$version_nr" ]; then
			
				# if Fusion18 folder is present then uninstall old version
				zenity --info --title "Fusion" --text "STEP 01: Uninstall old Fusion\n\n STEP 02: Install new Fusion\n\n"
				
				### REMOVE OLD VERSION ###
				sudo "/opt/BlackmagicDesign/Fusion$version_nr/./FusionInstaller"
				sudo "/opt/BlackmagicDesign/FusionRenderNode$version_nr/./FusionInstaller"
				
				### INSTALL FUSION ###
				loop_through_BMpackages
			else
				# if Fusion18 folder is NOT present then just install fusion
				
				### INSTALL FUSION ###
				loop_through_BMpackages
			fi
		        ;;
		    "Resolve")
			# Logic for installing Resolve
			if [ -d "/opt/resolve" ]; then
				
				# if Fusion18 folder is present then uninstall old version
				zenity --info --title "Resolve" --text "STEP 01: Uninstall old Resolve\n\n STEP 02: Install new Resolve\n\n"
				
				### REMOVE OLD VERSION ###
				sudo /opt/resolve/./installer 
				
				### INSTALL FUSION ###
				loop_through_BMpackages
				
				### Centralized LUTS. Turn on or off by commenting ###
				centralizing_LUTS
			else
				### INSTALL FUSION ###
				loop_through_BMpackages
				
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
	
	if [[ -n "$selectedApps" ]]; then
	    # Loop through the selected apps and download them
	    IFS=":" read -ra apps <<< "$selectedApps"
	    for app in "${apps[@]}"; do
		case "$app" in
		    "Fusion")
		        # downloading Fusion
		        
		        if [ ! -d "Install-app-packages" ]; then
				mkdir "Install-app-packages"
				
				wget $download_url_fusion -O ./$install_package_folder/$tar_gz_file
				
				# unzip file in same directory
				tar -xzvf "./$install_package_folder/$tar_gz_file" -C "$(dirname "./$install_package_folder/$tar_gz_file")"

				# check if unzip is succesfull
				if [ $? -eq 0 ]; then
				    # Verwijder het zip-bestand
				    rm "./$install_package_folder/$tar_gz_file"
				    echo "Unpak succesfull and tar.gz-file deleted."
				else
				    echo "There was an error while unpacking"
				fi

			else
				#wget $download_url_fusion -O ./$install_package_folder/$tar_gz_file
				
				# unzip file in same directory
				tar -xzvf "./$install_package_folder/$tar_gz_file" -C "$(dirname "./$install_package_folder/$tar_gz_file")"

				# check if unzip is succesfull
				if [ $? -eq 0 ]; then
				    # Verwijder het zip-bestand
				    rm "./$install_package_folder/$tar_gz_file"
				    echo "Unpak succesfull and tar.gz deleted."
				else
				    echo "There was an error while unpacking"
				fi
			fi
		        
		        ;;
		    "Resolve")
			# downloading Resolve
			
			if [ ! -d "Install-app-packages" ]; then
				mkdir "Install-app-packages"
				
				wget $download_url_resolve -O ./$install_package_folder/$zip_file
				
				# unzip file in same directory
				unzip "./$install_package_folder/$zip_file" -d "$(dirname "./$install_package_folder/$zip_file")"

				# check if unzip is succesfull
				if [ $? -eq 0 ]; then
				    # Verwijder het zip-bestand
				    rm "./$install_package_folder/$zip_file"
				    echo "Unpak succesfull and zip-file deleted."
				else
				    echo "There was an error while unpacking"
				fi

			else
				wget $download_url_resolve -O ./$install_package_folder/$zip_file
				
				# unzip file in same directory
				unzip "./$install_package_folder/$zip_file" -d "$(dirname "./$install_package_folder/$zip_file")"

				# check if unzip is succesfull
				if [ $? -eq 0 ]; then
				    # Verwijder het zip-bestand
				    rm "./$install_package_folder/$zip_file"
				    echo "Unpak succesfull and zip-file deleted."
				else
				    echo "There was an error while unpacking"
				fi
			fi			
			
		        ;;
		    *)
		        echo "Invalid app: $app"
		        ;;
		esac
	    done

	    zenity --info --title "Download app" --text "\n\n Download completed.\n\n"
	else
	    echo "No apps selected. Downloading terminated."
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

