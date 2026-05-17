# suno-agent-skill

[English](README.md) | 中文

这是一个 **Claude Agent Skill + Suno CLI Rust 源码整合仓库**，用于让 Claude Agent 更方便地在本地终端调用 Suno，完成 AI 音乐生成、下载、歌词、封面、元数据等流程。

本仓库包含：

- **Claude Skill**：`skills/suno/SKILL.md`
- **Suno CLI Rust 源码**：`src/`、`Cargo.toml`、`Cargo.lock` 等
- **Skill 安装脚本**：一键复制到 `~/.claude/skills/suno/`
- **鉴权恢复流程说明**：针对 Suno / Clerk / hCaptcha 的实际问题整理

> 本项目与 Suno 官方无关。请遵守 Suno 的服务条款，并合理使用。

## 为什么做这个仓库

Suno 的本地 CLI 鉴权并不总是顺利。现代浏览器 Cookie 经常被加密，CLI 很难直接读取；而生成歌曲时又可能需要 hCaptcha 验证。

实际可行的流程通常是：

1. 用户已经在正常浏览器里登录 Suno；
2. 从浏览器 DevTools 的 Network 请求中复制 cURL；
3. Claude Agent 从本地剪贴板提取 JWT 和 device-id；
4. 写入本地 `suno-cli` 的 auth 配置；
5. 生成歌曲时让 CLI 自动启动 Chrome 处理 hCaptcha。

这个 Skill 把这套经验写成可复用说明，方便以后在别的项目里快速调用。

## 仓库结构

```text
.
├── skills/suno/SKILL.md      # Claude Skill 说明文件
├── scripts/install-skill.ps1 # Windows PowerShell 安装脚本
├── scripts/install-skill.sh  # macOS/Linux/Git Bash 安装脚本
├── src/                      # 内置 suno-cli Rust 源码
├── Cargo.toml
├── Cargo.lock
├── README.md                 # 英文说明
└── README.zh-CN.md           # 中文说明
```

## 安装 Claude Skill

### Windows PowerShell

```powershell
.\scripts\install-skill.ps1
```

### macOS / Linux / Git Bash

```bash
bash scripts/install-skill.sh
```

安装后 Skill 会被复制到：

```text
~/.claude/skills/suno/SKILL.md
```

如果 Claude Code / Claude Agent 没有立刻识别，请重启当前 Claude 会话。

## 从源码构建内置 CLI

如果电脑还没有 Rust，请先安装：

```bash
# https://rustup.rs/
rustc --version
cargo --version
```

构建 release 版本：

```bash
cargo build --release
```

生成的二进制文件在：

```text
target/release/suno
# Windows 是 target/release/suno.exe
```

Windows 下可以复制到常用 PATH 目录：

```powershell
New-Item -ItemType Directory -Force "$HOME\.local\bin"
Copy-Item .\target\release\suno.exe "$HOME\.local\bin\suno.exe" -Force
```

## 基本 CLI 用法

```bash
suno credits
suno models

suno generate \
  --title "Midnight Frequency" \
  --tags "cinematic synth-pop, female vocal, emotional chorus" \
  --lyrics-file lyrics.txt \
  --model v5.5 \
  --vocal female \
  --wait \
  --download ./out
```

下载的 MP3 可以自动写入 ID3 歌词标签；如果 Suno 返回了时间轴歌词，也可以写入同步歌词。

## Claude 调用示例

安装 Skill 后，可以对 Claude 说：

```text
使用 suno skill，通过本机 suno CLI 帮我生成一首中文流行歌，并下载 MP3、封面、元数据、时间轴歌词。
```

或者：

```text
Use the suno skill and the local suno CLI to generate a song and download all available assets.
```

## 鉴权恢复流程

如果 CLI 报错：

- `auth_expired`
- `JWT expired or rejected by Suno`
- `Token validation failed`

可以使用下面的快速恢复流程：

1. 在已经登录 Suno 的正常 Chrome / Edge 浏览器里打开 `https://suno.com`。
2. 打开 DevTools → Network。
3. 点击任意 `studio-api-prod.suno.com` 请求。
4. 右键 Copy → Copy as cURL。
5. 让 Claude Agent 在本地读取剪贴板，但不要把密钥打印出来。
6. 提取：
   - `authorization: Bearer <JWT>`
   - `device-id: <uuid>`
7. 写入 CLI 鉴权配置。

Windows 路径：

```text
%APPDATA%\suno-cli\suno-cli\config\auth.json
```

文件结构示例：

```json
{
  "jwt": "<JWT>",
  "cookie": null,
  "session_id": null,
  "device_id": "<device-id>",
  "clerk_client_cookie": null
}
```

8. 生成歌曲时正常运行，不要加 `--no-captcha`。CLI 需要自动启动浏览器来处理 hCaptcha。

## 代理示例

如果使用 Clash，本机代理端口是 `127.0.0.1:7897`，可以这样运行：

```bash
HTTP_PROXY=http://127.0.0.1:7897 \
HTTPS_PROXY=http://127.0.0.1:7897 \
ALL_PROXY=socks5://127.0.0.1:7897 \
suno credits
```

PowerShell 写法：

```powershell
$env:HTTP_PROXY="http://127.0.0.1:7897"
$env:HTTPS_PROXY="http://127.0.0.1:7897"
$env:ALL_PROXY="socks5://127.0.0.1:7897"
suno credits
```

## 安全提示

- 不要提交 `auth.json`、JWT、Cookie、浏览器用户数据、生成的密钥等敏感文件。
- Skill 明确要求 Claude 在提取浏览器请求头时不要打印密钥。
- JWT 有时效；Clerk Cookie 更敏感，必须妥善保管。
- 运行任何会读取浏览器 Cookie 或认证信息的 CLI 之前，都建议先审查源码。

## 许可证

见 [LICENSE](LICENSE)。

本仓库包含来自上游 `suno-cli` 的源码。重新分发或商用前，请自行确认上游许可证和相关服务条款。
