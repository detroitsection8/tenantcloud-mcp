# Team setup: TenantCloud in Claude Code

This is our private copy of an unofficial TenantCloud connector (originally by Eric Ma, `ericmanyc/tenantcloud-client-ts`). It was reviewed on 2026-10-05.

**Do not** use `npx tc-mcp`, which you'll see in the README and online. That name on npm belongs to an unrelated project. Only install from this repo.

## Before you start

- A Mac with **Claude Code** installed
- Access to this GitHub repo (ask Kirtan)
- Your **own TenantCloud team login**. Don't use anyone else's.

## Setup (about 5 minutes)

Open Terminal and paste these two commands, one at a time:

```bash
git clone https://github.com/detroitsection8/tenantcloud-mcp.git ~/tools/tenantcloud-mcp
```

```bash
bash ~/tools/tenantcloud-mcp/setup.sh
```

If GitHub asks you to sign in during the first command, sign in with your GitHub account.

The second command checks your computer, builds the tool, connects it to Claude Code, and opens a TenantCloud sign-in window. Sign in as usual. Your login is saved in your Mac's Keychain.

Then **fully quit Claude Code (Cmd+Q)** and reopen it.

If the script stops with a message (for example "Node.js isn't installed"), do what it says, then run the second command again.

## Ground rules

- The tool acts as **you** in TenantCloud, and it can make real changes (payments, leases, messages, deletions). Have Claude show you what it will do before anything is changed.
- Logged out? Run `node ~/tools/tenantcloud-mcp/packages/mcp/dist/cli.js login`.
- Updates: pull the latest code (`cd ~/tools/tenantcloud-mcp && git pull`), then run `bash setup.sh` again.
