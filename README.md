# Install script for Davinci Resolve and Fusion for Ubuntu

We, as an animation studio (storytailors.nl), work entirely on Ubuntu Linux. 
We love the desktop experience and the open nature of the open source community. 
Therefore, we share our code and methods with others who also want to use Linux for business purposes.

This code installs Blackmagic Resolve, Fusion, and the Fusion network renderer on Ubuntu.

# Install
1. Download
2. Unpack
3. Run "Install.sh"
    - It grabs first the Blackmagic install packages for both Resolve and Fusion as a zipfile.
    - Then it creates a folder "Install-app-packages" and unzips the file
    - Then the install asks you which Blackmagic app to install
    - Then it installs dependencies like libraries before the Blackmagic package
    - Now the app(s) are being installed
    - Finally last libraries are installed after the Blackmagic package 

# Tested versions
Resolve          : Studio 18.6.4
Fusion           : Studio 18.6.4
Fusion Renderer  : Studio 18.6.4

Ubuntu           : 23.04, 23.10 

