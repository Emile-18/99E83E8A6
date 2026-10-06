@echo off
chcp 65001 >nul
title Push to GitHub - Emile-18 / 智能车
setlocal

REM ============================================================
REM  这个脚本是本机专用（下面的路径和代理端口是写死的）
REM  local-only helper: the paths and proxy port below are
REM  machine specific - adjust them if you clone this elsewhere.
REM ============================================================
set "REPO=C:\Users\wanya\Desktop\新建文件夹"
set "PROXY=http://127.0.0.1:12450"
set "GCM=C:/Program Files/Git/ucrt64/bin/git-credential-manager.exe"
set "CACHE=%REPO%\.git\push-log.txt"

cd /d "%REPO%"
if errorlevel 1 goto norepo

echo ================================================
echo   推送到 GitHub
echo   仓库: Emile-18 / 智能车
echo ================================================
echo.
echo   [回车]  推送到 GitHub（首次会自动打开浏览器登录）
echo   [ 2 ]   只看状态，不推送
echo   [ 3 ]   退出
echo.
set "CH="
set /p "CH=直接按回车键开始推送: "
if "%CH%"=="2" goto status
if "%CH%"=="3" goto end

echo.
echo 正在推送...  如果弹出浏览器，请登录你的 GitHub 账号授权。
echo 不要关这个窗口，等它跑完。
echo.
git -c http.proxy=%PROXY% -c credential.helper="%GCM%" push -u origin main > "%CACHE%" 2>&1
set "RC=%errorlevel%"
type "%CACHE%"
goto result

:status
echo.
echo --- 远程地址 ---
git remote -v
echo.
echo --- 提交记录 ---
git log --oneline -5
echo.
echo --- 本地状态 ---
git status --short --branch
echo.
echo --- GitHub 上的分支（需要网络）---
git -c http.proxy=%PROXY% -c credential.helper="%GCM%" ls-remote --heads origin > "%CACHE%" 2>&1
set "RC=%errorlevel%"
type "%CACHE%"
goto result

:result
echo.
echo ================================================
if "%RC%"=="0" (
  echo   推送成功！
  echo   打开 https://github.com/Emile-18 就能看到仓库了。
) else (
  echo   失败了，错误码 %RC%
  echo   详细日志已存到:
  echo   %CACHE%
  echo.
  echo   把上面显示的内容或这个日志文件发给 AI 助手，让它帮你判断。
)
echo ================================================
goto end

:norepo
echo 打不开文件夹: %REPO%
echo 文件夹可能被移动或改名了。

:end
echo.
echo 按任意键关闭窗口...
pause >nul
endlocal
