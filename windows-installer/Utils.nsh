;-------------------------------

!macro _debugMsg MSG
  push $7
  push $6
  push $5
  push $4
  push $3
  push $2
  push $1
  push $0
  push $R0

  strcpy $R0 "${MSG}"

  ClearErrors
  FileOpen $7 ${LOGFILE} a
  FileSeek $7 0 END
  IfErrors +8
  ${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
  FileWrite $7 "$2-$1-$0 $4:$5:$6$\t"
  ;FileWrite $7 "${__FUNCTION__}$\t"
  FileWrite $7 "$R0"
  ;FileWrite $7 "$\t(${__FILE__},${__FUNCTION__},${__LINE__})"
  FileWrite $7 "$\n"
  FileClose $7

  pop $R0
  pop $0
  pop $1
  pop $2
  pop $3
  pop $4
  pop $5
  pop $6
  pop $7
!macroend

!define LogFilePrint "!insertmacro _debugMsg"

!macro _checkLogFileSize

  Push "${LOGFILE}"
  Call FileSizeNew
  Pop $0
  
  ${If} $0 > ${MAXLOGFILESIZE}
  	IfFileExists ${LOGFILE2} 0 SkipDeleteLOGFILE2
        Delete ${LOGFILE2}
        SkipDeleteLOGFILE2:
        Rename ${LOGFILE} ${LOGFILE2}
  ${EndIf}

!macroend

!define CheckLogFileSize "!insertmacro _checkLogFileSize"

;-------------------------------


;--------------------------------

!macro __DetailPrint Text
  SetDetailsPrint Both
  DetailPrint "${Text}"
  ${LogFilePrint} "${Text}"
  SetDetailsPrint None
!macroend

!macro __TextPrint Text
  SetDetailsPrint TextOnly
  DetailPrint "${Text}"
  ${LogFilePrint} "${Text}"
  SetDetailsPrint None
!macroend

!macro __ListPrint Text Data
  !define ID "${__LINE__}"
  SetDetailsPrint ListOnly

  StrCmp ${Data} "" PrintEmpty_${ID}
  DetailPrint "> ${Text}: ${Data}"
  ${LogFilePrint} "> ${Text}: ${Data}"
  Goto PrintDone_${ID}
  
  PrintEmpty_${ID}:
  DetailPrint "> ${Text}: Unknown"
  ${LogFilePrint} "> ${Text}: Unknown"
  Goto PrintDone_${ID}

  PrintDone_${ID}:
  SetDetailsPrint None
  !undef ID
!macroend




!define DetailPrint "!insertmacro __DetailPrint"
!define TextPrint "!insertmacro __TextPrint"
!define ListPrint "!insertmacro __ListPrint"

;-------------------------------

!macro __MyAbort Text

  SetDetailsPrint Both
  ${PlayerFailMessage}
  Abort "${Text}"
  SetDetailsPrint None

!macroend

!define MyAbort "!insertmacro __MyAbort"

!macro __PlayerFailMessage

   SetDetailsPrint Both

   ${DetailPrint} "Rise Vision Player failed to install correctly due to the following errors:"
   ${DetailPrint} "$Errors"
   ${DetailPrint} "These errors have been written to this log file ${LOGFILE}."
   ${DetailPrint} "If you cannot correct this error please post the details to http://community.risevision.com"

   SetDetailsPrint None

!macroend

!define PlayerFailMessage "!insertmacro __PlayerFailMessage"
;--------------------------------

!macro __Download mode Info URL OutName showStatus
  !define ID "${__LINE__}"
  
  DL_Retry_${ID}:
 
  !if ${mode} == "popup"
    inetc::get /CAPTION "${Info}" /POPUP "${URL}" "${URL}" "${OutName}"
  !else if ${mode} == "banner"
    inetc::get /CAPTION "${Info}" /BANNER "Update Server:$\n$\n${URL}" "${URL}" "${OutName}"
  !else if ${mode} == "silent"
    inetc::get /SILENT "${URL}" "${OutName}"
  !else
    !error 'You must set MODE to "popup", "banner" or "silent"'
  !endif
  
  Pop $R0
  
  !if ${showStatus} == "true"
	  SetDetailsPrint Both
	  ${DetailPrint} "Download status: $R0"
	  SetDetailsPrint None
  !endif
  #StrCmp $R0 "OK" DL_Success_${ID}
  #StrCmp $R0 "Cancelled" DL_Canceled_${ID}
  StrCmp $R0 "Transfer Error" DL_Error_${ID}

  Push $R0
  Goto DL_Done_${ID}

  #StrCmp $Hidden "1" DownloadFailed_${ID}
  #MessageBox MB_RETRYCANCEL|MB_ICONSTOP|MB_TOPMOST "Download failed: $R0$\nPlease check your internet connection and try again!" IDRETRY DL_Retry_${ID}
  #DownloadFailed_${ID}:
  #${MyAbort} "Update has failed."
  
  #DL_Canceled_${ID}:
  #MessageBox MB_OK|MB_ICONEXCLAMATION|MB_TOPMOST "Download was aborted by user!"
  #${MyAbort} "Update was aborted by user."
  
  DL_Error_${ID}:
  
  SetDetailsPrint Both
  ${DetailPrint} "Transfer error detected $R0, retrying..."
  SetDetailsPrint None
  Goto DL_Retry_${ID}

  DL_Done_${ID}:
  !undef ID
!macroend

!define Download "!insertmacro __Download"

;--------------------------------

; load language from command line /L=1033
 ; foo.exe /S /L=1033 /D=C:\Program Files\Foo
 ; or:
 ; foo.exe /S "/L=1033" /D="C:\Program Files\Foo"
 ; gpv "/L=" "1033"
 !macro __GetCLIParameterValue SWITCH DEFAULT
  !define LN "${__LINE__}"
   Push $0
   Push $1
   Push $2
   Push $3
   Push $4
 
 ;$CMDLINE='"My Setup\Setup.exe" /L=1033 /S'
   Push "$CMDLINE"
   Push '${SWITCH}"'
   !insertmacro StrStr
   Pop $0
   StrCmp "$0" "" gpv_notquoted_${LN}
 ;$0='/L="1033" /S'
   StrLen $2 "$0"
   Strlen $1 "${SWITCH}"
   IntOp $1 $1 + 1
   StrCpy $0 "$0" $2 $1
 ;$0='1033" /S'
   Push "$0"
   Push '"'
   !insertmacro StrStr
   Pop $1
   StrLen $2 "$0"
   StrLen $3 "$1"
   IntOp $4 $2 - $3
   StrCpy $0 $0 $4 0
   Goto gpv_done_${LN}
 
   gpv_notquoted_${LN}:
   Push "$CMDLINE"
   Push "${SWITCH}"
   !insertmacro StrStr
   Pop $0
   StrCmp "$0" "" gpv_done_${LN}
 ;$0='/L="1033" /S'
   StrLen $2 "$0"
   Strlen $1 "${SWITCH}"
   StrCpy $0 "$0" $2 $1
 ;$0=1033 /S'
   Push "$0"
   Push ' '
   !insertmacro StrStr
   Pop $1
   StrLen $2 "$0"
   StrLen $3 "$1"
   IntOp $4 $2 - $3
   StrCpy $0 $0 $4 0
   Goto gpv_done_${LN}
 
   gpv_done_${LN}:
   StrCmp "$0" "" 0 +2
   StrCpy $0 "${DEFAULT}"
 
   Pop $4
   Pop $3
   Pop $2
   Pop $1
   Exch $0
   !undef LN
 !macroend
 
; And I had to modify StrStr a tiny bit.
; Possible upgrade switch the goto's to use ${__LINE__}
 
!macro STRSTR
  Exch $R1 ; st=haystack,old$R1, $R1=needle
  Exch    ; st=old$R1,haystack
  Exch $R2 ; st=old$R1,old$R2, $R2=haystack
  Push $R3
  Push $R4
  Push $R5
  StrLen $R3 $R1
  StrCpy $R4 0
  ; $R1=needle
  ; $R2=haystack
  ; $R3=len(needle)
  ; $R4=cnt
  ; $R5=tmp
 ;  loop;
    StrCpy $R5 $R2 $R3 $R4
    StrCmp $R5 $R1 +4
    StrCmp $R5 "" +3
    IntOp $R4 $R4 + 1
    Goto -4
 ;  done;
  StrCpy $R1 $R2 "" $R4
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Exch $R1
!macroend

!define GetCLIParameterValue "!insertmacro __GetCLIParameterValue"

;--------------------------------

!macro __GetRevision DestURL
  
    !define LN "${__LINE__}"
    StrCpy $1 ""
    
    !insertmacro __Download "silent" "Downloading version information..." "${DestURL}" "$PLUGINSDIR\temp.txt"
  
    Pop $R0
    StrCmp $R0 "OK" DetectRevision_${LN}

    ${DetailPrint} "Unable to obtain version information at this time."
    Goto SkipRevisionDetection_${LN}
    
    DetectRevision_${LN}:
    ClearErrors
    FileOpen $0 "$PLUGINSDIR\temp.txt" r
    IfErrors SkipRevisionDetection_${LN}
    FileRead $0 $1
    FileClose $0
    
    Push $1
    !insertmacro Trim
    Pop $1
  
    SkipRevisionDetection_${LN}:
    Delete "$PLUGINSDIR\temp.txt"
    
    Push $1
    
    !undef LN
!macroend

!macro TRIM

    Exch $R1 ; Original string
    Push $R2
 
Loop1_${LN}:
    StrCpy $R2 "$R1" 1
    StrCmp "$R2" " " TrimLeft_${LN}
    StrCmp "$R2" "$\r" TrimLeft_${LN}
    StrCmp "$R2" "$\n" TrimLeft_${LN}
    StrCmp "$R2" "$\t" TrimLeft_${LN}
    GoTo Loop2_${LN}
TrimLeft_${LN}:   
    StrCpy $R1 "$R1" "" 1
    Goto Loop1_${LN}
 
Loop2_${LN}:
    StrCpy $R2 "$R1" 1 -1
    StrCmp "$R2" " " TrimRight_${LN}
    StrCmp "$R2" "$\r" TrimRight_${LN}
    StrCmp "$R2" "$\n" TrimRight_${LN}
    StrCmp "$R2" "$\t" TrimRight_${LN}
    GoTo Done_${LN}
TrimRight_${LN}:  
    StrCpy $R1 "$R1" -1
    Goto Loop2_${LN}
 
Done_${LN}:
    Pop $R2
    Exch $R1
!macroend

!define GetRevision "!insertmacro __GetRevision"

;--------------------------------

!macro __MutexCheck _mutexname _outvar _handle 
    System::Call 'kernel32::CreateMutexA(i 0, i 0, t "${_mutexname}" ) i.r1 ?e' 
    StrCpy ${_handle} $1 
    Pop ${_outvar} 
!macroend 

!define MutexCheck "!insertmacro __MutexCheck"

;--------------------------------

!macro __MutexClose _handle 
    System::Call 'kernel32::CloseHandle(i ${_handle}) i.' 
!macroend 

!define MutexClose "!insertmacro __MutexClose"

;--------------------------------

; Push $filenamestring (e.g. 'c:\this\and\that\filename.htm')
; Push "\"
; Call StrSlash
; Pop $R0
; ;Now $R0 contains 'c:/this/and/that/filename.htm'
/*Function StrSlash
  Exch $R3 ; $R3 = needle ("\" or "/")
  Exch
  Exch $R1 ; $R1 = String to replacement in (haystack)
  Push $R2 ; Replaced haystack
  Push $R4 ; $R4 = not $R3 ("/" or "\")
  Push $R6
  Push $R7 ; Scratch reg
  StrCpy $R2 ""
  StrLen $R6 $R1
  StrCpy $R4 "\"
  StrCmp $R3 "/" loop
  StrCpy $R4 "/"  
loop:
  StrCpy $R7 $R1 1
  StrCpy $R1 $R1 $R6 1
  StrCmp $R7 $R3 found
  StrCpy $R2 "$R2$R7"
  StrCmp $R1 "" done loop
found:
  StrCpy $R2 "$R2$R4"
  StrCmp $R1 "" done loop
done:
  StrCpy $R3 $R2
  Pop $R7
  Pop $R6
  Pop $R4
  Pop $R2
  Pop $R1
  Exch $R3
FunctionEnd
*/

!macro _StrSlashConstructor filenamestring 
  Push "${filenamestring}"
  Push "\"
  Call StrSlash
  Pop $0
!macroend
 
!define ConvertSlashes '!insertmacro "_StrSlashConstructor"'

;--------------------------------

!macro _ExtractDisplayId 

    ;expected file name structure:
    ; a) RiseVisionPlayer.exe
    ; b) RiseVisionPlayer_{display ID (36 characters)}_{claim ID}.exe
    ; c) RiseVisionPlayer__{claim ID (var characters)}.exe
    
    StrCpy $RightPart ""
    StrCpy $DisplayId ""
    StrCpy $ClaimId ""
    StrCpy $InstallerExeName "${BaseName}.exe"

    ; try to read Display ID and Claim ID from RiseDisplayNetworkII.ini
    IfFileExists "$INSTDIR\${DisplayIdFile}" 0 CopyIdFromInstaller
    ${ConfigRead} "$INSTDIR\${DisplayIdFile}" "displayid=" $DisplayId
    ${ConfigRead} "$INSTDIR\${DisplayIdFile}" "claimid=" $ClaimId
    ${ConfigRead} "$INSTDIR\${DisplayIdFile}" "viewerurl=" $ViewerURLLocal
    ${ConfigRead} "$INSTDIR\${DisplayIdFile}" "coreurl=" $CoreURLLocal

    Goto SkipWriteDisplayId
    
    ;-------------------------------
    ; check if installer does not include Display ID and/or Claim ID
    ;-------------------------------
    
    CopyIdFromInstaller:

    ${DetailPrint} "Extracting Display Id from Installer filename"
    StrCmp "$EXEFILE" "${BaseName}.exe" WriteDisplayId 0
        
    ;-------------------------------
    ;check if installer has Display ID or just Claim Id. Two hyphens in a row means no Display ID 
    Push "$EXEFILE";input string
    Push "_" ;divider char
    Push "i"
    Call StrCount
    Pop $0
    StrCmp $0 "0" WriteDisplayId
    StrCmp $0 "1" ReadDisplayId
    StrCmp $0 "2" ReadClaimId
    
    ReadDisplayId:
    Push "_" ;divider char
    Push  "$EXEFILE";input string
    Call SplitFirstStrPart
    Pop $R0 ;1st part ["string1"]
    Pop $R1 ;rest ["string2|string3|string4|string5"]   
    StrCpy $RightPart "$R1" ;2KPMM6ZZ4C6P__986027363897563894756389473434 (1).exe
       
    Push "$RightPart" ;input string 2KPMM6ZZ4C6P (1).exe
    Call GetFirstStrPartFileName
    Pop $R0 ;1st part ["string1"]
    StrCpy $DisplayId "$R0"  ; got 2KPMM6ZZ4C6P
    
    StrCmp $RightPart "__" WriteDisplayId 0
    
    ReadClaimId:
    Push $RightPart ;"String to do replacement in (haystack)"
    Push "__" ;"String to replace (needle)"
    Push "_"
    Call StrRep
    Pop "$R0" ;result
    StrCpy $RightPart "$R0"
    
    Push "_" ;divider char
    Push  "$RightPart";input string
    Call SplitFirstStrPart
    Pop $R0 ;1st part ["string1"]
    Pop $R1 ;rest ["string2|string3|string4|string5"]   
    StrCpy $RightPart "$R1" ;986027363897563894756389473434 (1).exe
    
    Push  "$RightPart" ;input string
    Call GetFirstStrPartFileName
    Pop $R0 ;1st part ["string1"]
    StrCpy $ClaimId "$R0"
    
    WriteDisplayId:
    
    ;-------------------
    ; Writing DisplayID to an INI file for compatibility with legacy applications 
    
    ClearErrors
    FileOpen $0 "$INSTDIR\${DisplayIdFile}" w
    IfErrors SkipWriteDisplayId
    FileWrite $0 "[RDNII]$\r$\ndisplayid=$DisplayId$\r$\nclaimid=$ClaimId$\r$\nviewerurl=${ViewerURL}$\r$\ncoreurl=${CoreURL}$\r$\n"
    FileClose $0

    ;-------------------
 
    SkipWriteDisplayId:
    
    StrCmp $DisplayId "" 0 +2
    StrCpy $DisplayId "DEMO"
               
    ${ListPrint} "Display ID" $DisplayId
    ${ListPrint} "Claim ID" $ClaimId
!macroend
 
!define ExtractDisplayId '!insertmacro "_ExtractDisplayId"'


Function GetFirstStrPartFileName
  Exch $R0
  Push $R1
  Push $R2
  StrLen $R1 $R0
  IntOp $R1 $R1 + 1
  loop:
    IntOp $R1 $R1 - 1
    StrCpy $R2 $R0 1 -$R1
    StrCmp $R2 "" exit2
    StrCmp $R2 " " exit1 ; Change " " to "\" if ur inputting dir path str
    StrCmp $R2 "(" exit1 ; Change " " to "\" if ur inputting dir path str
    StrCmp $R2 "." exit1 ; Change " " to "\" if ur inputting dir path str
    StrCmp $R2 "_" exit1 ; Change " " to "\" if ur inputting dir path str
  Goto loop
  exit1:
    StrCpy $R0 $R0 -$R1
  exit2:
    Pop $R2
    Pop $R1
    Exch $R0
FunctionEnd


Function SplitFirstStrPart
  Exch $R0
  Exch
  Exch $R1
  Push $R2
  Push $R3
  StrCpy $R3 $R1
  StrLen $R1 $R0
  IntOp $R1 $R1 + 1
  loop:
    IntOp $R1 $R1 - 1
    StrCpy $R2 $R0 1 -$R1
    StrCmp $R1 0 exit0
    StrCmp $R2 $R3 exit1 loop
  exit0:
  StrCpy $R1 ""
  Goto exit2
  exit1:
    IntOp $R1 $R1 - 1
    StrCmp $R1 0 0 +3
     StrCpy $R2 ""
     Goto +2
    StrCpy $R2 $R0 "" -$R1
    IntOp $R1 $R1 + 1
    StrCpy $R0 $R0 -$R1
    StrCpy $R1 $R2
  exit2:
  Pop $R3
  Pop $R2
  Exch $R1 ;rest
  Exch
  Exch $R0 ;first
FunctionEnd

Function StrRep
  Exch $R4 ; $R4 = Replacement String
  Exch
  Exch $R3 ; $R3 = String to replace (needle)
  Exch 2
  Exch $R1 ; $R1 = String to do replacement in (haystack)
  Push $R2 ; Replaced haystack
  Push $R5 ; Len (needle)
  Push $R6 ; len (haystack)
  Push $R7 ; Scratch reg
  StrCpy $R2 ""
  StrLen $R5 $R3
  StrLen $R6 $R1
loop:
  StrCpy $R7 $R1 $R5
  StrCmp $R7 $R3 found
  StrCpy $R7 $R1 1 ; - optimization can be removed if U know len needle=1
  StrCpy $R2 "$R2$R7"
  StrCpy $R1 $R1 $R6 1
  StrCmp $R1 "" done loop
found:
  StrCpy $R2 "$R2$R4"
  StrCpy $R1 $R1 $R6 $R5
  StrCmp $R1 "" done loop
done:
  StrCpy $R3 $R2
  Pop $R7
  Pop $R6
  Pop $R5
  Pop $R2
  Pop $R1
  Pop $R4
  Exch $R3
FunctionEnd

Function StrCount 
	;takes the following parameters by the stack:
	; case sensitive ('s') or insensitive
    ; string to lookup
    ; string where to search
 
	Exch $2	;Stack = ($2 test str)
    Exch	;Stack = (test $2 str)
    Exch $1	;Stack = ($1 $2 str)
    Exch	;Stack = ($2 $1 str)
    Exch 2	;Stack = (str $1 $2)
    Exch $0	;Stack = ($0 $1 $2)
    Exch 2	;Stack = ($2 $1 $0) just to pop in natural order
    Push $3
    Push $4
    Push $5	
    Push $6	;Stack = ($6 $5 $4 $3 $2 $1 $0)
 
	StrLen $4 $1    
    StrCpy $5 0
    StrCpy $6 0
 
    ;now $0=str, $1=test, $2=s/i, $3=tmp str, $4=lookup len, $5=index, $6=count
 
    loop:
    StrCpy $3 $0 $4 $5
    StrCmp $3 "" end
    ${if} $2 == 's'
    	StrCmpS $3 $1 count ignore
    ${else}
    	StrCmp $3 $1 count ignore
    ${endif}
    count:
    IntOp $6 $6 + 1	;count++
    ignore:
    IntOp $5 $5 + 1 ;index++
	goto loop
	end:
 
    Exch 6	;Stack = ($0 $5 $4 $3 $2 $1 $6)
	Pop $0
    Pop $5
    Pop $4
    Pop $3
    Pop $2
    Pop $1	;Stack = ($6)
    Exch $6	;count is on top stack
FunctionEnd

Function FileSizeNew 
 
  Exch $0
  Push $1
  FileOpen $1 $0 "r"
  FileSeek $1 0 END $0
  FileClose $1  
  Pop $1
  Exch $0
 
FunctionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate a random number using the RtlGenRandom api
;; P1 :out: Random number
;; P2 :in:  Minimum value
;; P3 :in:  Maximum value
;; min/max P2 and P3 values = -2 147 483 647 / 2 147 483 647
;; max range = 2 147 483 647 (31-bit)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!define Rnd "!insertmacro _Rnd"
!macro _Rnd _RetVal_ _Min_ _Max_
   Push "${_Max_}"
   Push "${_Min_}"
   Call Rnd
   Pop ${_RetVal_}
!macroend
Function Rnd
   Exch $0  ;; Min / return value
   Exch
   Exch $1  ;; Max / random value
   Push "$3"  ;; Max - Min range
   Push "$4"  ;; random value buffer
 
   IntOp $3 $1 - $0 ;; calculate range
   IntOp $3 $3 + 1
   System::Call '*(l) i .r4'
   System::Call 'advapi32::SystemFunction036(i r4, i 4)'  ;; RtlGenRandom
   System::Call '*$4(l .r1)'
   System::Free $4
   ;; fit value within range
   System::Int64Op $1 * $3
   Pop $3
   System::Int64Op $3 / 0xFFFFFFFF
   Pop $3
   IntOp $0 $3 + $0  ;; index with minimum value
 
   Pop $4
   Pop $3
   Pop $1
   Exch $0
FunctionEnd
