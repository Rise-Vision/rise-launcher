# Rise Launcher

## Introduction

Player launcher will check for component updates (Rise Cache, Rise Player, Chrome, Java, etc) and launch Rise Cache and Rise Player.

Expected versions are stored in versions-config/remote-components-[os-arch].cfg
These version files are stored in a public Google Cloud Storage bucket at install-versions.risevision.com

Rise Player and Rise Cache work in conjunction with [Rise Vision](http://www.risevision.com), the [digital signage management application](http://rva.risevision.com/) that runs on [Google Cloud](https://cloud.google.com).


At this time Chrome is the only browser that this project and Rise Vision supports.

Built With

 - Java 1.7
 - [NSIS 2.46](http://nsis.sourceforge.net/Download.)
 - [Eclipse](http://www.eclipse.org/downloads/)
 
## Development

### Local Development Environment Setup and Installation

#### Installer

To build windows-installer, open the NSIS script compiler then open the file setup.nsi from the player-native repository.

Windows Installer can be built by compiling "setup.nsi" in NSIS.

1. Select Compile NSI scripts. That will launch MakeNSISW
2. Select File menu
3. Load the script setup.nsi from within the player-native repo
4. Once complete, a RiseVisionPlayer.exe will be generated

For Linux, the installer is a shell script. To edit, open linux-installer.sh file with any text editor.

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
