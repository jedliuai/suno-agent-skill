> **Chatgpt代充：[aishopvip.com](https://aishopvip.com)**

# suno-agent-skill

English | [中文](README.zh-CN.md)

A Claude Agent Skill + bundled Rust source for [`suno-cli`](https://github.com/paperfoot/suno-cli), designed to help Claude agents generate, download, and manage Suno AI music from local terminal workflows.

This repository packages:

- **Claude Skill**: `skills/suno/SKILL.md`
- **Suno CLI Rust source**: the `src/`, `Cargo.toml`, and related project files
- **Install scripts** for copying the skill into `~/.claude/skills/suno/`
- **Auth recovery notes** for the real-world Suno / Clerk / hCaptcha flow

> This project is not affiliated with Suno. Use responsibly and follow Suno's terms of service.

## Why this exists

Suno authentication can be confusing for local CLI usage because modern browser cookies are often encrypted and hard for command-line tools to extract. In practice, a Claude agent may need to recover auth from a logged-in browser request, write the local CLI auth config, and then let the CLI handle hCaptcha for generation.

This skill documents that workflow so future Claude sessions can solve the same problem quickly.

## Repository layout

```text
.
├── skills/suno/SKILL.md      # Claude Skill instructions
├── scripts/install-skill.ps1 # Windows skill installer
├── scripts/install-skill.sh  # macOS/Linux/Git Bash skill installer
├── src/                      # bundled suno-cli Rust source
├── Cargo.toml
├── Cargo.lock
├── README.md                 # English README
└── README.zh-CN.md           # Chinese README
```

## Install the Claude Skill

### Windows PowerShell

```powershell
.\scripts\install-skill.ps1
```

### macOS / Linux / Git Bash

```bash
bash scripts/install-skill.sh
```

The skill will be copied to:

```text
~/.claude/skills/suno/SKILL.md
```

Restart Claude Code / your Claude agent session if the skill list does not refresh automatically.

## Build the bundled CLI from source

Install Rust first if you do not have it:

```bash
# https://rustup.rs/
rustc --version
cargo --version
```

Build release binary:

```bash
cargo build --release
```

The binary will be generated at:

```text
target/release/suno
# or target/release/suno.exe on Windows
```

Optional: copy it to a directory in your PATH, for example:

```powershell
# Windows example
New-Item -ItemType Directory -Force "$HOME\.local\bin"
Copy-Item .\target\release\suno.exe "$HOME\.local\bin\suno.exe" -Force
```

## Basic CLI usage

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

Generated MP3 downloads can include embedded ID3 lyrics, including synced lyrics when available.

## Claude usage examples

After installing the skill, ask Claude:

```text
Use the suno skill and the local suno CLI to generate a Chinese pop song, then download the MP3, cover image, metadata, and timed lyrics.
```

or:

```text
使用 suno skill，通过本机 suno CLI 帮我生成一首歌，并下载所有可用元素。
```

## Auth recovery workflow

If the CLI reports:

- `auth_expired`
- `JWT expired or rejected by Suno`
- `Token validation failed`

A practical recovery path is:

1. Open `https://suno.com` in the normal browser profile where you are already logged in.
2. Open DevTools → Network.
3. Click any request to `studio-api-prod.suno.com`.
4. Copy → Copy as cURL.
5. Let the Claude agent read the local clipboard without printing secrets.
6. Extract:
   - `authorization: Bearer <JWT>`
   - `device-id: <uuid>`
7. Write the CLI auth config:

Windows:

```text
%APPDATA%\suno-cli\suno-cli\config\auth.json
```

Example shape:

```json
{
  "jwt": "<JWT>",
  "cookie": null,
  "session_id": null,
  "device_id": "<device-id>",
  "clerk_client_cookie": null
}
```

8. Run generation normally and **do not** pass `--no-captcha`; the CLI needs its browser-backed hCaptcha solver for generation.

## Proxy example

If you use Clash or a local proxy:

```bash
HTTP_PROXY=http://127.0.0.1:7897 \
HTTPS_PROXY=http://127.0.0.1:7897 \
ALL_PROXY=socks5://127.0.0.1:7897 \
suno credits
```

Windows Git Bash uses the same syntax. In PowerShell:

```powershell
$env:HTTP_PROXY="http://127.0.0.1:7897"
$env:HTTPS_PROXY="http://127.0.0.1:7897"
$env:ALL_PROXY="socks5://127.0.0.1:7897"
suno credits
```

## Security notes

- Never commit `auth.json`, JWTs, cookies, browser profiles, or generated credentials.
- The skill intentionally says not to print secrets while extracting browser request headers.
- JWTs are short-lived; Clerk cookies can be sensitive and should be protected.
- Review source code before running any CLI that interacts with browser cookies or auth tokens.

## License

See [LICENSE](LICENSE).

This repository bundles source derived from the upstream `suno-cli` project. Check upstream licensing and terms before redistribution or commercial use.
