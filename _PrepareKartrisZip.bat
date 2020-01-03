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
del "c:\CleanKartris\Kartris\_PrepareKartrisZip.bat"
del "c:\CleanKartris\Kartris\vwd.webinfo"
del "c:\CleanKartris\Kartris\website.publishproj"
ECHO **
ECHO CLEANING ERROR LOGS...
IF EXIST "c:\CleanKartris\Kartris\Uploads\Logs\Errors" rd "c:\CleanKartris\Kartris\Uploads\Logs\Errors" /S /Q
ECHO DONE!
ECHO **
ECHO REMOVING TFS CACHE FILES (now we're on github, probably no need, but whatever)...
IF EXIST "c:\CleanKartris\Kartris\$tf" rd "c:\CleanKartris\Kartris\$tf" /S /Q
IF EXIST "c:\CleanKartris\Kartris\$tf1" rd "c:\CleanKartris\Kartris\$tf1" /S /Q
IF EXIST "c:\CleanKartris\Kartris\$tf2" rd "c:\CleanKartris\Kartris\$tf2" /S /Q
IF EXIST "c:\CleanKartris\Kartris\$tf3" rd "c:\CleanKartris\Kartris\$tf3" /S /Q
ECHO DONE!
ECHO REMOVING GIT AND VS FILES...
IF EXIST "c:\CleanKartris\Kartris\.git" rd "c:\CleanKartris\Kartris\.git" /S /Q
IF EXIST "c:\CleanKartris\Kartris\.vs" rd "c:\CleanKartris\Kartris\.vs" /S /Q
IF EXIST "c:\CleanKartris\Kartris\.gitignore" del "c:\CleanKartris\Kartris\.gitignore" /Q
IF EXIST "c:\CleanKartris\Kartris\.gitattributes" del "c:\CleanKartris\Kartris\.gitattributes" /Q
ECHO REMOVING OTHER CRUFT...
IF EXIST "c:\CleanKartris\Kartris\kartris.sln" del "c:\CleanKartris\Kartris\kartris.sln" /Q
IF EXIST "c:\CleanKartris\Kartris\WebEssentials2015-Settings.json" del "c:\CleanKartris\Kartris\WebEssentials2015-Settings.json" /Q
IF EXIST "c:\CleanKartris\Kartris\packages.config" del "c:\CleanKartris\Kartris\packages.config" /Q
IF EXIST "c:\CleanKartris\Kartris\packages" rd "c:\CleanKartris\Kartris\packages" /S /Q
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
ECHO DONE!
ECHO **
ECHO Copying default WPI files...
xcopy "c:\CleanKartris\Kartris\DefaultBuildFiles\*.*" "c:\CleanKartris\*.*"	/S /Y 
xcopy /f /y "c:\CleanKartris\Kartris\DefaultBuildFiles\Kartris\web.config.default" "c:\CleanKartris\Kartris\web.config"
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