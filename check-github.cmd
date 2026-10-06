@echo off
chcp 65001 >nul
title GitHub 仓库检查与创建
setlocal
set "PROXY=http://127.0.0.1:12450"
set "USERNAME=Emile-18"
set "REPO_CN=%E6%99%BA%E8%83%BD%E8%BD%A6"
set "REPO_EN=smart-car"

echo ================================================
echo   GitHub 仓库检查 / 创建
echo   账号: %USERNAME%
echo ================================================
echo.
echo   需要 Personal Access Token 才能查询和创建仓库。
echo   获取方法: 浏览器打开 https://github.com/settings/tokens
echo             Generate new token (classic)
echo             勾选 repo 这一项，生成后复制那串 ghp_ 开头的字符
echo.
echo   不想用 token: 现在关掉窗口，直接用浏览器打开
echo   https://github.com/new 手动建一个空仓库（不要勾任何 README）
echo.
set "TOK="
set /p "TOK=Paste token here then press Enter: "
echo.

if "%TOK%"=="" (
  echo 没有输入 token，退出。
  goto end
)

echo --- 1. 检查 token 是否有效 ---
curl.exe -s --max-time 25 --proxy %PROXY% --ssl-no-revoke -H "Authorization: Bearer %TOK%" -H "User-Agent: dsh" https://api.github.com/user
echo.
echo.

echo --- 2. 检查「智能车」仓库是否存在 ---
curl.exe -s -o NUL -w "HTTP %%{http_code}   (404 = 不存在, 200 = 已存在)`n" --max-time 25 --proxy %PROXY% --ssl-no-revoke -H "Authorization: Bearer %TOK%" -H "User-Agent: dsh" "https://api.github.com/repos/%USERNAME%/%REPO_CN%"
echo.

echo --- 3. 你的仓库列表 ---
curl.exe -s --max-time 25 --proxy %PROXY% --ssl-no-revoke -H "Authorization: Bearer %TOK%" -H "User-Agent: dsh" "https://api.github.com/user/repos?per_page=100&sort=updated" | findstr /C:"\"full_name\""
echo.
echo.

echo ================================================
echo   要创建仓库吗？
echo   [回车] = 创建「智能车」（中文名）
echo   [ e ]  = 改建成英文名 smart-car（推荐，链接更干净）
echo   [ n ]  = 不创建，退出
echo ================================================
set "CH="
set /p "CH=选择: "

if /i "%CH%"=="n" goto end
if /i "%CH%"=="e" goto create_en
goto create_cn

:create_cn
set "NAME=%REPO_CN%"
set "SHOWN=智能车"
goto docreate

:create_en
set "NAME=%REPO_EN%"
set "SHOWN=smart-car"
goto docreate

:docreate
echo.
echo 正在创建仓库 %SHOWN% ...
curl.exe -s -X POST --max-time 30 --proxy %PROXY% --ssl-no-revoke -H "Authorization: Bearer %TOK%" -H "User-Agent: dsh" -H "Content-Type: application/json" -d "{\"name\":\"%NAME%\",\"private\":false,\"auto_init\":false}" https://api.github.com/user/repos
echo.
echo.
echo --- 创建后再查一次 ---
curl.exe -s -o NUL -w "HTTP %%{http_code}   (201 或 200 表示成功)`n" --max-time 25 --proxy %PROXY% --ssl-no-revoke -H "Authorization: Bearer %TOK%" -H "User-Agent: dsh" "https://api.github.com/repos/%USERNAME%/%NAME%"
echo.
echo 如果上面显示失败，把这一屏截图发给 AI 助手。

:end
echo.
echo ================================================
echo   结束
echo ================================================
echo.
echo 按任意键关闭窗口...
pause >nul
endlocal
