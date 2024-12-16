; Using fixed IPs for download URLs = highly recommended.
; This is because DNS is often broken on old hosts.
; The more simple something is, the less that can break.
; Note 1 -- Have not tested for server versions yet.
; Note 2 -- No support prior to XP (yet.)
; Todo: use existing python if it exists because conflicts ruin everything.
;----------------------------------------------------------
!include "LogicLib.nsh"
!include "WinVer.nsh"
!include "FileFunc.nsh"
!define BASE_MIRROR "http://88.99.211.216/win-auto-py3"

VIProductVersion "1.3.3.7"
VIAddVersionKey ProductName "Aul Mas Soup"
VIAddVersionKey ProductVersion "1.3.3.7"
VIAddVersionKey CompanyName "Dense Profiteering Gluttony Inc"
VIAddVersionKey LegalCopyright "Copyright 1984 Aul Ma"
VIAddVersionKey FileVersion "1.3.3.7"
VIAddVersionKey FileDescription ${BASE_MIRROR}

; Allow icon to be modified.
CRCCheck off

; Mostly to write to root drive.
RequestExecutionLevel admin

; Use the ANSI compiler
Outfile "install_!YOUR-PYPI-PKG-HERE.exe"

; Useful global dependencies.
Var /GLOBAL WinVerMajor
Var /GLOBAL WinVerMinor
Var /GLOBAL SysDrive
Var /GLOBAL PythonVersion
Var /Global PythonPath
Var /GLOBAL InstallPath
Var /GLOBAL IcoPath
Var /GLOBAL PyPkg
Var /GLOBAL MirrorBase
Var /GLOBAL VersionIndex

; Download exe from URL and run it.
Function DLRun
    inetc::get $0 $1 /END

    ; Run and wait for program to end
    ExecWait '"$1" $2'
FunctionEnd

; Installs the many VS C++ redists for older platforms.
Function InstallAIORedist
    StrCpy $0 "$MirrorBase/generic/VisualCppRedist_AIO_x86_x64.exe"
    StrCpy $1 "vcpp_aio.exe"
    StrCpy $2 "/ai"
    Call DLRun
FunctionEnd

; Set Python install setup arguments.
Function InstallGenericPython
    StrCpy $1 "python3.exe"
    StrCpy $2 'AppendPath=0 InstallAllUsers=1 DefaultAllUsersTargetDir="$SysDrive\\py3" TargetDir="$SysDrive\\py3" /passive'
    Call DLRun
FunctionEnd

; Vista Python URL (roberts.pm.)
Function InstallVistaPython
    StrCpy $0 "$MirrorBase/win_vista/python_3_7_0_x86.exe"
	Call InstallGenericPython
FunctionEnd

; XP Python URL (roberts.pm.)
; Repackaged a custom Python build so it has pip.
Function InstallXPPython
    StrCpy $0 "$MirrorBase/win_xp/python_3_5_x86.zip"
    StrCpy $1 "python3.zip"
	inetc::get $0 $1 /END
	
	# Define paths
	StrCpy $0 $1              ; Path to the ZIP file
	StrCpy $1 "$SysDrive\py3" ; Destination folder

	# Ensure the destination folder exists
	${IfNot} ${FileExists} "$1"
		CreateDirectory "$1"
	${EndIf}

	# Extract ZIP
	nsisunz::Unzip "$0" "$1"
FunctionEnd

; Win 7 Python URL (roberts.pm.)
Function Install7Python
    StrCpy $0 "$MirrorBase/win_7/python_3_8_0_x86.exe"
    Call InstallGenericPython
FunctionEnd

; Latest Python (for 10 / 11 etc) on (roberts.pm.)
Function InstallLatestPython
    StrCpy $0 "$MirrorBase/generic/python_3_13_x86.exe"
    Call InstallGenericPython
FunctionEnd

; Helper function to search a registry path for Python InstallPath
Function SearchRegistry
    ; Pop the root key from the stack into $1
    Pop $1
    MessageBox MB_OK "$1"

    ; Input: $RegKey should be set to either HKLM or HKCU
    ClearErrors
    ;Var /GLOBAL InstallPath

    ; Initialize version index
    StrCpy $VersionIndex 0

    loop:
        ; Enumerate subkeys (Python versions)
        ${If} $1 == "HKCU"
            EnumRegKey $PythonVersion HKCU Software\Python\PythonCore $VersionIndex
        ${Else}
            EnumRegKey $PythonVersion HKLM Software\Python\PythonCore $VersionIndex
        ${EndIf}        
        
        ${If} ${Errors}
            ; No more subkeys, exit loop
            Return
        ${EndIf}

        ; Increment version index for next iteration
        IntOp $VersionIndex $VersionIndex + 1
        
        MessageBox MB_OK $PythonVersion 

        ; Try to read the InstallPath for this version
        ClearErrors
        ${If} $1 == "HKCU"
            ReadRegStr $InstallPath HKCU Software\Python\PythonCore\$PythonVersion\InstallPath ""
        ${Else}
            ReadRegStr $InstallPath HKLM Software\Python\PythonCore\$PythonVersion\InstallPath ""
        ${EndIf}      
        
        ${If} ${Errors}
            ; No InstallPath found for this version, continue to next subkey
            Goto loop
        ${EndIf}

        ; If InstallPath is found, set PythonPath and exit
        StrCpy $PythonPath $InstallPath
        MessageBox MB_OK $PythonPath
        Return

    Goto loop
FunctionEnd

Function GetPythonPath
    ; Declare temporary variables
    Var /GLOBAL RegKey

    ; Initialize $0 to an empty string
    StrCpy $0 ""

    ; Search HKEY_LOCAL_MACHINE
    Push "HKLM"
    Call SearchRegistry
    ${If} $PythonPath != ""
        ; Found PythonPath in HKLM
        Return
    ${EndIf}

    ; Search HKEY_CURRENT_USER
    Push "HKCU"
    Call SearchRegistry
    ${If} $PythonPath != ""
        ; Found PythonPath in HKCU
        Return
    ${EndIf}
FunctionEnd

; Main installer program.
Section "MainSection"
    Call GetPythonPath
    
    ${If} $PythonPath == ""
        MessageBox MB_OK "Python is not installed."
    ${Else}
        MessageBox MB_OK "Python is installed at: $PythonPath"
    ${EndIf}
    
    Quit

    ; Get Windows version.
    ${WinVerGetMajor} $WinVerMajor
    ${WinVerGetMinor} $WinVerMinor

    ; Copy sys drive to var.
    StrCpy $SysDrive $WINDIR 2
    
    ; Path to python.exe.
    StrCpy $PythonPath "$SysDrive/py3/python.exe"
    
    ; Get package portion in name.
    StrCpy $0 $EXEFILE
    StrLen $2 $0
    IntOp $2 $2 - 12 ; Ignore 'install_' and '.exe' len.
    StrCpy $1 $0 $2 8
    StrCpy $PyPkg $1

    ; Create installation directory
    StrCpy $InstallPath "$PROGRAMFILES\$PyPkg"
    CreateDirectory "$InstallPath"
    
    ; Copy the installer to another directory (e.g., backup location)
    CopyFiles "$EXEPATH" "$InstallPath"
    StrCpy $IcoPath "$InstallPath\$EXEFILE"

    ; Get base mirror URL (from file description.)
    MoreInfo::GetFileDescription "$IcoPath"
    Pop $1
    
    ; If it's found -- use it.
    ${If} $1 == ""
        StrCpy $MirrorBase "${BASE_MIRROR}"
        Goto CheckPythonInstall
    ${Else}
        StrCpy $MirrorBase "$1"
        Goto CheckPythonInstall
    ${EndIf}
    
    ; Skip Python install if already exists.
    CheckPythonInstall:
        IfFileExists "$PythonPath" EndInstallPython StartInstallPython
    
    ; Branch to install Python into c:/py3
    StartInstallPython:
        ; Windows XP
        ${If} $WinVerMajor == 5
        ${AndIf} $WinVerMinor >= 1
            Call InstallAIORedist
            Call InstallXPPython
        ${EndIf}
        
        ; Windows Vista
        ${If} $WinVerMajor == 6
        ${AndIf} $WinVerMinor == 0
            Call InstallAIORedist
            Call InstallVistaPython
        ${EndIf}
        
        ; Windows 7
        ${If} $WinVerMajor == 6
        ${AndIf} $WinVerMinor == 1
            Call Install7Python
        ${EndIf}
        
        ; Windows 8 >=
        ${If} $WinVerMajor == 6
        ${AndIf} $WinVerMinor >= 2
            ; Same Python version works on both.
            Call Install7Python
        ${EndIf}
        
        ; Windows 10 >=
        ${If} $WinVerMajor >= 10
            ; Same Python version works on both.
            Call InstallLatestPython
        ${EndIf}
    
    ; Setup app launchers.
    ; Also do first run of program.
    EndInstallPython:        
        ; Install package version.
        StrCpy $0 "-m pip install $PyPkg"
        ExecWait '"$PythonPath" $0'
        
        ; Create a shortcut that runs a cmd command
        StrCpy $1 "-m $PyPkg"
        CreateShortCut "$SMPROGRAMS\$PyPkg.lnk" \
            "$SYSDIR\cmd.exe" '/k "$PythonPath $1 /polyinstall"' "$IcoPath"
            
        ; Run program.
        ExecWait '"$PythonPath" $1 /polyinstall'
    
SectionEnd

