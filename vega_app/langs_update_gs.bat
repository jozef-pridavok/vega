@echo off

set "REQUIRED=vega_app"

set "CURRENT=%cd%"
for %%I in ("%CURRENT%") do set "BASENAME=%%~nI"

if not "%BASENAME%"=="%REQUIRED%" (
    echo Run this script from %REQUIRED% directory. You are in %BASENAME% directory.
    exit /b 1
)

vtc lang google-sheet --keys .\lib\keys.dart --output .\asserts\langs\ --url "https://docs.google.com/spreadsheets/d/e/2PACX-1vSUsPxkfwS0J_JLpo4NaVFL8oQpdSonpJA4KY5xMJRxnJrZ2Z80GFqwMeuCePQYrgHkfZHWSiJPEmbC/pub?gid=1338362051&single=true&output=tsv"
