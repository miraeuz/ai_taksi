@echo off
cd /d "%~dp0preview"
start "" http://localhost:8765
python -m http.server 8765
