!macro __JavaUpdate

    StrCmp $JavaVersion "" SkipJavaUpdate
    StrCmp $CurrentJavaVersion "" BeginJavaUpdate
    StrCmp $JavaVersion $CurrentJavaVersion 0 BeginJavaUpdate

    ${DetailPrint} "The installed Java version is still up-to-date."
    ${DetailPrint} "Java update was skipped."
    Goto SkipJavaUpdate
  
    ;-------------------
  
    BeginJavaUpdate:
  
    ${DetailPrint} "Downloading Java version $JavaVersion, please wait..."
    
    StrCmp $Hidden "0" ShowJavaProgress
    
    ${Download} "silent" "Java version $JavaVersion" "$JavaURL" "$PLUGINSDIR\${JavaZIP}" "true"
    
    Pop $R0
    StrCmp $R0 "OK" ExtractJava
    ${DetailPrint} "Unable to download Java at this time, will retry later."
    Goto SkipJavaUpdate
    
    ShowJavaProgress:
    
    ${Download} "banner" "Java version $JavaVersion" "$JavaURL" "$PLUGINSDIR\${JavaZIP}" "true"
    
    Pop $R0
    StrCmp $R0 "OK" ExtractJava
    StrCmp $R0 "Cancelled" CancelledJavaDownload    
    
    MessageBox MB_RETRYCANCEL|MB_ICONSTOP|MB_TOPMOST "Download failed: $R0$\nPlease check your internet connection and try again!" IDRETRY ShowJavaProgress
    StrCpy $Errors "$Errors$\n$\tJAVA Update Error: $R0 Please check your internet connection and try again!"
    Goto SkipJavaUpdate
  
    CancelledJavaDownload:
    MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "Download was aborted by user!"
    Goto SkipJavaUpdate
    
    ExtractJava:
    
    ${DetailPrint} "Extracting files, please wait..."

    CreateDirectory "$PLUGINSDIR\JRE"
        
    !insertmacro ZIPDLL_EXTRACT "$PLUGINSDIR\${JavaZIP}" "$PLUGINSDIR\JRE" "<ALL>"
    Pop $0
    
    StrCmp $0 "success" SuccessfullyExtractedJava 0
    ${DetailPrint} "An error has occured while extracting the files ($0)"
    StrCpy $Errors "$Errors$\n$\tJAVA Update Error: An error has occured while extracting the files ($0)"
    RMDir /r "$PLUGINSDIR\JRE" 
    
    StrCmp $Hidden "1" SkipJavaUpdate
    
    MessageBox MB_RETRYCANCEL|MB_ICONSTOP|MB_TOPMOST "Extraction failed: $0$\nPlease check your user permissions and try again." IDRETRY ExtractJava
    Goto SkipJavaUpdate
  
    SuccessfullyExtractedJava:
    Delete "$PLUGINSDIR\${JavaZIP}"
    
    ;-------------------

    IfFileExists "$PLUGINSDIR\JRE\bin\javaw.exe" 0 MissingJavaFile
    Goto AllJavaFilesThere
  
    MissingJavaFile:
    ${DetailPrint} "Error: At least one required file is missing in the update!"
    StrCpy $Errors "$Errors$\n$\tJAVA Update Error: At least one required file is missing in the update!"
    RMDir /r "$PLUGINSDIR\JRE"
    
    Goto SkipJavaUpdate
  
    AllJavaFilesThere: 
    
    StrCpy $UpgradeNeeded "yes"
    
    ;StrCpy $FlashVersion $Revision
    
    SkipJavaUpdate:
    
!macroend

!macro __JavaInstall

    StrCmp $JavaVersion "" SkipJavaInstall
    StrCmp $JavaVersion $CurrentJavaVersion SkipJavaInstall
    
    ${DetailPrint} "Installing Java, please wait..."
    
    CreateDirectory "$INSTDIR\JRE"
    CopyFiles /SILENT "$PLUGINSDIR\JRE\*.*" "$INSTDIR\JRE"
    IfErrors 0 JavaCopySuccessful
    ${DetailPrint} "Failed to copy Java files to the install folder!" 
    RMDir /r "$PLUGINSDIR\JRE"
        
    StrCmp $Hidden "1" SkipJavaInstall   
    
    JavaCopySuccessful:
    
    RMDir /r "$PLUGINSDIR\JRE"
  
    ;-------------------

    ${DetailPrint} "Saving Java version information, please wait..."

    ClearErrors
    FileOpen $0 "$INSTDIR\java.ver" w
    IfErrors SkipWriteJavaVersion
    FileWrite $0 $JavaVersion
    FileClose $0
 
    SkipWriteJavaVersion:
    SkipJavaInstall:

!macroend

!macro __LaunchJavaApp AppPath

    ${DetailPrint} "Launching ${AppPath}"
    
    Exec '$INSTDIR\JRE\bin\javaw.exe -jar "${AppPath}"'

!macroend

!define JavaUpdate "!insertmacro __JavaUpdate"
!define JavaInstall "!insertmacro __JavaInstall"
!define LaunchJavaApp "!insertmacro __LaunchJavaApp"
