!macro __RisePlayerUpdate

    StrCmp $RisePlayerVersion "" SkipRisePlayerUpdate
    StrCmp $CurrentRisePlayerVersion "" BeginRisePlayerUpdate
    StrCmp $RisePlayerVersion $CurrentRisePlayerVersion 0 BeginRisePlayerUpdate

    ${DetailPrint} "The installed RisePlayer version is still up-to-date."
    ${DetailPrint} "RisePlayer update was skipped."
    Goto SkipRisePlayerUpdate
  
    ;-------------------
  
    BeginRisePlayerUpdate:
  
    ${DetailPrint} "Downloading RisePlayer version $RisePlayerVersion, please wait..."
    
    StrCmp $Hidden "0" ShowRisePlayerProgress
    
    ${Download} "silent" "RisePlayer (jar) version $RisePlayerVersion" "$RisePlayerURL" "$PLUGINSDIR\${RisePlayerZIP}" "true"
    
    Pop $R0
    StrCmp $R0 "OK" ExtractRisePlayer
    ${DetailPrint} "Unable to download RisePlayer at this time, will retry later."
    Goto SkipRisePlayerUpdate
    
    ShowRisePlayerProgress:
    
    ${Download} "banner" "RisePlayer version $RisePlayerVersion" "$RisePlayerURL" "$PLUGINSDIR\${RisePlayerZIP}" "true"
    
    Pop $R0
    StrCmp $R0 "OK" ExtractRisePlayer
    StrCmp $R0 "Cancelled" CancelledRisePlayerDownload
    
    MessageBox MB_RETRYCANCEL|MB_ICONSTOP|MB_TOPMOST "Download failed: $R0$\nPlease check your internet connection and try again!" IDRETRY ShowRisePlayerProgress
    Goto SkipRisePlayerUpdate
  
    CancelledRisePlayerDownload:
    MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "Download was aborted by user!"
    Goto SkipRisePlayerUpdate
    
    ExtractRisePlayer:
    
    ${DetailPrint} "Extracting files, please wait..."

    CreateDirectory "$PLUGINSDIR\RisePlayer"
    
    !insertmacro ZIPDLL_EXTRACT "$PLUGINSDIR\${RisePlayerZIP}" "$PLUGINSDIR\RisePlayer" "<ALL>"
    Pop $0
    
    StrCmp $0 "success" SuccessfullyExtractedRisePlayer 0
    ${DetailPrint} "An error has occured while extracting the files ($0)"
    RMDir /r "$PLUGINSDIR\RisePlayer" 
    
    StrCmp $Hidden "1" SkipRisePlayerUpdate
    
    MessageBox MB_RETRYCANCEL|MB_ICONSTOP|MB_TOPMOST "Extraction failed: $0$\nPlease check your user permissions and try again." IDRETRY ExtractRisePlayer
    Goto SkipRisePlayerUpdate
  
    SuccessfullyExtractedRisePlayer:
    Delete "$PLUGINSDIR\${RisePlayerZIP}"
    
    ;-------------------

    IfFileExists "$PLUGINSDIR\RisePlayer\RisePlayer.jar" 0 MissingRisePlayerFile
    Goto AllRisePlayerFilesThere
  
    MissingRisePlayerFile:
    ${DetailPrint} "Error: At least one required file is missing in the update!"
    RMDir /r "$PLUGINSDIR\RisePlayer"
    
    Goto SkipRisePlayerUpdate
  
    AllRisePlayerFilesThere: 
    
    StrCpy $UpgradeNeeded "yes"
    
    ;StrCpy $FlashVersion $Revision
    
    SkipRisePlayerUpdate:
    
!macroend

!macro __RisePlayerInstall

    StrCmp $RisePlayerVersion "" SkipRisePlayerInstall
    StrCmp $RisePlayerVersion $CurrentRisePlayerVersion SkipRisePlayerInstall
    
    ${DetailPrint} "Installing RisePlayer, please wait..."
    
    CopyFiles /SILENT "$PLUGINSDIR\RisePlayer\*.*" "$INSTDIR"
    IfErrors 0 RisePlayerCopySuccessful
    ${DetailPrint} "Failed to copy RisePlayer files to the install folder!" 
    RMDir /r "$PLUGINSDIR\RisePlayer"
        
    StrCmp $Hidden "1" SkipRisePlayerInstall
    
    RisePlayerCopySuccessful:
    
    RMDir /r "$PLUGINSDIR\RisePlayer"
  
    ;-------------------

    ${DetailPrint} "Saving RisePlayer version information, please wait..."

    ClearErrors
    FileOpen $0 "$INSTDIR\RisePlayer.ver" w
    IfErrors SkipWriteRisePlayerVersion
    FileWrite $0 $RisePlayerVersion
    FileClose $0
 
    SkipWriteRisePlayerVersion:
    SkipRisePlayerInstall:

!macroend

!define RisePlayerUpdate "!insertmacro __RisePlayerUpdate"
!define RisePlayerInstall "!insertmacro __RisePlayerInstall"