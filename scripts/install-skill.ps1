$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$TargetDir = Join-Path $HOME ".claude\skills\suno"
New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
Copy-Item -Force (Join-Path $Root "skills\suno\SKILL.md") (Join-Path $TargetDir "SKILL.md")

Write-Host "Installed Suno Claude Skill to: $TargetDir\SKILL.md"
Write-Host "Restart Claude Code / your Claude agent session if the skill list does not refresh automatically."
