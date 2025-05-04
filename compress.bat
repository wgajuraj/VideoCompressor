@echo off
REM =============================================================================
REM Drag-and-Drop Compression Script using FFmpeg with NVIDIA NVENC (Hardware Decode)
REM Usage: Drag and drop a video file onto this .bat file to compress it using FFmpeg NVENC and NVDEC for faster encoding.
REM Requires FFmpeg installed and added to PATH, and an NVIDIA GPU with NVENC and NVDEC support.
REM Adjust VB (video bitrate), AB (audio bitrate), FPS, and NVENC preset below as desired.
REM =============================================================================

REM Ensure ffmpeg is available
where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo.
    echo FFMPEG not found in PATH. Please install FFmpeg and add it to your system PATH.
    echo Use "winget install ffmpeg" or download from https://ffmpeg.org/download.html
    echo.
    pause
    exit /b
)

REM Check for input file
if "%~1"=="" (
    echo.
    echo Usage: Drag and drop a video file onto this script to compress it.
    echo.
    pause
    exit /b
)

REM Setup variables
set "INPUT=%~1"
set "BASENAME=%~n1"
set "DIR=%~dp1"
set "OUTPUT=%DIR%%BASENAME%_compressed.mp4"
set "VB=10M"            REM Video bitrate (e.g., 10M = 10 Mbps)
set "AB=96k"            REM Audio bitrate (e.g., 96k = 96 kbps)
set "FPS=60"            REM Frame rate (must match source)
set "PRESET=p3"         REM NVENC preset (e.g., p1..p7)
set "USE_HWACCEL=1"     REM Default to using hardware acceleration (set to 0 to disable)

REM Display welcome message
echo.
echo ====================================================
echo   Starting compression of "%BASENAME%"
echo   Profile: NVENC H.265 (%VB%), AAC (%AB%), %FPS% fps, preset: %PRESET%
echo   Input: "%INPUT%"
echo   Output: "%OUTPUT%"
echo   Start time: %TIME%
echo ====================================================
echo.

REM Run FFmpeg via PowerShell to capture timing
if "%USE_HWACCEL%"=="1" (
    powershell -NoProfile -Command "& { $start = Get-Date; ffmpeg -y -hwaccel nvdec -threads 8 -i \"%INPUT%\" -c:v hevc_nvenc -preset %PRESET% -b:v %VB% -r %FPS% -c:a aac -b:a %AB% \"%OUTPUT%\"; $end = Get-Date; Write-Host ''; Write-Host '===================================================='; Write-Host 'Compression complete.'; Write-Host ('End time: {0}' -f $end.ToString('HH:mm:ss')); Write-Host ('Elapsed time: {0}' -f ($end - $start)); Write-Host '===================================================='; }"
) else (
    powershell -NoProfile -Command "& { $start = Get-Date; ffmpeg -y -i \"%INPUT%\" -c:v libx265 -preset medium -b:v %VB% -r %FPS% -c:a aac -b:a %AB% \"%OUTPUT%\"; $end = Get-Date; Write-Host ''; Write-Host '===================================================='; Write-Host 'Compression complete.'; Write-Host ('End time: {0}' -f $end.ToString('HH:mm:ss')); Write-Host ('Elapsed time: {0}' -f ($end - $start)); Write-Host '===================================================='; }"
)

echo.
pause
