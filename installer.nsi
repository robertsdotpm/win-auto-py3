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
        StrCpy $0 "http://roberts.pm/win-auto-py3/generic/VisualCppRedist_AIO_x86_x64.exe"
        StrCpy $1 "$TEMP\vcpp_aio.exe"
        inetc::get /URL $0 $1
        
        
        pop $R0
        DetailPrint "Result: $R0"

        Pop $2 ; Get the result of the download

        ; Check for download errors
        StrCmp $2 "OK" +2
        MessageBox MB_OK "Download failed with error: $2"

        ; Run and wait for program to end
        ExecWait '"$1"'
    ${EndIf}
SectionEnd