#!/bin/bash

install_libs() {
	sudo apt install libapr1 -y
	sudo apt install libaprutil1 -y
	sudo apt install libxcb-cursor0 -y
	sudo apt install libxcb-damage0 -y
	sudo apt install libasound2 -y
	sudo apt install libglib2.0-0 -y
}

install_logic_apps() {
	if [[ -n "$selectedApps" ]]; then
	    # Loop through the selected apps and install them
	    IFS=":" read -ra apps <<< "$selectedApps"
	    for app in "${apps[@]}"; do
		case "$app" in
		    "Fusion")
		        # Logic for installing Fusion
		        zenity --info --title "Fusion" --text "STAP 01: Uninstall old Fusion\n\n STAP 02: Install new Fusion\n\n"
		        
		        ### REMOVE OLD VERSION ###
		        sudo /opt/BlackmagicDesign/Fusion18/./FusionInstaller
		        sudo /opt/BlackmagicDesign/FusionRenderNode18/./FusionInstaller
		        
		        ### INSTALL FUSION ###
		        sudo ./Install-app-packages/./Fusion.run
		        sudo ./Install-app-packages/./Fusion_render.run
		        
		        ### CHANGE OWNERSHIP ###
		        sudo chown root:users -R /var/BlackmagicDesign/Fusion/Scripts/
		        sudo chmod 775 -R /var/BlackmagicDesign/Fusion/Scripts/
		        
		        #sudo ln -s "$fusion_scripting_source" "$fusion_scripting_destination"
		        ;;
		    "Resolve")
		        # Logic for installing Resolve
		        zenity --info --title "Resolve" --text "STAP 01: Uninstall old Resolve\n\n STAP 02: Install new Resolve\n\n"
		        
		        ### REMOVE OLD VERSION ###
		        sudo /opt/resolve/./installer 
		        
		        ### INSTALL RESOLVE ###
		        sudo ./Install-app-packages/./Resolve.run
		        
		        ### CHANGE OWNERSHIP ###
		        sudo chown root:users -R /opt/resolve/LUT/
		        sudo chmod 775 -R /opt/resolve/LUT/
		        
		        sudo ln -s "$resolve_luts_source" "$resolve_luts_destination"
		        
		        sudo chown root:users -R "$resolve_transitions_destination"
			sudo chmod 775 -R "$resolve_transitions_destination"
		        
		        # Workaround for the faulty default libs. By removing the provided libs, Resolve will automatically use the system libs.
		        # But first we make a backup of the default libs
		        sudo cp /opt/resolve/libs/libglib-2.0.so /opt/resolve/libs/libglib-2.0.so-BU
		        sudo cp /opt/resolve/libs/libglib-2.0.so.0 /opt/resolve/libs/libglib-2.0.so.0-BU
		        sudo cp /opt/resolve/libs/libglib-2.0.so.0.6800.4 /opt/resolve/libs/libglib-2.0.so.0.6800.4-BU
		        
		        # The we remove them
		        sudo rm /opt/resolve/libs/libglib-2.0.so
		        sudo rm /opt/resolve/libs/libglib-2.0.so.0
		        sudo rm /opt/resolve/libs/libglib-2.0.so.0.6800.4
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
