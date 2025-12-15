# Complete n8n + Claude Code Orchestration Setup Guide

> **Complete A-Z guide for building a Discord-controlled Claude Code orchestration system**

**What You'll Build:**
- Discord bot that responds to `!claude` commands
- n8n workflow orchestration
- Claude Code AI assistant integration
- Full automation system accessible from Discord

**Time Required:** 2-3 hours for complete setup

---

## Table of Contents

- [Part 1: Environment Setup](#part-1-environment-setup)
- [Part 2: Core Installation](#part-2-core-installation)
- [Part 3: n8n Setup](#part-3-n8n-setup)
- [Part 4: Discord Bot Creation](#part-4-discord-bot-creation)
- [Part 5: Discord Bot Installation](#part-5-discord-bot-installation)
- [Part 6: n8n Workflow Configuration](#part-6-n8n-workflow-configuration)
- [Part 7: Testing](#part-7-testing)
- [Part 8: Docker Containerization (Optional)](#part-8-docker-containerization-optional)

---

## Part 1: Environment Setup

### Prerequisites

**You need:**
- Windows 10/11
- Anthropic Claude Pro subscription OR API key
- Discord account
- Basic command line familiarity

### Step 1.1: Install WSL2 with Ubuntu

**Open PowerShell as Administrator:**

```powershell
# Check if WSL is installed
wsl --version

# If not installed, install WSL
wsl --install

# If already installed, set default to WSL2
wsl --set-default-version 2

# Install Ubuntu (if not already installed)
wsl --install -d Ubuntu

# List installed distributions
wsl -l -v
```

**Expected output:**
```
  NAME              STATE           VERSION
* Ubuntu            Running         2
```

**After installation:**
- Ubuntu will ask you to create a username and password
- **Remember this password** - you'll need it for `sudo` commands

**Test it works:**
```powershell
wsl -d Ubuntu
```

You should see a Ubuntu bash prompt like: `username@computer:~$`

---

## Part 2: Core Installation

### Step 2.1: Install Node.js in WSL

**In WSL terminal:**

```bash
# Update package lists
sudo apt update

# Install Node.js 20.x (LTS)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

**Expected output:**
- Node: v20.x.x
- npm: 10.x.x or higher

### Step 2.2: Install Claude Code

```bash
# Install Claude Code globally
sudo npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version
```

**Expected output:** `2.0.69 (Claude Code)` or higher

### Step 2.3: Authenticate Claude Code

```bash
claude auth
```

**This will:**
- Open a browser window
- Ask you to log in with your Anthropic Pro account
- Authenticate Claude Code

**After successful auth:**
- You'll see "Successfully authenticated!"
- Close the browser window

### Step 2.4: Install SSH Server

```bash
# Install OpenSSH server
sudo apt install openssh-server -y

# Start SSH service
sudo service ssh start

# Verify SSH is running
sudo service ssh status
```

**Expected:** `sshd is running`

**Test SSH connection:**
```bash
ssh localhost
# Type 'yes' when asked
# Enter your WSL password
# Type 'exit' to close the SSH session
```

---

## Part 3: n8n Setup

### Step 3.1: Install n8n

```bash
# Install n8n globally
sudo npm install -g n8n

# Verify installation
n8n --version
```

**Expected:** `1.x.x` (version number)

**Note:** Installation takes 5-10 minutes with many warnings - this is normal!

### Step 3.2: Start n8n

**Keep this terminal running:**

```bash
n8n
```

**Expected output:**
```
Editor is now accessible via: http://localhost:5678/
```

**Open browser:** http://localhost:5678

### Step 3.3: Create n8n Account

**First time setup:**
1. Enter your email (any email - doesn't need verification for local use)
2. Enter your name
3. Create a password (remember this!)
4. Click through any setup wizards

**You'll see:** n8n dashboard

---

## Part 4-5: Discord Bot Setup

**Discord bot setup has been moved to a dedicated guide for clarity.**

👉 **See:** [DISCORD-BOT-SETUP.md](DISCORD-BOT-SETUP.md) for complete Discord bot setup instructions including:
- Creating Discord application and bot
- Enabling required intents
- Inviting bot to server
- Creating webhooks
- Installing and configuring the bot code

Once you've completed the Discord bot setup, return here to continue with Part 6.

---
## Part 6: n8n Workflow Configuration

### Step 6.1: Import Workflow

**In n8n browser (http://localhost:5678):**

1. Click the **"..." menu** (three dots in top right)
2. Select **"Import from File"**
3. Navigate to: `C:\dev\GIT\automaton\workflows\4-discord-webhook-simple.json`
4. Click **"Open"** to import

### Step 6.2: Configure Webhook Node

**Click on the "Webhook" node (first node):**

- **HTTP Method:** POST
- **Path:** `discord-claude`

**This should already be correct from the import.**

### Step 6.3: Configure Parse Discord Message Node

**Click on "Parse Discord Message" Code node:**

**Replace code with:**

```javascript
// Extract from body
const content = $input.item.json.body.content;
const username = $input.item.json.body.username;
const userId = $input.item.json.body.userId;

return [{
  json: {
    message: content,
    user: username,
    userId: userId
  }
}];
```

### Step 6.4: Configure Generate UUID Node

**Click on "Generate Session ID" Code node:**

**Code should be:**

```javascript
const uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
  const r = Math.random() * 16 | 0;
  const v = c == 'x' ? r : (r & 0x3 | 0x8);
  return v.toString(16);
});

return [{
  json: {
    sessionId: uuid,
    message: $input.item.json.message,
    user: $input.item.json.user
  }
}];
```

### Step 6.5: Configure SSH/Ask Claude Node

**Click on "Ask Claude" (Execute Command/SSH) node:**

**Create new SSH credentials:**
1. Click "Create New Credential"
2. Fill in:
   - **Host:** `localhost`
   - **Port:** `22`
   - **Username:** Your WSL username
   - **Authentication:** Password
   - **Password:** Your WSL password
3. Click "Save"

**Command:**
```bash
claude -p "{{ $json.message }}" --session-id {{ $json.sessionId }}
```

### Step 6.6: Configure Send to Discord Node

**Click on "Send to Discord" (HTTP Request) node:**

**Settings:**
- **Method:** POST
- **URL:** Your Discord Webhook URL from Step 4.5

**Body Content Type:** JSON

**Specify Body:** Using Fields Below

**Add field:**
- **Name:** `content`
- **Value:** `{{ $('Ask Claude').item.json.stdout }}`

### Step 6.7: Save and Activate

1. Click **"Save"** at top
2. Name it: "Discord Claude Bot"
3. Toggle **"Active"** switch to ON (blue/green)

**You should see:** "Workflow activated"

---

## Part 7: Testing

### Your Terminal Setup

**You should have 3 terminals running:**

1. **Terminal 1 (n8n):** Shows n8n output
2. **Terminal 2 (Discord bot):** Shows bot activity
3. **Terminal 3:** Available for other commands

### Step 7.1: Send Test Message

**In Discord, in the channel with your bot, type:**

```
!claude Tell me a joke about automation
```

### Step 7.2: Watch the Flow

**Terminal 2 (Discord bot) should show:**
```
[2025-12-14T...] Message from YourName: Tell me a joke about automation
✓ Forwarded to n8n successfully
```

**n8n browser:**
1. Click "Executions" in left sidebar
2. You should see a new execution
3. All nodes should show green checkmarks ✓

**Discord channel:**
- Within 5-10 seconds, Claude's response appears!
- Posted by your "Claude Response" webhook

### Step 7.3: Try More Commands

```
!claude Explain quantum computing in simple terms
!claude What's the best way to learn programming?
!claude Write a haiku about automation
```

**🎉 Success! Your orchestration system is working!**

---

## Part 8: Docker Containerization (Optional)

**For easier startup and auto-restart, see:**
- **DOCKER-LAUNCH-QUICKSTART.md** - Quick Docker setup
- **CONTAINERIZATION-FAQ.md** - Docker vs WSL comparison

**Benefits of Docker:**
- One command startup: `docker-compose up -d`
- Auto-restart on crashes/reboots
- Easy backup and migration
- Full file system access maintained

---

## Troubleshooting

### Discord Bot Not Seeing Messages

**Check:**
- Is MESSAGE CONTENT INTENT enabled in Discord Developer Portal?
- Is bot in the same channel where you're typing?
- Did you type `!claude` with the exclamation mark?

**Fix:**
- Go to Discord Developer Portal → Bot → Enable MESSAGE CONTENT INTENT
- Restart bot: Ctrl+C in Terminal 2, then `node bot.js`

### n8n Not Receiving Webhook

**Check:**
- Is workflow activated? (toggle should be blue/green)
- Is webhook path correct? (should be `discord-claude`)

**Fix:**
- Toggle workflow OFF then ON
- Click "Save"

### Claude Not Responding

**Check:**
- Are SSH credentials correct in n8n?
- Is Claude Code authenticated? Run `claude --version` in WSL

**Fix:**
- Test SSH: `ssh localhost` in WSL
- Re-authenticate Claude: `claude auth`

### Discord Webhook Not Posting

**Check:**
- Is Discord webhook URL correct?
- Did you paste the full URL?

**Fix:**
- Test webhook manually:
```bash
curl -X POST "YOUR_DISCORD_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"content":"Test message"}'
```

---

## Daily Usage

### Starting Everything

**Terminal 1 - n8n:**
```bash
wsl -d Ubuntu
n8n
```

**Terminal 2 - Discord Bot:**
```bash
wsl -d Ubuntu
cd ~/discord-bot
node bot.js
```

### Stopping Everything

- Press **Ctrl+C** in each terminal

### Auto-Start (Optional)

See **Part03-Easy-Startup.md** for:
- Startup scripts
- One-click batch files
- systemd services

---

## Next Steps

1. ✅ Test different Claude commands
2. ✅ Explore example workflows in Part02-Workflow-Examples.md
3. ✅ Set up Docker for easier management (DOCKER-LAUNCH-QUICKSTART.md)
4. ✅ Create custom workflows for your use cases
5. ✅ Share with friends (see Part07-Appendix.md for sharing guide)

---

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────┐
│                       Windows 10/11                       │
│                                                           │
│  ┌──────────┐                  ┌─────────────────────┐  │
│  │ Discord  │ ───────────────► │   Discord Bot       │  │
│  │ (You)    │  !claude message │   (WSL Terminal 2)  │  │
│  └──────────┘                  └──────┬──────────────┘  │
│                                       │                  │
│                            HTTP POST to localhost:5678   │
│                                       ▼                  │
│                          ┌────────────────────────────┐  │
│                          │   n8n Workflow             │  │
│                          │   (WSL Terminal 1)         │  │
│                          │   - Webhook Trigger        │  │
│                          │   - Parse Message          │  │
│                          │   - Generate Session ID    │  │
│                          └────────┬───────────────────┘  │
│                                   │                      │
│                              SSH to localhost:22        │
│                                   ▼                      │
│                          ┌────────────────────────────┐  │
│                          │   Claude Code              │  │
│                          │   (WSL)                    │  │
│                          │   - AI Processing          │  │
│                          │   - Generate Response      │  │
│                          └────────┬───────────────────┘  │
│                                   │                      │
│                              Response back to n8n        │
│                                   ▼                      │
│                          ┌────────────────────────────┐  │
│                          │   n8n Send to Discord      │  │
│                          │   (HTTP Request)           │  │
│                          └────────┬───────────────────┘  │
│                                   │                      │
│                       Discord Webhook POST              │
│                                   ▼                      │
│  ┌──────────┐                  ┌─────────────────────┐  │
│  │ Discord  │ ◄─────────────── │   Discord Webhook   │  │
│  │ (You)    │  Claude response │   (Cloud)           │  │
│  └──────────┘                  └─────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

---

**Congratulations! You've built a complete AI orchestration system!** 🎉

**For Docker setup, continue to:** DOCKER-LAUNCH-QUICKSTART.md
