# Docker Launch & Quick Start Guide

> **One-command launch for the complete orchestration system using Docker**

This guide covers:
- **(A)** Launching with your own environment settings
- **(B)** Setting up from scratch after following the main guide

---

## Prerequisites

### Required Software

1. **Docker Desktop for Windows**
   - Download: https://www.docker.com/products/docker-desktop
   - Install with WSL 2 backend enabled
   - Restart computer after installation

2. **Your Credentials Ready:**
   - Discord Bot Token
   - Anthropic API Key (optional if using Pro subscription)
   - Discord Webhook URL

---

## Option A: Launch Existing Setup

**If you already have the automaton project and just want to start it:**

### Step A1: Configure Environment

```powershell
cd C:\dev\GIT\automaton
copy .env.template .env
notepad .env
```

**Fill in your values (NO quotes):**

```env
# Required - Your Discord bot token
DISCORD_BOT_TOKEN=MTxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Optional - Only if NOT using Pro subscription
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxxxxxxx

# Optional - Only if you need external webhooks
NGROK_AUTHTOKEN=your_ngrok_token_here
```

**Save and close.**

**IMPORTANT:** Remove all quotes from values!

### Step A2: Start Everything

```powershell
cd C:\dev\GIT\automaton
docker-compose up -d
```

**First time:** Takes 5-10 minutes to download images and build
**Subsequent starts:** Takes 10-30 seconds

### Step A3: Verify Status

```powershell
docker-compose ps
```

**Expected output:**
```
NAME                    STATUS
n8n-orchestration       Up
claude-code-runner      Up
discord-bot             Up
```

### Step A4: Access Services

**Open browser:**
- **n8n:** http://localhost:5678

**Check bot is running:**
```powershell
docker logs discord-bot
```

**Should show:**
```
✓ Discord bot logged in as YourBot#1234
✓ Forwarding to: http://n8n:5678/webhook/discord-claude
✓ Listening for: !claude <message>
```

### Step A5: Import Workflow (First Time Only)

**In n8n (http://localhost:5678):**

1. Create account (first launch only)
2. Click "..." menu → Import from File
3. Select: `C:\dev\GIT\automaton\workflows\4-discord-webhook-simple.json`
4. Click "Open"

### Step A6: Configure Workflow

**Configure SSH credentials:**

1. Click "Ask Claude" node
2. Create new credential:
   - **Credential Name:** `Claude Runner SSH`
   - **Host:** `claude-runner` (NOT localhost!)
   - **Port:** `22`
   - **Username:** `={{$env.SSH_USERNAME}}`
   - **Password:** `={{$env.SSH_PASSWORD}}`
3. Save

**Important:** Use the exact syntax `={{$env.SSH_USERNAME}}` to read from environment variables. See the "SSH Credentials" section below for details.

**Configure Discord webhook:**

1. Click "Send to Discord" node
2. **URL:** Your Discord webhook URL from Discord settings
3. **Method:** POST
4. **Body Content Type:** JSON
5. **Add field:**
   - Name: `content`
   - Value: `{{ $('Ask Claude').item.json.stdout }}`

### Step A7: Activate Workflow

1. Click "Save"
2. Toggle "Active" to ON

### Step A8: Test

**In Discord:**
```
!claude Hello from Docker!
```

**Expected:** Claude responds in Discord channel

---

## Option B: Complete Fresh Setup

**If you're setting this up from scratch on a new machine:**

### Step B1: Get the Files

**Option 1 - From GitHub (if shared):**
```powershell
cd C:\dev
git clone https://github.com/your-username/automaton.git
cd automaton
```

**Option 2 - Copy from shared folder:**
- Copy the entire `automaton` folder to `C:\dev\GIT\automaton`

### Step B2: Install Docker Desktop

1. Download from https://www.docker.com/products/docker-desktop
2. Run installer
3. Enable "Use WSL 2 instead of Hyper-V" during setup
4. Restart computer
5. Launch Docker Desktop
6. Wait for whale icon in system tray

### Step B3: Set Up Discord Bot

**Complete Discord bot setup using the dedicated guide:**

👉 **See:** [DISCORD-BOT-SETUP.md](DISCORD-BOT-SETUP.md)

You'll need to complete:
- Creating Discord application and bot (save the bot token)
- Enabling MESSAGE CONTENT INTENT
- Inviting bot to your Discord server
- Creating a webhook in your Discord channel (save the webhook URL)

**Save these values - you'll need them in Step B4!**

### Step B4: Get Anthropic Credentials

**Option 1 - API Key:**
1. Go to https://console.anthropic.com
2. Create API key
3. Copy and save it

**Option 2 - Pro Subscription:**
- Sign up for Claude Pro at https://claude.ai/pro
- You'll authenticate later in the container

### Step B5: Configure Environment

```powershell
cd C:\dev\GIT\automaton
copy .env.template .env
notepad .env
```

**Fill in (NO quotes):**

```env
DISCORD_BOT_TOKEN=your_bot_token_from_step_B3
ANTHROPIC_API_KEY=your_api_key_from_step_B4
```

**Save and close.**

### Step B6: Launch Docker

```powershell
docker-compose up -d
```

**Wait 5-10 minutes for first-time setup.**

### Step B7: Follow Steps A3-A8

Continue with Option A from Step A3 to complete setup.

---

## Daily Usage

### Start System

```powershell
cd C:\dev\GIT\automaton
docker-compose up -d
```

### Stop System

```powershell
docker-compose down
```

### View Logs

```powershell
# All containers
docker-compose logs

# Specific container
docker logs discord-bot
docker logs n8n-orchestration
docker logs claude-code-runner

# Follow logs (live)
docker logs -f discord-bot
```

### Restart a Service

```powershell
docker-compose restart discord-bot
docker-compose restart n8n
```

### Enter a Container

```powershell
# Enter Claude container
docker exec -it claude-code-runner bash

# Enter n8n container
docker exec -it n8n-orchestration sh
```

---

## File Access from Containers

**Your local files are mounted in containers:**

| Local Path | Container Path | Access |
|------------|----------------|--------|
| `C:\dev` | `/workspace` | Read/Write |
| `C:\dev\GIT\automaton` | `/workspace/GIT/automaton` | Read/Write |
| Your repos | `/workspace/your-repo` | Read/Write |

**Example workflow command:**
```bash
cd /workspace/my-project && claude -p "Analyze this codebase"
```

**Git operations work:**
```bash
cd /workspace && git clone https://github.com/user/repo
```

---

## Auto-Start on Boot

### Method 1: Docker Desktop Settings

1. Open Docker Desktop
2. Settings → General
3. ✅ Check "Start Docker Desktop when you log in"
4. Your containers auto-start (because `restart: unless-stopped`)

### Method 2: Task Scheduler

**Create startup batch file:**

`C:\dev\GIT\automaton\start-docker-on-boot.bat`:
```batch
@echo off
cd C:\dev\GIT\automaton
docker-compose up -d
```

**Add to Task Scheduler:**
1. Open Task Scheduler
2. Create Basic Task
3. Trigger: At log on
4. Action: Start a program
5. Program: `C:\dev\GIT\automaton\start-docker-on-boot.bat`

---

## Troubleshooting

### Containers Won't Start

**Check Docker is running:**
- Look for whale icon in system tray
- Should say "Docker Desktop is running"

**Check logs:**
```powershell
docker-compose logs
```

**Restart Docker Desktop:**
- Right-click whale icon → Restart

### Discord Bot Not Responding

**Check bot is running:**
```powershell
docker logs discord-bot
```

**Check token is correct:**
```powershell
notepad .env
# Verify DISCORD_BOT_TOKEN has no quotes
# Restart: docker-compose restart discord-bot
```

**Verify intents enabled:**
- Discord Developer Portal → Bot
- MESSAGE CONTENT INTENT must be ON

### n8n Can't Connect to Claude

**Test SSH connection:**
```powershell
docker exec -it claude-code-runner bash
ssh automaton@localhost
# Password: automaton
# Type 'exit' to close
```

**Verify credentials in n8n:**
- Host: `claude-runner` (NOT localhost!)
- Port: `22`
- Username: `automaton`
- Password: `automaton`

### Claude Not Authenticated

**Enter Claude container:**
```powershell
docker exec -it claude-code-runner bash
```

**Inside container:**
```bash
claude auth
# Follow prompts to authenticate
```

### File Access Issues

**Verify mounts:**
```powershell
docker exec -it n8n-orchestration sh
ls /workspace
ls /workspace/GIT
```

**If files missing:**
- Check docker-compose.yml volumes section
- Ensure path is correct: `C:/dev:/workspace:rw`

---

## Container Architecture

```
┌─────────────────────────────────────────────────────┐
│              Docker Network: orchestration-net       │
│                                                      │
│  ┌─────────────────┐         ┌──────────────────┐  │
│  │   discord-bot   │────────►│       n8n        │  │
│  │   Port: -       │  HTTP   │   Port: 5678     │  │
│  └─────────────────┘         └────────┬─────────┘  │
│                                        │            │
│                                   SSH (port 22)     │
│                                        ▼            │
│                              ┌──────────────────┐  │
│                              │  claude-runner   │  │
│                              │   Port: 2222→22  │  │
│                              └──────────────────┘  │
│                                                      │
│  Volumes:                                           │
│  - n8n-data (workflows, credentials)                │
│  - claude-data (Claude config, auth)                │
│  - C:/dev → /workspace (your files)                 │
└─────────────────────────────────────────────────────┘
```

---

## Quick Reference Commands

```powershell
# Start
docker-compose up -d

# Stop
docker-compose down

# Status
docker-compose ps

# Logs
docker-compose logs -f

# Restart service
docker-compose restart discord-bot

# Update containers (after changing docker-compose.yml)
docker-compose up -d --build

# Remove everything (nuclear option)
docker-compose down -v  # WARNING: Deletes volumes!

# Enter container
docker exec -it claude-code-runner bash
docker exec -it n8n-orchestration sh

# SSH to Claude runner
ssh -p 2222 automaton@localhost
# Password: automaton
```

---

## Service URLs

- **n8n:** http://localhost:5678
- **SSH to Claude:** `ssh -p 2222 automaton@localhost` (password: `automaton`)
- **Docker Dashboard:** Open Docker Desktop app

---

## Backup & Restore

### Backup

```powershell
# Backup n8n data (workflows, credentials)
docker run --rm -v automaton_n8n-data:/data -v C:/backup:/backup ubuntu tar czf /backup/n8n-backup.tar.gz /data

# Backup Claude data (auth, config)
docker run --rm -v automaton_claude-data:/data -v C:/backup:/backup ubuntu tar czf /backup/claude-backup.tar.gz /data
```

### Restore

```powershell
# Restore n8n data
docker run --rm -v automaton_n8n-data:/data -v C:/backup:/backup ubuntu tar xzf /backup/n8n-backup.tar.gz -C /

# Restore Claude data
docker run --rm -v automaton_claude-data:/data -v C:/backup:/backup ubuntu tar xzf /backup/claude-backup.tar.gz -C /
```

---

## Migration to Another Machine

**On old machine:**
1. Export workflows from n8n UI (Settings → Export)
2. Backup volumes (see above)
3. Copy entire automaton folder
4. Copy backup files

**On new machine:**
1. Install Docker Desktop
2. Copy automaton folder to `C:\dev\GIT\automaton`
3. Copy backup files to `C:\backup`
4. Create `.env` file with credentials
5. Restore volumes (see above)
6. Run `docker-compose up -d`

---

## What's Included

### Containers

1. **n8n-orchestration**
   - Workflow engine
   - Web UI at port 5678
   - Auto-restart enabled

2. **claude-code-runner**
   - Ubuntu 22.04
   - Claude Code installed
   - SSH server running
   - Git, vim, nano installed

3. **discord-bot**
   - Node.js 20
   - Discord.js bot
   - Auto-forwards to n8n

### Volumes

1. **n8n-data**
   - Workflows
   - Credentials
   - Execution history
   - Settings

2. **claude-data**
   - Claude authentication
   - Config files
   - SSH keys

### Mounts

- **C:\dev → /workspace**
  - Full read/write access
  - All your local files accessible
  - Git operations work

---

## SSH Credentials Configuration

### Why Use Environment Variables?

- **Repeatable**: Anyone can set their own credentials in `.env` without editing workflows
- **Secure**: Credentials are not hardcoded in the workflow JSON
- **Flexible**: Change credentials without touching n8n configuration

### Environment Variable Syntax

When configuring SSH credentials in n8n, use this exact syntax:

| Field | Value | Notes |
|-------|-------|-------|
| **Host** | `claude-runner` | Service name from docker-compose.yml |
| **Port** | `22` | Standard SSH port |
| **Username** | `={{$env.SSH_USERNAME}}` | ⚠️ Use this exact syntax! |
| **Password** | `={{$env.SSH_PASSWORD}}` | ⚠️ Use this exact syntax! |

**Syntax Rules:**
- The `=` at the start tells n8n this is an expression
- The `{{ }}` wraps the expression
- The `$env.` prefix accesses environment variables
- **Do NOT** use quotes around the expression

### How It Works

1. Docker Compose reads `.env` file
2. Passes `SSH_USERNAME` and `SSH_PASSWORD` to both containers:
   - **claude-runner**: Creates user with these credentials
   - **n8n**: Makes variables available as `$env.SSH_USERNAME` and `$env.SSH_PASSWORD`
3. n8n evaluates the expressions in credentials at runtime
4. SSH connection is made with the evaluated values

### Troubleshooting SSH Credentials

**"Connection failed" Error:**

Check:
- Is the claude-runner container running? `docker ps`
- Are the env vars in your `.env` file (no quotes)?
- Did you restart n8n after updating `.env`? `docker-compose restart n8n`

Test manually:
```bash
docker exec n8n-orchestration printenv | grep SSH
```

Should show:
```
SSH_USERNAME=automaton
SSH_PASSWORD=automaton
```

**"Expression error" in Credentials:**

Check:
- Did you use the exact syntax `={{$env.SSH_USERNAME}}`?
- No quotes around the expression
- Expression starts with `=`

**Test SSH Manually:**

```bash
# From Windows/host
ssh -p 2222 automaton@localhost

# From inside n8n container
docker exec -it n8n-orchestration sh
apk add openssh-client
ssh automaton@claude-runner
```

### Changing Credentials

To change SSH credentials:

1. Update `.env` file:
   ```env
   SSH_USERNAME=mynewuser
   SSH_PASSWORD=mynewpassword
   ```

2. Rebuild containers:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

3. n8n credentials will automatically use the new values (no changes needed in n8n UI!)

### Security Notes

- These credentials are for the **Docker container only**, not your host system
- The container is isolated and only accessible via the Docker network
- For production, use stronger passwords and consider SSH keys instead

---

## Comparison: Docker vs WSL

| Feature | WSL Setup | Docker Setup |
|---------|-----------|--------------|
| Startup | 3 terminal commands | 1 command |
| Stop | Ctrl+C in 3 terminals | 1 command |
| Auto-restart | Manual | Built-in |
| Survives reboot | No | Yes |
| Setup time | Medium | Low (after first) |
| File access | Direct (faster) | Mounted (slight overhead) |
| Isolation | Shared | Isolated |
| Portability | WSL-only | Any Docker host |

---

## Success Checklist

✅ Docker Desktop installed and running
✅ .env file created with tokens (no quotes)
✅ `docker-compose up -d` completed successfully
✅ All 3 containers showing "Up" status
✅ n8n accessible at http://localhost:5678
✅ Workflow imported and configured
✅ SSH credentials point to `claude-runner`
✅ Discord webhook URL configured
✅ Workflow activated (toggle ON)
✅ Bot shows online in Discord
✅ `!claude` command works and Claude responds

---

## Need Help?

**Check these docs:**
- `00-COMPLETE-SETUP-GUIDE.md` - Full setup instructions
- `CONTAINERIZATION-FAQ.md` - Docker questions answered
- `Part05-Troubleshooting.md` - Common issues and fixes

**Test individual components:**
```powershell
# Test Discord bot
docker logs discord-bot

# Test n8n
curl http://localhost:5678

# Test Claude SSH
docker exec -it claude-code-runner bash
claude --version
```

---

**🎉 You now have a one-command orchestration system!**

**Daily usage:** `docker-compose up -d` → Test in Discord → Done!
