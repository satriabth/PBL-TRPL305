@echo off
title Aplikasi Microcredential - Mode Demo
color 0A
echo =============================================
echo    APLIKASI MICROCREDENTIAL POLIBATAM - DEMO
echo =============================================
echo.
echo Mencari Python (diperlukan untuk menjalankan demo)...
echo.

where python >nul 2>nul
if %errorlevel%==0 goto run_python

where py >nul 2>nul
if %errorlevel%==0 goto run_py

echo [GAGAL] Python tidak ditemukan di komputer ini.
echo.
echo Solusi (sekali saja): 
echo   1. Buka https://www.python.org/downloads/
echo   2. Download Python lalu install
echo   3. PENTING: centang "Add Python to PATH" saat install
echo   4. Tutup file ini, lalu dobel-klik lagi.
echo.
pause
exit /b 1

:run_python
echo Membuka aplikasi di browser...
start "" http://localhost:8080
python -m http.server 8080
exit /b 0

:run_py
echo Membuka aplikasi di browser...
start "" http://localhost:8080
py -m http.server 8080
exit /b 0
