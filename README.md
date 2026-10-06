# 项目名称

在这里写一句话介绍这个项目是做什么的。

## 使用方法

```bash
# 安装依赖
# 运行
```

## 目录结构

```
.
├── README.md
├── .gitignore
├── .gitattributes
└── push-to-github.cmd      # 本机专用的推送助手，双击即可运行
```

## 推送到 GitHub

已配置好远程仓库 `origin`，推送方式二选一：

**方式一：双击 `push-to-github.cmd`**，直接按回车即可（首次会自动打开浏览器登录 GitHub）。

**方式二：命令行**

```bash
git push -u origin main
```

> 注意：本机 `github.com` 走本地代理（`127.0.0.1:12450`），git 不读取 Windows 系统代理设置。
> 若直连超时，先执行一次 `git config http.proxy http://127.0.0.1:12450` 即可。
> 代理端口变了用 `git config --unset http.proxy` 撤掉。


## 说明

（在这里补充说明、联系方式或致谢。）
