@echo off
title Anima Training UI
cd /d "%~dp0training-ui"

rem Port: pass one as argument to override, otherwise default 3001
set "UI_PORT=3001"
if not "%~1"=="" set "UI_PORT=%~1"

echo ============================================================
echo   Anima Training UI
echo   Opening: http://localhost:%UI_PORT%
echo   (keep this window open while you train - close it to stop)
echo ============================================================
echo.

rem Open the browser a few seconds after the server has had time to start
start "" /b cmd /c "timeout /t 5 /nobreak >nul & start "" http://localhost:%UI_PORT%"

rem Start the server in this window (shows live logs)
call npm start -- --port=%UI_PORT%

echo.
echo Server stopped. Press any key to close this window.
pause >nul
