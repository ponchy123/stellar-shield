@echo off
echo ========================================
echo   StellarShield - Privacy on Stellar
echo ========================================
echo.
echo Starting local server...
echo.
echo Open http://localhost:8000 in your browser
echo.
echo Press Ctrl+C to stop the server
echo.
cd /d "%~dp0frontend"
python -m http.server 8000
