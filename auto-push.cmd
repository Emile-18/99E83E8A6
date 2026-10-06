@echo off
chcp 65001 >nul
title 一条龙：建仓库 + 推送
setlocal

REM ============================================================
REM  本机专用脚本（路径 / 代理端口写死在本段，换机器要改）
REM  machine-specific helper
REM ============================================================
set "REPO=C:\Users\wanya\Desktop\新建文件夹"
set "PROXY=http://127.0.0.1:12450"
set "GCM=C:/Program Files/Git/ucrt64/bin/git-credential-manager.exe"
set "GHUSER=Emile-18"
set "GHREPO=%E6%99%BA%E8%83%BD%E8%BD%A6"
set "GHREPO_URL=https://github.com/Emile-18/%E6%99%BA%E8%83%BD%E8%BD%A6.git"
set "LOG=%REPO%\.git\push-log.txt"
set "BODY=%REPO%\.git\gh-body.txt"
set "CODE=%REPO%\.git\gh-code.txt"

cd /d "%REPO%"
if errorlevel 1 goto norepo

echo ================================================
echo   一条龙：建仓库 + 推送
echo   账号: %GHUSER%    仓库: 智能车
echo ================================================
echo.
echo   流程: 1 检查仓库  -^>  2 不存在就建  -^>  3 推送
echo.

REM ---------- 第 1 步：检查仓库是否存在 ----------
echo [1/3] 检查远程仓库是否存在...
curl.exe -s -o "%BODY%" -w "%%{http_code}" --max-time 25 --proxy %PROXY% --ssl-no-revoke -H "User-Agent: dsh" "https://api.github.com/repos/%GHUSER%/%GHREPO%" > "%CODE%" 2>nul
set /p HC=<"%CODE%"
echo         HTTP %HC%     (404 = 还没建, 200 = 已存在)

if "%HC%"=="200" goto dopush
if "%HC%"=="404" goto create

echo.
echo         网络检查没成功（代理可能没开，或端口变了）。
echo         本脚本按 http://127.0.0.1:12450 使用代理。
echo         请确认代理软件开着，然后重新双击本脚本。
goto end

REM ---------- 第 2 步：创建仓库 ----------
:create
echo.
echo [2/3] 创建空仓库
echo.
echo       需要一个 GitHub Token（只用于建仓库）:
echo         1. 浏览器打开  https://github.com/settings/tokens
echo         2. 点 Generate new token (classic)
echo         3. 勾选 repo 这一项，其它不用勾
echo         4. 拉到最下面点 Generate token
echo         5. 复制那串 ghp_ 开头的字符（只显示一次）
echo.
echo       粘贴 token 后按回车（粘贴时屏幕上不显示内容是正常的）。
echo       不想弄 token: 关掉窗口，用浏览器打开
echo       https://github.com/new  手动建一个叫 智能车 的空仓库
echo       （不要勾任何 README / license），然后重新双击本脚本。
echo.
set "TOK="
set /p "TOK=Paste token here: "
if "%TOK%"=="" goto notoken
echo.
echo       正在创建...
curl.exe -s -o "%BODY%" -w "%%{http_code}" -X POST --max-time 30 --proxy %PROXY% --ssl-no-revoke -H "Authorization: Bearer %TOK%" -H "User-Agent: dsh" -H "Content-Type: application/json" -d "{\"name\":\"%GHREPO%\",\"private\":false,\"auto_init\":false}" https://api.github.com/user/repos > "%CODE%" 2>nul
set /p HC=<"%CODE%"
echo       GitHub 返回: HTTP %HC%     (201 = 创建成功)
if not "%HC%"=="201" (
  echo.
  echo        创建失败，这是 GitHub 的原始回复:
  type "%BODY%"
  echo.
  echo        常见原因:
  echo          - token 复制不全、已过期，或没勾 repo 权限
  echo          - 这个名字已经存在了
  goto end
)
goto dopush

REM ---------- 第 3 步：推送 ----------
:dopush
echo.
if "%HC%"=="200" (
  echo [2/3] 建仓库  -- 已存在，跳过
) else (
  echo [2/3] 建仓库  -- 创建成功
)
echo.
echo [3/3] 推送代码
echo.
echo       正在推送... 首次会弹出浏览器让你登录 GitHub。
echo       不要关这个窗口，等它跑完。
echo.
git remote set-url origin "%GHREPO_URL%"
git -c http.proxy=%PROXY% -c credential.helper="%GCM%" push -u origin main > "%LOG%" 2>&1
set "RC=%errorlevel%"
type "%LOG%"
goto result

:result
echo.
echo ================================================
if "%RC%"=="0" (
  echo   全部成功！
  echo   打开 https://github.com/%GHUSER% 就能看到仓库了。
) else (
  echo   推送失败，错误码 %RC%
  echo   日志: %LOG%
  echo   把这一屏拍照，或把日志文件发给 AI 助手。
)
echo ================================================
goto end

:notoken
echo.
echo       没有输入 token，退出。
echo       手动建仓库: https://github.com/new
goto end

:norepo
echo 打不开文件夹: %REPO%
echo 文件夹可能被移动或改名了。
goto end

:end
echo.
echo 按任意键关闭窗口...
pause >nul
endlocal
