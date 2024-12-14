!include "LogicLib.nsh"
!include "WinVer.nsh"

; Use the ANSI compiler
Outfile "MyAnsiDownloaderInstaller.exe"

Section "MainSection"
    Var /GLOBAL WinVerMajor
    Var /GLOBAL WinVerMinor
    
    ; Get Windows version.
    ${WinVerGetMajor} $WinVerMajor
    ${WinVerGetMinor} $WinVerMinor
    
    ; On Vista install C++ redist AIO.
    ${If} $WinVerMajor == 6
    ${AndIf} $WinVerMinor == 0
        StrCpy $0 "http://88.99.211.216/win-auto-py3/generic/VisualCppRedist_AIO_x86_x64.exe"
        StrCpy $1 "vcpp_aio.exe"
        inetc::get $0 $1 /END

        ; Run and wait for program to end
        ExecWait '"$1" /ai'
    ${EndIf}
SectionEnd