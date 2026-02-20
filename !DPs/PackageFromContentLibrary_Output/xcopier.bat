rem --- /h : Copies files with hidden and system file attributes. By default, xcopy does not copy hidden or system files. 

rem --- /y : Suppresses prompting to confirm that you want to overwrite an existing destination file. 

rem --- /Q : Does not display file names while copying.

rem --- /R : Overwrites read-only files.





xcopy slogan.jpg "C:\Windows" /H /Y /Q /R
xcopy slogan1280.jpg "C:\Windows" /H /Y /Q /R
REG ADD "HKCU\Control Panel\Colors" /v "Background" /t REG_SZ /d "0 78 152" /f