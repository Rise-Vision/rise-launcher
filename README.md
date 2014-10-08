# player-native

## Introduction

player-native is a set of Java Apps, responsible for launching Viewer in Chrome, to display HTML content from Rise Vision - our digital signage management application.

player-native repository consists of components to run the presentation on Windows and Linux.

- Winows_installer NSIS scripts to configure, launch and auto-update the components on Windows 
- Linux-Installer shell script to configure, launch and auto-update the components on Windows
- Cache Java App for maintaining local cache for video files
- Player Java App responsible for launching [Viewer](https://github.com/Rise-Vision/viewer) in Chrome.

player works in conjunction with [Rise Vision](http://www.risevision.com), the [digital signage management application](http://rva.risevision.com/) that runs on [Google Cloud](https://cloud.google.com).

At this time Chrome is the only browser that this project and Rise Vision supports.

## Built With
- *Java 1.7*
- *[NSIS 2.46](http://nsis.sourceforge.net/Download.)*
- Eclipse
- *Shell script*

## Development 

### Local Development Environment Setup and Installation
The Java projects RiseCache in /rise-cache and RisePlayer in /player folders in repository can be build using eclipse.

You will need to export these to Runnable jar file

- *RisePlayer to RisePlayer.jar and*
- *RiseCache to RiseCache.jar*

To build windows-installer, you will need NSIS 2.46 on your machine, [NSIS 2.46](http://nsis.sourceforge.net/Download). Once installed, open the NSIS script compiler and open the file setup.nsi from the repository.

Windows Installer  can be build by compiling "setup.nsi" in NSIS. 

### Run Local on Linux
player can run locally on Ubuntu. It can be installed by running command "sudo rvplayer-installerraspbian.sh" in terminal window. The script will download the required components from server, configure the machine and launch the Chrome browser.

### Run Local on Windows
player can run locally on Windows. First Installer need to be created by compiling "windows-installer\setup.nsi" using NSIS and then execute the generated installer exe file. The Installer will download the required components from server, configure the machine and launch the Chrome browser.

When installation has completed, the Java App’s, RisePlayer.jar and RiseCahce.jar, are launched. 

RisePlayer.jar is responsible for launching Chrome. In addition, RisePlayer.jar will run a local server on port 9449 that is used for communication with Viewer.

RiseCache.jar will run a local server on port 9494 and serves as a proxy for downloading and serving videos requested by the Video Widget running in viewer.

Upon startup, the Rise Vision Player will require either a Display ID or Claim ID to connect your Display to the Platform. From the [Rise Vision Platform](http://rva.risevision.com) click on Displays, then Add Display give it a name and click save. Copy the Display ID and enter it in the Rise Vision Player on startup.

One can change the display id, or shift between test and production platform by editing the "RiseDisplayNetworkII.ini" in application folder.


####Components:

- *Installer*
- *RisePlayer*
- *RiseCache*
- *Chromium*

####Important configuration steps for testing/running on your Windows/Linux machine

Installer upon launch connects to CORE server and request for components version numbers, if component is missing on local machine or version number is different, the particular component is downloaded.

For your testing its recommended that the version of your updated component should match with the version number set on the Core server otherwise Installer script will replace your copy with the version set on the server.

The Core server URL is coded in the Installer, you can update the CORE_URL variable in script to connect to test "https://rvacore-test.appspot.com" or production "https://rvaserver2.appspot.com" or local Core server.

Similary update the SHOW_URL to connect to test "http://viewer-test.appspot.com" or production "http://rvashow.appspot.com" Viewer server

Installer uses following URL to check for current component version numbers $CORE_URL/v2/player/components?os=rsp

    Windows Url: 
    https://rvacore-test.appspot.com/v2/player/components?os=win
    
    Linux Url: 
    https://rvacore-test.appspot.com/v2/player/components?os=lnx
    
    Linux 64 Url: 
    https://rvacore-test.appspot.com/v2/player/components?os=lnx64
     
    Windows url Returns:
    PlayerVersion=2.0.035
    PlayerURL=http://commondatastorage.googleapis.com/rise-player%2FRisePlayer-2.0.035.zip
    InstallerVersion=2.2.00037-test
    InstallerURL=https://rvacore-test.appspot.com/player/download?os=win
    BrowserVersion=24.0.1312.56
    BrowserURL=http://commondatastorage.googleapis.com/chrome-windows%2Fchrome-win32-24.0.1312.56.zip
    CacheVersion=1.0.008
    CacheURL=http://commondatastorage.googleapis.com/risecache/RiseCache-1.0.008.zip
    JavaVersion=7.9
    JavaURL=http://commondatastorage.googleapis.com/javazipfile/jre-7.9-32bit.zip

On Windows, if you are making changes to Installer files, copy the generated "RiseVisionPlayer.exe" to application folder i.e., "RVPlayer" folder under "%LOCALAPPDATA%".

On Linux, If you are making changes to installer script, copy the updated script to file rvplayer in application folder i.e., /root/rvplayer and make sure script rvplayer has execute permissions and the installer version number set in variable VERSION match the InstallerVersion set on CORE Server

If you are making changes to RisePlayer.jar, copy the updated jar file to application folder and the RisePlayer version number set in java application should match the PlayerVersion set on CORE server

If you are making changes to RiseCache.jar, copy the updated jar file to application folder and the RiseCache version number set in java application should match the CacheVersion set on CORE Server

#####application folder contain following:

- *chrome-linux directory - On Linux Chromium binaries downloaded by Installer*
- *chromium  directory - on Windows Chromium binaries downloaded by Installer*
- *JRE directory - On Windows only - Java binaries*
- *RiseCache directory - Contains RiseCache.jar and downloaded video files*
- *RisePlayer.jar*
- *rvplayer - On Linux only - Installer script*
- *RiseVisionPlayer.exe - On Windows only - Installer*
- *chromium.log - Chrmium std err output*
- *RisePlayer.log - RisePlayer log*
- *RiseDisplayNetworkII.ini - Configuration file, created by Installer and updated by RisePlayer, contains Core Server URL, Display ID...*
- *installer.ver - contain Installer vesion number*
- *RisePlayer.ver - contain RisePlayer vesion number*
- *chromium.ver - contain Chromium vesion number*
- *RiseCache.ver - contain RiseCache vesion number*

### Dependencies

All dependencies like Chromium and Java are downloaded and installed by the installer.

## Submitting Issues 
If you encounter problems or find defects we really want to hear about them. If you could take the time to add them as issues to this Repository it would be most appreciated. When reporting issues please use the following format where applicable:

**Reproduction Steps**

1. did this
2. then that
3. followed by this (screenshots / video captures always help)

**Expected Results**

What you expected to happen.

**Actual Results**

What actually happened. (screenshots / video captures always help)

## Contributing
All contributions are greatly appreciated and welcome! If you would first like to sound out your contribution ideas please post your thoughts to our [community](http://community.risevision.com), otherwise submit a pull request and we will do our best to incorporate it


## Resources
If you have any questions or problems please don't hesitate to join our lively and responsive community at http://community.risevision.com.

If you are looking for user documentation on Rise Vision please see http://www.risevision.com/help/users/

If you would like more information on developing applications for Rise Vision please visit http://www.risevision.com/help/developers/. 

**Facilitator**

[Alan Clayton](https://github.com/alanclayton "Alan Clayton")
