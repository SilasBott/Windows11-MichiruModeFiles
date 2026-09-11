# ==============================================================================
# WINDOWS AUTOMATED SETUP SCRIPT
# Bitte als Administrator ausführen!
# ==============================================================================

# --- CONFIGURE YOUR URLS HERE ---
$ExeUrl        = "https://github.com/SilasBott/Windows11-MichiruModeFiles/raw/refs/heads/main/DesktopFocus.exe"  # Link zu deiner Python EXE
$VideoUrl      = "https://github.com/SilasBott/Windows11-MichiruModeFiles/raw/refs/heads/main/michiru-kagemori-in-the-night-train-moewalls-com.mp4"          # Link zu deinem Wallpaper-Video
$CursorUrl     = "https://github.com/SilasBott/Windows11-MichiruModeFiles/raw/refs/heads/main/michiru_blinking.ani"         # Link zu deinem Custom Cursor

# --- PFADE DEFINIEREN ---
$StartupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$TargetExe     = "$StartupFolder\DesktopFocus.exe"
$MediaFolder   = "$env:USERPROFILE\Pictures\AutomatedSetup"
$VideoPath     = "$MediaFolder\wallpaper.mp4"
$CursorPath    = "$MediaFolder\custom_cursor.cur"

New-Item -ItemType Directory -Force -Path $MediaFolder | Out-Null

Write-Host ">>> [1/6] Installiere Programme über WinGet..." -ForegroundColor Green
winget install --id Rocksdanister.Lively -e --silent --accept-source-agreements --accept-package-agreements
winget install --id TranslucentTB.TranslucentTB -e --silent --accept-source-agreements --accept-package-agreements

Write-Host ">>> [2/6] Lade Python-EXE herunter und füge sie zum Autostart hinzu..." -ForegroundColor Green
if ($ExeUrl -like "http*") {
    Invoke-WebRequest -Uri $ExeUrl -OutFile $TargetExe
    Write-Host "Python EXE im Autostart gespeichert: $TargetExe"
}

Write-Host ">>> [3/6] Passen Windows Multitasking & Settings an (Registry)..." -ForegroundColor Green
# Aero Shake aktivieren/deaktivieren (0 = aktiviert, 1 = deaktiviert)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking" -Value 0

# Fenster-Snapping / Andocken aktivieren
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WindowArrangementActive" -Value "1"

# Multitasking Alt+Tab (Alle Fenster anzeigen)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingALTABFilter" -Value 0

Write-Host ">>> [4/6] Lade Custom Cursor herunter & wende ihn an..." -ForegroundColor Green
if ($CursorUrl -like "http*") {
    Invoke-WebRequest -Uri $CursorUrl -OutFile $CursorPath
    
    # Cursor in Registry eintragen (Pfeil / Arrow Cursor)
    Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "Arrow" -Value $CursorPath
    
    # System anweisen, Cursor neu zu laden
    $CSharpCode = @"
    using System;
    using System.Runtime.InteropServices;
    public class CursorReloader {
        [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
        public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);
    }
"@
    Add-Type -TypeDefinition $CSharpCode
    [CursorReloader]::SystemParametersInfo(0x0057, 0, $null, 0x01 -bor 0x02) | Out-Null
}

Write-Host ">>> [5/6] Lade Video-Wallpaper herunter & wende es in Lively Wallpaper an..." -ForegroundColor Green
if ($VideoUrl -like "http*") {
    Invoke-WebRequest -Uri $VideoUrl -OutFile $VideoPath
    
    # Lively Command-Line Interface aufrufen
    $LivelyCli = "$env:LOCALAPPDATA\Programs\Lively Wallpaper\livelycu.exe"
    if (Test-Path $LivelyCli) {
        & $LivelyCli setwp --file "$VideoPath"
    } else {
        Write-Host "Lively CLI nicht gefunden unter standardmäßigem Pfad. Starten Sie Lively einmalig manuell." -ForegroundColor Yellow
    }
}

Write-Host ">>> [6/6] Starte Windows Debloat..." -ForegroundColor Green
# Führt das populäre Win11Debloat-Skript aus (entfernt Bloatware, Telemetrie & Werbung)
iwr -useb https://win11debloat.com | iex

Write-Host ">>> FERTIG! Das System wurde erfolgreich konfiguriert." -ForegroundColor Cyan