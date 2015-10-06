!macro __RiseCacheUpdate

    StrCmp $RiseCacheVersion "" FailedRiseCacheUpdate
    StrCmp $CurrentRiseCacheVersion "" BeginRiseCacheUpdate
    StrCmp $RiseCacheVersion $CurrentRiseCacheVersion 0 BeginRiseCacheUpdate

    ${DetailPrint} "The installed RiseCache version is still up-to-date."
    ${DetailPrint} "RiseCache update was skipped."
    Goto ExitRiseCacheUpdate
  
    ;-------------------
  
    BeginRiseCacheUpdate:
  
    ${DetailPrint} "Downloading RiseCache version $RiseCacheVersion, please wait..."
    
    StrCmp $Hidden "0" ShowRiseCacheProgress
    
    ${Download} "silent" "RiseCache version $RiseCacheVersion" "$RiseCacheURL" "$PLUGINSDIR\${RiseCacheZIP}" "true"
    
    Pop $R0
    StrCmp $R0 "OK" ExtractRiseCache
    StrCpy $Errors "$Errors$\n$\tRise Cache update Error: $R0 Please check your internet connection and try again!"
    Goto FailedRiseCacheUpdate
    
    ShowRiseCacheProgress:
    
    ${Download} "banner" "RiseCache version $RiseCacheVersion" "$RiseCacheURL" "$PLUGINSDIR\${RiseCacheZIP}" "true"
    
    Pop $R0
    StrCmp $R0 "OK" ExtractRiseCache
    StrCmp $R0 "Cancelled" CancelledRiseCacheDownload
    
    MessageBox MB_RETRYCANCEL|MB_ICONSTOP|MB_TOPMOST "Download failed: $R0$\nPlease check your internet connection and try again!" IDRETRY ShowRiseCacheProgress
    StrCpy $Errors "$Errors$\n$\tRise Cache update Error: $R0 Please check your internet connection and try again!"
    Goto FailedRiseCacheUpdate
  
    CancelledRiseCacheDownload:
    MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "Download was aborted by user!"
    StrCpy $Errors "$Errors$\n$\tRise Cache Update Error: Download was aborted by user!"
    Goto FailedRiseCacheUpdate
    
    ExtractRiseCache:
    
    ${DetailPrint} "Extracting files, please wait..."

    CreateDirectory "$PLUGINSDIR\RiseCache"
        
    !insertmacro ZIPDLL_EXTRACT "$PLUGINSDIR\${RiseCacheZIP}" "$PLUGINSDIR\RiseCache" "<ALL>"
    Pop $0
    
    StrCmp $0 "success" SuccessfullyExtractedRiseCache 0
    ${DetailPrint} "An error has occured while extracting the files ($0)"
    StrCpy $Errors "$Errors$\n$\tRise Cache Update Error: An error has occured while extracting the files ($0)"
    RMDir /r "$PLUGINSDIR\RiseCache" 
    
    StrCmp $Hidden "1" FailedRiseCacheUpdate
    
    MessageBox MB_RETRYCANCEL|MB_ICONSTOP|MB_TOPMOST "Extraction failed: $0$\nPlease check your user permissions and try again." IDRETRY ExtractRiseCache
    StrCpy $Errors "$Errors$\n$\tRise Cache Update Error: $0$\nPlease check your user permissions and try again."
    Goto FailedRiseCacheUpdate
  
    SuccessfullyExtractedRiseCache:
    Delete "$PLUGINSDIR\${RiseCacheZIP}"
    
    ;-------------------

    IfFileExists "$PLUGINSDIR\RiseCache\RiseCache.jar" 0 MissingRiseCacheFile
    Goto AllRiseCacheFilesThere
  
    MissingRiseCacheFile:
    ${DetailPrint} "Error: At least one required file is missing in the update!"
    StrCpy $Errors "$Errors$\n$\tRise Cache Update Error: At least one required file is missing in the update!"
    RMDir /r "$PLUGINSDIR\RiseCache"
    
    Goto FailedRiseCacheUpdate
  
    AllRiseCacheFilesThere: 
    
    StrCpy $UpgradeNeeded "yes"
    
    ;StrCpy $FlashVersion $Revision
    
    Goto ExitRiseCacheUpdate

    FailedRiseCacheUpdate:
    IfFileExists "$INSTDIR\RiseCache\RiseCache.jar" ExitRiseCacheUpdate
    ${MyAbort} "Installation has failed."
    return

    ExitRiseCacheUpdate:
    ClearErrors
    StrCpy $Errors ""

!macroend

!macro __RiseCacheInstall

    StrCmp $RiseCacheVersion "" SkipRiseCacheInstall
    StrCmp $RiseCacheVersion $CurrentRiseCacheVersion SkipRiseCacheInstall
    
    ${DetailPrint} "Installing RiseCache, please wait..."
    
    CreateDirectory "$INSTDIR\RiseCache"
    CopyFiles /SILENT "$PLUGINSDIR\RiseCache\*.*" "$INSTDIR\RiseCache"
    IfErrors 0 RiseCacheCopySuccessful
    ${DetailPrint} "Failed to copy RiseCache files to the install folder!" 
    RMDir /r "$PLUGINSDIR\RiseCache"
        
    StrCmp $Hidden "1" SkipRiseCacheInstall   
    
    RiseCacheCopySuccessful:
    
    RMDir /r "$PLUGINSDIR\RiseCache"
  
    ;-------------------

    ${DetailPrint} "Saving RiseCache version information, please wait..."

    ClearErrors
    FileOpen $0 "$INSTDIR\RiseCache.ver" w
    IfErrors SkipWriteRiseCacheVersion
    FileWrite $0 $RiseCacheVersion
    FileClose $0
 
    SkipWriteRiseCacheVersion:
    SkipRiseCacheInstall:

!macroend

!define RiseCacheUpdate "!insertmacro __RiseCacheUpdate"
!define RiseCacheInstall "!insertmacro __RiseCacheInstall"