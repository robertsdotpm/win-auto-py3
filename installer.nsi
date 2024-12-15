!include "LogicLib.nsh"
!include "WinVer.nsh"

; Use the ANSI compiler
Outfile "MyAnsiDownloaderInstaller.exe"

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

Function InstallVistaPython
    StrCpy $0 "http://88.99.211.216/win-auto-py3/win_vista/python_3_7_0_x86.exe"
    StrCpy $1 "python3.exe"
    StrCpy $2 "/passive"
    Call DLRun
FunctionEnd

Section "MainSection"
    Var /GLOBAL WinVerMajor
    Var /GLOBAL WinVerMinor
    
    ; Get Windows version.
    ${WinVerGetMajor} $WinVerMajor
    ${WinVerGetMinor} $WinVerMinor
    
    ; Windows Vista
    ${If} $WinVerMajor == 6
    ${AndIf} $WinVerMinor == 0
        Call InstallAIORedist
        Call InstallVistaPython
    ${EndIf}
SectionEnd