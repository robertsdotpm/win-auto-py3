!include "LogicLib.nsh"
!include "WinVer.nsh"
!include FileFunc.nsh

; Allow icon to be modified.
CRCCheck off

; Mostly to write to root drive.
RequestExecutionLevel admin

; Use the ANSI compiler
Outfile "install_p2pd.exe"

; Useful global dependencies.
Var /GLOBAL SysDrive
Var /GLOBAL WinVerMajor
Var /GLOBAL WinVerMinor
Var /GLOBAL PyPkg
Var /GLOBAL InstallPath
Var /GLOBAL IcoPath

Function DLRun
    inetc::get $0 $1 /END

    ; Run and wait for program to end
    ExecWait '"$1" $2'
FunctionEnd

Function InstallAIORedist
    StrCpy $0 "http://88.99.211.216/win-auto-py3/generic/VisualCppRedist_AIO_x86_x64.exe"
    StrCpy $1 "vcpp_aio.exe"
    StrCpy $2 "/ai"
    Call DLRun
FunctionEnd

Function InstallGenericPython
    StrCpy $1 "python3.exe"
    StrCpy $2 'InstallAllUsers=1 DefaultAllUsersTargetDir="$SysDrive\\py3" TargetDir="$SysDrive\\py3" /passive'
    Call DLRun
FunctionEnd

; This has pip built in - python.exe
Function InstallVistaPython
    StrCpy $0 "http://88.99.211.216/win-auto-py3/win_vista/python_3_7_0_x86.exe"
	Call InstallGenericPython
FunctionEnd

; python.exe
Function InstallXPPython
    StrCpy $0 "http://88.99.211.216/win-auto-py3/win_xp/python_3_5_x86.zip"
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

; Notes: I think 3.5 works too but the installer UI
; is glitched (have to run from cmd line)
; python.exe
Function Install7Python
    StrCpy $0 "http://88.99.211.216/win-auto-py3/win_7/python_3_8_0_x86.exe"
    Call InstallGenericPython
FunctionEnd

Function InstallLatestPython
    StrCpy $0 "http://88.99.211.216/win-auto-py3/generic/python_3_13_x86.exe"
    Call InstallGenericPython
FunctionEnd

Section "MainSection"
    ; Copy sys drive to var.
    StrCpy $SysDrive $WINDIR 2
    
    ; Get installer file name.
    StrCpy $0 $EXEFILE
    
    ; Get package porition in name.
    StrLen $2 $0
    ; Don't include len of 'install_' and '.exe'
    IntOp $2 $2 - 12
    StrCpy $1 $0 $2 8
    StrCpy $PyPkg $1
    
    ; Create installation directory
    StrCpy $InstallPath "$PROGRAMFILES\$PyPkg"
    CreateDirectory "$InstallPath"
    
    ; Copy the installer to another directory (e.g., backup location)
    CopyFiles "$EXEPATH" "$InstallPath\"
    StrCpy $IcoPath "$InstallPath\$EXEFILE"
    MessageBox MB_OK $IcoPath
    
    ; Install package version.
    StrCpy $0 "$SysDrive/py3/python.exe"
    StrCpy $1 "-m pip install $PyPkg"
    ExecWait '"$0" $1'
    
    ; Create a shortcut that runs a cmd command
    ; Example: Run "echo Hello, World!" in cmd
    StrCpy $1 "-m $PyPkg.poly"
    CreateShortCut "$SMPROGRAMS\$PyPkg.lnk" \
        "$SYSDIR\cmd.exe" '/k "$0" $1' "$IcoPath"
        
    Quit
    
    ; Get Windows version.
    ${WinVerGetMajor} $WinVerMajor
    ${WinVerGetMinor} $WinVerMinor
	
	; Windows XP
    ${If} $WinVerMajor == 5
    ${AndIf} $WinVerMinor == 1
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
    

    
SectionEnd

