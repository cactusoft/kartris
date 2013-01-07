@ECHO OFF
CLS
ECHO =========================================================================
ECHO PRECOMPILE KARTRIS
ECHO.
ECHO (c)2011 CACTUSOFT INTERNATIONAL FZ LLC. - WWW.KARTRIS.COM
ECHO All rights reserved.
ECHO =========================================================================
ECHO.
ECHO This script will precompile Kartris. Precompiling Kartris provides faster
ECHO initial response time for users since pages do not have to be compiled
ECHO the first time they are requested. 
ECHO.
ECHO ATTENTION: Make sure that Kartris can connect to the database before
ECHO            continuing. The connection string in the web.config (KartrisSQLConnection)
ECHO            must be properly set to allow successful precompilation.
ECHO.
SET WORKING_DIRECTORY=%cd%
cd ..
ECHO.
ECHO TARGET DIRECTORY
ECHO ==========================================================================
ECHO Precompiled Kartris will be saved to "%cd%\PrecompiledKartris"
ECHO ==========================================================================
ECHO.
ECHO Press CTRL+C if you want to cancel or
pause
ECHO.
ECHO PRECOMPILING...PLEASE WAIT...
ECHO.
"%windir%\Microsoft.NET\Framework\v2.0.50727\aspnet_compiler" -p "%WORKING_DIRECTORY%" -u "PrecompiledKartris" -v /
ECHO.
IF ERRORLEVEL 1 GOTO err
goto success

:success
DEL "%cd%\PrecompiledKartris\PrecompileKartris.bat"
ECHO PRECOMPILATION SUCCESSFUL!!!
ECHO FILES SAVED TO "%cd%\PrecompiledKartris"
goto end

:err
ECHO ERROR/S ENCOUNTERED DURING PRECOMPILATION.
ECHO OPERATION CANCELLED.
goto end

:end
ECHO.
pause