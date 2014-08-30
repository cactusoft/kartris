echo off
cls
ECHO ------------------------------
ECHO KARTRIS ZIP PREPARATION SCRIPT
ECHO ------------------------------
pause
cd ..
ECHO **
ECHO TRYING TO REMOVE C:\CLEANKARTRIS IF IT ALREADY EXISTS...
IF EXIST "C:\CleanKartris" rd "C:\CleanKartris" /S /Q
ECHO DONE!
ECHO **
ECHO DUMPING KARTRIS FILES TO C:\CLEANKARTRIS\KARTRIS...
IF EXIST "KartrisDumpLogFile.txt" del "KartrisDumpLogFile.txt" /S /Q
xcopy Kartris "C:\CleanKartris\Kartris" /S /I /Y >> "KartrisDumpLogFile.txt"
ECHO DONE!
ECHO **
cd "\CleanKartris\Kartris"
del "c:\CleanKartris\Kartris\PrepareKartrisZip.bat"
ECHO **
ECHO CLEANING ERROR LOGS...
IF EXIST "c:\CleanKartris\Kartris\Uploads\Logs\Errors" rd "c:\CleanKartris\Kartris\Uploads\Logs\Errors" /S /Q
ECHO DONE!
ECHO **
ECHO REMOVING TFS CACHE FILES...
IF EXIST "c:\CleanKartris\Kartris\$tf" rd "c:\CleanKartris\Kartris\$tf" /S /Q
IF EXIST "c:\CleanKartris\Kartris\$tf1" rd "c:\CleanKartris\Kartris\$tf1" /S /Q
ECHO DONE!
ECHO **
ECHO REMOVING SAMPLE MEDIA FILES...
del "c:\CleanKartris\Kartris\Uploads\Media\*.*" /Q
copy "c:\CleanKartris\Kartris\Uploads\Logs\README.txt" "c:\CleanKartris\Kartris\Uploads\Media\README.txt"
ECHO DONE!
ECHO **
del "c:\CleanKartris\Kartris\uploads\resources\*.bak"
del "c:\CleanKartris\Kartris\uploads\resources\*UpdateData*.sql"
del "c:\CleanKartris\Kartris\uploads\resources\UpdateSQL.sql"
REM ECHO Copying MainData SQL script to root...
REM copy "c:\CleanKartris\Kartris\uploads\resources\kartrisSQL_MainData.sql" "c:\CleanKartris\InstallSQL.SQL"
REM ECHO DONE!
REM ECHO **
ECHO Copying default web.config file...
copy "c:\CleanKartris\Kartris\defaultbuildfiles\Kartris\*.default" "c:\CleanKartris\Kartris\*.config"
ECHO DONE!
ECHO **
REM ECHO DONE!
REM ECHO **
ECHO Copying default WPI files...
copy "c:\CleanKartris\Kartris\defaultbuildfiles\*.*" "c:\CleanKartris\*.*"
ECHO DONE!
ECHO **
ECHO Deleting DefaultBuildFiles folder...
rd "c:\CleanKartris\Kartris\DefaultBuildFiles" /S /Q
ECHO DONE!
ECHO **
ECHO -----------------------------------------------------
ECHO Files inside "C:\CleanKartris\" ready for zipping! =)
ECHO -----------------------------------------------------
pause