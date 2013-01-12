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
IF EXIST "c:\CleanKartris\Kartris\Uploads\Errors" rd "c:\CleanKartris\Kartris\Uploads\Errors" /S /Q
ECHO DONE!
ECHO **
ECHO REMOVING SAMPLE MEDIA FILES...
del "c:\CleanKartris\Kartris\Uploads\Media\*.*" /Q
ECHO DONE!
ECHO **
del "c:\CleanKartris\Kartris\uploads\resources\*UpdateData*.sql"
del "c:\CleanKartris\Kartris\uploads\resources\UpdateSQL.sql"
REM ECHO DONE!
REM ECHO **
ECHO Copying default web.config file...
copy "c:\CleanKartris\Kartris\defaultbuildfiles\Kartris\*.default" "c:\CleanKartris\Kartris\*.config"
ECHO DONE!
ECHO **
ECHO Copying default payment gateway config files...
copy "c:\CleanKartris\Kartris\defaultbuildfiles\Kartris\Plugins\2Checkout\*.default" "c:\CleanKartris\Kartris\Plugins\2Checkout\*.config"
copy "c:\CleanKartris\Kartris\defaultbuildfiles\Kartris\Plugins\GoogleCheckout\*.default" "c:\CleanKartris\Kartris\Plugins\GoogleCheckout\*.config"
copy "c:\CleanKartris\Kartris\defaultbuildfiles\Kartris\Plugins\Paypal\*.default" "c:\CleanKartris\Kartris\Plugins\Paypal\*.config"
copy "c:\CleanKartris\Kartris\defaultbuildfiles\Kartris\Plugins\PO_OfflinePayment\*.default" "c:\CleanKartris\Kartris\Plugins\PO_OfflinePayment\*.config"
copy "c:\CleanKartris\Kartris\defaultbuildfiles\Kartris\Plugins\RBSWorldPay\*.default" "c:\CleanKartris\Kartris\Plugins\RBSWorldPay\*.config"
copy "c:\CleanKartris\Kartris\defaultbuildfiles\Kartris\Plugins\SagePay\*.default" "c:\CleanKartris\Kartris\Plugins\SagePay\*.config"
copy "c:\CleanKartris\Kartris\defaultbuildfiles\Kartris\Plugins\SagePayDirect\*.default" "c:\CleanKartris\Kartris\Plugins\SagePayDirect\*.config"
copy "c:\CleanKartris\Kartris\defaultbuildfiles\Kartris\Plugins\SecureTrading\*.default" "c:\CleanKartris\Kartris\Plugins\SecureTrading\*.config"
copy "c:\CleanKartris\Kartris\defaultbuildfiles\Kartris\Plugins\UPS\*.default" "c:\CleanKartris\Kartris\Plugins\UPS\*.config"
copy "c:\CleanKartris\Kartris\defaultbuildfiles\Kartris\Plugins\USPS\*.default" "c:\CleanKartris\Kartris\Plugins\USPS\*.config"
ECHO DONE!
ECHO **
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