@echo off
cd /d "%~dp0"

rem Port: use the first argument if given, otherwise default to 8080
rem (3000 is avoided to prevent clashes with other local apps).
set "UI_PORT=%~1"
if "%UI_PORT%"=="" set "UI_PORT=3001"

echo Starting Anima Training UI on http://localhost:%UI_PORT% ...
call npm start -- --port=%UI_PORT%
echo.
echo Application exited (check for errors above).
pause
