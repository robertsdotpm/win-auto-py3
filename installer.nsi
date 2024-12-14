!include "LogicLib.nsh"
!include "WinVer.nsh"

; Use the ANSI compiler
Outfile "MyAnsiDownloaderInstaller.exe"

Section "MainSection"
    Var /GLOBAL WindowsMajorVersion
    ${WinVerGetMajor} $WindowsMajorVersion
    ${If} $WindowsMajorVersion == 10
        StrCpy $0 "http://localhost/nsi/hello.exe"
        StrCpy $1 "$TEMP\myprogram.exe"

        inetc::get /URL $0 $1
        Pop $2
        StrCmp $2 "OK" +2
        MessageBox MB_OK "Download failed with error: $2"

        ; Run and wait for program to end
        ExecWait '"$1"'
        MessageBox MB_OK "Installation complete!"
    ${EndIf}
SectionEnd