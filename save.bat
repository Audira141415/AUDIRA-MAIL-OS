@echo off
echo ==========================================
echo    AUDIRA-MAIL-OS Git Push Automation
echo ==========================================

:: Cek apakah folder sudah merupakan repositori git
if not exist .git (
    echo [INFO] Menginisialisasi repositori Git baru...
    git init
    git branch -M main
    git remote add origin https://github.com/Audira141415/AUDIRA-MAIL-OS.git
)

:: Pastikan branch adalah main
git branch -M main 2>nul

:: Tambahkan remote jika belum ada (akan error diam-diam jika sudah ada)
git remote add origin https://github.com/Audira141415/AUDIRA-MAIL-OS.git 2>nul

echo.
echo Menambahkan semua file ke staging...
git add .

echo.
set /p msg="Masukkan pesan commit (tekan Enter untuk default 'Auto-save update'): "
if "%msg%"=="" set msg=Auto-save update

echo.
echo Melakukan commit...
git commit -m "%msg%"

echo.
echo Mendorong ke GitHub repositori...
git push -u origin main

echo.
echo ==========================================
echo    Selesai! Push berhasil dieksekusi.
echo ==========================================
pause
