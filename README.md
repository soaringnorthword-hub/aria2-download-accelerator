# aria2 Download Accelerator for Windows · Windows 下载加速脚本

**浏览器下载太慢？下到一半断了就要重新开始？**
这个项目用 [aria2](https://aria2.github.io/) 把浏览器的单线程下载换成 **16 线程分片传输** —— 断点续传、断线自动重试、不限速。

**Browser downloads too slow? Tired of restarting from zero after a dropout?**
This project replaces the browser's single-connection download with a **16-connection segmented transfer** — resumable, auto-retrying, no speed cap.

[English](#english) · [简体中文](#简体中文)

---

## English

### The problem

Chrome, Edge and Firefox download a file over **one TCP connection**. That means:

- One connection's throughput is your ceiling, even if your line could do more.
- When the connection drops (Wi-Fi hiccup, proxy reset, server timeout), the transfer stops.
- Resume only works if the server advertises `Accept-Ranges: bytes`. If not, you start over from byte 0.

A "download accelerator" browser extension cannot fix this. Under Manifest V3, extensions can no longer drive the browser's download engine at that level. What actually works is handing the URL to a downloader that speaks HTTP Range natively.

### What this repo does

Three batch scripts and one config file. No installer, no service, no registry writes.

| File | Purpose |
|---|---|
| `install.bat` | Downloads `aria2c.exe` from the official aria2 GitHub release |
| `dl.bat` | Paste a link, download with 16 connections + resume + unlimited retry |
| `rpc.bat` | Runs aria2 as a local RPC server so a browser extension can take over downloads |
| `aria2.conf` | Shared settings: 16 connections, 1 MiB minimum split, retry every 5s, session save |

### Quick start

```bat
:: 1. get the engine (once)
install.bat

:: 2. download anything
dl.bat
::    then paste the URL and press Enter
```

Or drag a link onto `dl.bat`. Files land in the `downloads` folder next to the scripts.

### Browser takeover (optional)

1. Run `rpc.bat` and keep the window open.
2. Install **Aria2 Explorer** or **Aria2 Integration** in your browser.
   Both are listed on the official [aria2 GUI page](https://aria2.org/gui).
3. Point the extension at:
   - RPC endpoint: `http://127.0.0.1:6800/jsonrpc`
   - Secret: `workbuddy6800` (change it in `aria2.conf`)
4. Every download the browser starts is now routed to aria2.

### The hard limit — read this before complaining

Segmented downloading requires the server to support byte ranges:

- Response header contains `Accept-Ranges: bytes`
- A ranged request returns **206 Partial Content**, not 200

If the server does not support ranges, **nothing** can speed it up — not this script, not IDM, not any download manager. aria2 will silently fall back to a single connection. That is physics, not a bug.

Check it yourself:

```bash
curl -I -H "Range: bytes=0-1023" "https://example.com/file.zip"
# 206 + Accept-Ranges: bytes  -> segmented download works
# 200                         -> single connection only
```

### Why not just install a download manager?

You can — IDM, Motrix, Free Download Manager all work. This repo exists because the whole thing is ~4 KB of text plus one binary, it needs no installation, and you can read every line before running it.

### FAQ

**Is it safe?**
The scripts are plain batch files you can read in a text editor. `aria2c.exe` is downloaded from the official `aria2/aria2` GitHub release — verify the hash yourself if you want. No telemetry, no background service, no registry changes.

**Does it work on Windows 7?**
Only if `curl.exe` and `tar.exe` exist (Windows 10 1803+ ships both). On older systems, download the zip manually and drop `aria2c.exe` next to `dl.bat`.

**Download stopped, do I lose progress?**
No. aria2 writes a `.aria2` control file next to the target. Run the same URL again and it resumes. **Do not delete the `.aria2` file** — that is your progress.

**Why is the file huge on disk while progress shows 1%?**
aria2 extends the file to its final length up front, so Explorer shows the full size. Actual downloaded bytes are what the console reports.

**Can it download multiple files at once?**
Yes, run `dl.bat` several times, or use `aria2c -i list.txt` with one URL per line.

### License

MIT for the scripts. `aria2c.exe` is GPLv2 by Tatsuhiro Tsujikawa and is **not** redistributed here — `install.bat` fetches it from the official release.

---

## 简体中文

### 问题出在哪

Chrome、Edge、Firefox 下载文件时**只开一条 TCP 连接**。后果是：

- 单连接的吞吐就是你的速度上限，线路再宽也用不上。
- 连接一断（Wi-Fi 抖动、代理重置、服务器超时），传输就停了。
- 能否续传取决于服务器是否声明 `Accept-Ranges: bytes`；不支持就只能从第 0 字节重新开始。

浏览器"下载加速插件"解决不了这件事。MV3 之后扩展已经拿不到下载引擎的控制权。真正有效的做法是把链接交给原生支持 HTTP Range 的**多线程下载器**（aria2 就是），这也是所有"下载加速"工具背后唯一成立的原理：把一个文件切成多片，用多条连接同时拉。

### 这个仓库做了什么

三个批处理脚本加一个配置文件。不装软件、不注册服务、不写注册表。

| 文件 | 作用 |
|---|---|
| `install.bat` | 从 aria2 官方 GitHub release 下载 `aria2c.exe` |
| `dl.bat` | 粘贴链接即下载，16 线程 + 断点续传 + 无限重试 |
| `rpc.bat` | 把 aria2 起成本地 RPC 服务，供浏览器扩展接管下载 |
| `aria2.conf` | 统一配置：16 连接、最小分片 1 MiB、5 秒重试、会话保存 |

### 三步开始

```bat
:: 1. 先拿引擎（只需一次）
install.bat

:: 2. 下载任何文件
dl.bat
::    粘贴链接，回车
```

也可以直接把链接拖到 `dl.bat` 图标上。文件默认存到脚本旁边的 `downloads` 文件夹。

### 让浏览器自动接管（可选）

1. 双击 `rpc.bat`，窗口留着别关。
2. 浏览器里装 **Aria2 Explorer** 或 **Aria2 Integration**（aria2 官方 [GUI 页面](https://aria2.org/gui) 列出的两个仍在维护的扩展）。
3. 扩展设置里填：
   - RPC 地址：`http://127.0.0.1:6800/jsonrpc`
   - 密钥：`workbuddy6800`（可改 `aria2.conf`）
4. 之后浏览器点下载会被自动转给 aria2，多线程 + 断点续传。

### 硬限制 —— 抱怨之前先看这条

分片下载的前提是服务器支持字节范围请求：

- 响应头里有 `Accept-Ranges: bytes`
- 带 Range 的请求返回 **206 Partial Content**，而不是 200

服务器不支持的话，**任何工具都救不了**——不是这个脚本不行，IDM 也不行。aria2 会自动退化成单连接。这是协议决定的，不是 bug。

自己验证一下：

```bash
curl -I -H "Range: bytes=0-1023" "https://example.com/file.zip"
# 206 + Accept-Ranges: bytes  -> 可以分片加速
# 200                         -> 只能单连接
```

### 为什么不直接用 IDM

可以，IDM、Motrix、Free Download Manager 都能干这活。这个仓库存在的理由是：全部内容只有几 KB 文本加一个二进制，免安装，而且每一行你都能读完再运行。

### 常见问题

**安全吗？**
脚本是纯批处理，记事本能打开逐行看。`aria2c.exe` 从 `aria2/aria2` 官方 release 下载，你可以自己校验哈希。没有遥测、没有后台服务、不写注册表。

**这个下载加速脚本和浏览器扩展有什么区别？**
扩展改不了浏览器内核的单连接限制，也拿不到分片写入磁盘的权限。这个脚本把下载整个交给 aria2，多线程下载、断点续传、断线重试都是下载器原生能力，所以才能真的加速，而不是把进度条做得好看一点。

**Windows 7 能用吗？**
需要 `curl.exe` 和 `tar.exe`（Windows 10 1803 之后自带）。老系统就手动下载 zip，把 `aria2c.exe` 放到 `dl.bat` 旁边。

**下到一半停了，进度会丢吗？**
不会。aria2 会在目标文件旁写一个 `.aria2` 控制文件，重跑同一个链接自动续传。**别删那个 `.aria2` 文件**，那是你的进度。

**进度才 1%，磁盘上文件却已经是完整大小？**
aria2 会先把文件长度撑到最终大小，资源管理器显示的是这个长度。真实下载量看控制台里的 `x.xGiB/总量`。

**能同时下多个文件吗？**
可以，多开几个 `dl.bat`；或用 `aria2c -i list.txt`，一行一个链接。

### 许可证

脚本用 MIT。`aria2c.exe` 是 Tatsuhiro Tsujikawa 的 GPLv2 作品，本仓库**不再分发**该二进制，由 `install.bat` 从官方 release 获取。

---

## Keywords / 关键词

download accelerator · multi-thread download · multi-connection download · resume download · broken download resume · speed up downloads · browser download slow · Chrome download slow · Edge download slow · download manager · aria2 · aria2c · IDM alternative · Windows batch script · HTTP Range · 206 Partial Content

下载加速 · 多线程下载 · 分片下载 · 断点续传 · 下载中断重新开始 · 浏览器下载慢 · 谷歌浏览器下载慢 · Edge 下载慢 · 文件下载加速 · 下载速度慢怎么办 · 下载器 · 不限速下载 · Windows 批处理 · 免安装下载工具
