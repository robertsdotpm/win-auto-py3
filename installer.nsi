!include "LogicLib.nsh"
!include "WinVer.nsh"

RequestExecutionLevel admin

; Use the ANSI compiler
Outfile "MyAnsiDownloaderInstaller.exe"
Var /GLOBAL SysDrive
Var /GLOBAL WinVerMajor
Var /GLOBAL WinVerMinor

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

; This has pip built in.
Function InstallVistaPython
    StrCpy $0 "http://88.99.211.216/win-auto-py3/win_vista/python_3_7_0_x86.exe"
    StrCpy $1 "python3.exe"
    StrCpy $2 'InstallAllUsers=1 DefaultAllUsersTargetDir="$SysDrive\py3" TargetDir="$SysDrive\py3" /passive'
    Call DLRun
FunctionEnd

Function InstallXPPython
    StrCpy $0 "http://88.99.211.216/win-auto-py3/win_xp/python_3_5_x86.zip"
    StrCpy $1 "python3.zip"
FunctionEnd

Section "MainSection"
    StrCpy $SysDrive $WINDIR 2
    
    ; Get Windows version.
    ${WinVerGetMajor} $WinVerMajor
    ${WinVerGetMinor} $WinVerMinor
    
    ; Windows Vista
    ${If} $WinVerMajor == 6
    ${AndIf} $WinVerMinor == 0
        Call InstallAIORedist
        Call InstallVistaPython
    ${EndIf}
	
	# Windows XP
    ${If} $WinVerMajor == 5
    ${AndIf} $WinVerMinor == 1
        Call InstallAIORedist
        Call InstallVistaPython
    ${EndIf}
	
SectionEnd