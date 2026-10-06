# One-step setup of the TenantCloud connector (tc-mcp) on Windows, for the Claude desktop app and Claude Code.
# Easiest: right-click setup.ps1 > "Run with PowerShell".
# Or in PowerShell:  powershell -ExecutionPolicy Bypass -File "<folder>\setup.ps1"
# Safe to re-run: it rebuilds and re-registers. Run it again after pulling updates.
$ErrorActionPreference = "Stop"

$RepoDir = $PSScriptRoot
$Cli = Join-Path $RepoDir "packages\mcp\dist\cli.js"

function Say($msg)  { Write-Host "`n$msg" -ForegroundColor Cyan }
function Fail($msg) { Write-Host "`nStopped: $msg" -ForegroundColor Red; Read-Host "Press Enter to close"; exit 1 }
function Has($cmd)  { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

Say "1/4  Checking this computer has what it needs..."
if (-not (Has "node")) { Fail "Node.js isn't installed. Download the LTS version from https://nodejs.org, install it, CLOSE and reopen PowerShell, then run this again." }
$NodeMajor = [int](& node -p "process.versions.node.split('.')[0]")
if ($NodeMajor -lt 20) { Fail "Node.js is too old (version $NodeMajor). Install the LTS version from https://nodejs.org, then run this again." }
$HasClaudeCode = Has "claude"
Write-Host "OK: Node $(& node -v). Claude Code command line: $(if ($HasClaudeCode) {'found'} else {'not found (fine; setting up the Claude desktop app only)'})."

Say "2/4  Downloading supporting software and building (1-2 minutes)..."
Set-Location $RepoDir
# npm.cmd (not npm) sidesteps PowerShell's script-blocking policy for npm.ps1.
& npm.cmd ci --cache "$env:TEMP\tc-mcp-npm-cache" --no-audit --no-fund
if ($LASTEXITCODE -ne 0) { Fail "Downloading supporting software failed (see the messages above)." }
& npm.cmd run build
if ($LASTEXITCODE -ne 0) { Fail "The build failed (see the messages above)." }
if (-not (Test-Path $Cli)) { Fail "The build finished but $Cli is missing." }

Say "3/4  Connecting it to Claude..."
# Claude desktop app (chat): writes %APPDATA%\Claude\claude_desktop_config.json, with the required "mcp" argument.
& node "$Cli" install claude-desktop
if ($LASTEXITCODE -ne 0) { Fail "Couldn't connect it to the Claude desktop app (see the messages above)." }
if ($HasClaudeCode) {
  # Clear any earlier registration; "not found" errors here are expected and ignored.
  foreach ($scope in @("user", "local")) {
    try { & claude mcp remove tc-mcp -s $scope 2>&1 | Out-Null } catch { }
  }
  # The trailing "mcp" is required; without it the tool prints help and exits.
  & claude mcp add --scope user --transport stdio tc-mcp -- node "$Cli" mcp
  if ($LASTEXITCODE -ne 0) { Fail "Couldn't connect it to Claude Code (see the messages above)." }
}

Say "4/4  Sign in to TenantCloud with YOUR OWN login (a window will open)..."
& node "$Cli" login
if ($LASTEXITCODE -ne 0) { Fail "Sign-in didn't finish. Run this to try again:  node `"$Cli`" login" }

Say "Done. Fully quit Claude (right-click its icon in the taskbar > Quit), reopen it, and ask: `"How many properties do we have in TenantCloud?`""
Read-Host "Press Enter to close"
