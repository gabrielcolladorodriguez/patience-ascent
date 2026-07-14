@echo off
title Patience Ascent - Configurar App Store
cd /d "%~dp0"

echo.
echo  Patience Ascent - Configurador de tienda
echo  ========================================
echo.

python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python no esta instalado.
    echo Instalalo desde https://www.python.org/downloads/
    pause
    exit /b 1
)

echo Instalando dependencias (solo la primera vez)...
pip install -r requirements-asc.txt -q

echo Abriendo interfaz...
python configure_store_gui.py

if errorlevel 1 (
    echo.
    echo Si la ventana no abrio, ejecuta manualmente:
    echo   python configure_store_gui.py
    pause
)
