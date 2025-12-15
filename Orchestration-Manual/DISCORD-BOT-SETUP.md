# Discord Bot Complete Setup Guide

## Overview

This guide sets up a complete Discord bot that:
1. Listens for messages in Discord channels
2. Forwards them to your n8n webhook
3. n8n sends to Claude Code
4. n8n posts Claude's response back to Discord

---

## Part 1: Discord Developer Portal Setup

### Step 1: Create Discord Application & Bot

**You've already done this, but for reference:**

1. Go to: https://discord.com/developers/applications
2. Click your application (or create new one)
3. In left sidebar, click **"Bot"**
4. Copy your **Bot Token** (click "Reset Token" if needed)
   - **SAVE THIS** - You'll need it for the bot script
5. Scroll to **"Privileged Gateway Intents"**
6. Enable these intents:
   - ✅ **PRESENCE INTENT**
   - ✅ **SERVER MEMBERS INTENT**
   - ✅ **MESSAGE CONTENT INTENT** (CRITICAL!)
7. Click **"Save Changes"**

### Step 2: Create Discord Webhook (for responses)

1. In Discord, right-click the channel where you want the bot
2. Click **"Edit Channel"**
3. Click **"Integrations"** → **"Webhooks"**
4. Click **"New Webhook"**
5. Name it: "Claude Responses"
6. **Copy the Webhook URL** (looks like: `https://discord.com/api/webhooks/...`)
7. Click **"Save Changes"**

**Save both:**
- Bot Token: `YOUR_BOT_TOKEN_HERE`
- Webhook URL: `YOUR_WEBHOOK_URL_HERE`

---

## Part 2: Install Discord Bot Script

### Option A: Simple Node.js Bot (Recommended)

**1. Create bot directory in WSL:**

```bash
cd ~
mkdir discord-bot
cd discord-bot
```

**2. Initialize Node.js project:**

```bash
npm init -y
npm install discord.js axios dotenv
```

**3. Create environment file:**

```bash
nano .env
```

**Add this content (replace with your actual values):**

```env
DISCORD_BOT_TOKEN=your_bot_token_here
N8N_WEBHOOK_URL=http://localhost:5678/webhook/discord-claude
NGROK_WEBHOOK_URL=https://your-ngrok-url.ngrok.io/webhook/discord-claude
BOT_PREFIX=!claude
```

**Save:** Ctrl+O, Enter, Ctrl+X

**4. Create bot script:**

```bash
nano bot.js
```

**Paste this code:**

```javascript
require('dotenv').config();
const { Client, GatewayIntentBits } = require('discord.js');
const axios = require('axios');

// Create Discord client
const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
  ],
});

// Bot configuration
const BOT_TOKEN = process.env.DISCORD_BOT_TOKEN;
const WEBHOOK_URL = process.env.N8N_WEBHOOK_URL || process.env.NGROK_WEBHOOK_URL;
const BOT_PREFIX = process.env.BOT_PREFIX || '!claude';

// When bot is ready
client.once('ready', () => {
  console.log('========================================');
  console.log(`✓ Discord bot logged in as ${client.user.tag}`);
  console.log(`✓ Forwarding to: ${WEBHOOK_URL}`);
  console.log(`✓ Listening for: ${BOT_PREFIX} <message>`);
  console.log('========================================');
  console.log('Bot is ready! Send messages with:', BOT_PREFIX);
  console.log('Example: !claude Tell me a joke');
  console.log('');
});

// When message is received
client.on('messageCreate', async (message) => {
  // Ignore messages from bots
  if (message.author.bot) return;

  // Check if message starts with bot prefix
  if (!message.content.startsWith(BOT_PREFIX)) return;

  // Extract the actual message (remove prefix)
  const userMessage = message.content.slice(BOT_PREFIX.length).trim();

  // Ignore empty messages
  if (!userMessage) {
    message.reply('Please provide a message after the command. Example: `!claude Hello`');
    return;
  }

  console.log(`[${new Date().toISOString()}] Message from ${message.author.username}: ${userMessage}`);

  // Show typing indicator
  await message.channel.sendTyping();

  try {
    // Forward to n8n webhook
    const response = await axios.post(WEBHOOK_URL, {
      content: userMessage,
      username: message.author.username,
      userId: message.author.id,
      channelId: message.channel.id,
      messageId: message.id,
      timestamp: new Date().toISOString()
    }, {
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 60000 // 60 second timeout for Claude
    });

    console.log(`✓ Forwarded to n8n successfully`);

    // n8n will handle sending the response back via Discord webhook
    // So we don't need to reply here - just log success

  } catch (error) {
    console.error('Error forwarding to n8n:', error.message);
    message.reply('⚠️ Sorry, there was an error processing your request. Make sure n8n is running!');
  }
});

// Error handling
client.on('error', (error) => {
  console.error('Discord client error:', error);
});

process.on('unhandledRejection', (error) => {
  console.error('Unhandled promise rejection:', error);
});

// Login to Discord
console.log('Starting Discord bot...');
client.login(BOT_TOKEN).catch((error) => {
  console.error('Failed to login to Discord:', error.message);
  console.error('Please check your DISCORD_BOT_TOKEN in .env file');
  process.exit(1);
});
```

**Save:** Ctrl+O, Enter, Ctrl+X

**5. Test the bot:**

```bash
node bot.js
```

**Expected output:**
```
Starting Discord bot...
========================================
✓ Discord bot logged in as YourBot#1234
✓ Forwarding to: http://localhost:5678/webhook/discord-claude
✓ Listening for: !claude <message>
========================================
Bot is ready! Send messages with: !claude
Example: !claude Tell me a joke
```

---

## Part 3: Import and Configure n8n Workflow

**Step 1: Open n8n in browser**
- Go to: http://localhost:5678
- Log in with your n8n credentials

**Step 2: Import the Discord workflow**
1. Click the **"..." menu** (three dots) in top right corner
2. Select **"Import from File"**
3. Navigate to: `C:\dev\GIT\automaton\workflows\4-discord-webhook-simple.json`
4. Click **"Open"** or **"Import"**
5. The workflow will appear on your canvas

**Step 3: Configure the "Send to Discord" node**

1. Click on the **"Send to Discord"** node (HTTP Request node)
2. In the node settings:
   - **Method:** POST (should already be set)
   - **URL:** Paste your Discord Webhook URL from Part 1, Step 2
     - Should look like: `https://discord.com/api/webhooks/1234567890/abcdef...`
   - **Authentication:** None
   - **Send Body:** Yes
   - **Body Content Type:** JSON
   - **Specify Body:** Using JSON
   - **JSON:** Keep as is (should show the output formatting)
3. Click **"Execute Node"** to test (optional - may fail if workflow not fully configured)

**Step 4: Verify other nodes (should already be correct)**

The workflow includes these nodes - verify they exist:
1. **Webhook Trigger** - Path: `discord-claude`
2. **Parse Discord Message** (Code node) - Extracts message data
3. **Generate Session ID** (Code node) - Creates UUID
4. **Ask Claude** (SSH/Execute Command node) - Sends to Claude Code
5. **Send to Discord** (HTTP Request node) - Posts response ← You just configured this

**Step 5: Save and Activate the workflow**
1. Click **"Save"** button (top right)
2. Name it: "Discord Claude Bot"
3. Toggle the **"Active"** switch to ON (should turn green/blue)
4. You'll see "Workflow activated" confirmation

**Step 6: Note your webhook URL**

The workflow is now listening at:
- **Local:** `http://localhost:5678/webhook/discord-claude`
- **Public (ngrok):** `https://your-ngrok-url.ngrok.io/webhook/discord-claude`

The Discord bot will use the local URL since it's running in the same WSL environment.

---

## Part 4: Verify Everything is Running

**You should already have all three terminals running:**

### ✅ Terminal 1: n8n (Already Running)
```bash
# Should show n8n output
# Running at: http://localhost:5678
```

### ✅ Terminal 2: ngrok (Already Running)
```bash
# Should show ngrok tunnel
# Forwarding: https://your-url.ngrok-free.dev -> http://localhost:5678
```

### ✅ Terminal 3: Discord Bot (Already Running)
```bash
# Should show:
# ========================================
# ✓ Discord bot logged in as Automaton#9499
# ✓ Forwarding to: http://localhost:5678/webhook/discord-claude
# ✓ Listening for: !claude <message>
# ========================================
```

**If any terminal is NOT running, start it:**

```bash
# For n8n (Terminal 1):
wsl -d Ubuntu
n8n

# For ngrok (Terminal 2):
wsl -d Ubuntu
ngrok http 5678

# For Discord bot (Terminal 3):
wsl -d Ubuntu
cd ~/discord-bot
node bot.js
```

**Keep all three terminals open and running!**

---

## Part 5: Test the Complete System

### Prerequisites Check:
- ✅ n8n running (Terminal 1)
- ✅ ngrok running (Terminal 2)
- ✅ Discord bot running (Terminal 3)
- ✅ n8n workflow imported and activated
- ✅ Discord webhook URL configured in n8n

### Test 1: Send Message in Discord

**1. Open Discord and go to your channel**

**2. Type this command:**
```
!claude Tell me a joke about automation
```

**3. Watch what happens:**

**Terminal 3 (Discord Bot) should show:**
```
[2025-12-14T...] Message from YourName: Tell me a joke about automation
✓ Forwarded to n8n successfully
```

**n8n Browser (http://localhost:5678):**
- Click "Executions" in left sidebar
- You should see a new execution appear
- Click it to see the workflow execution details
- All nodes should show green checkmarks ✓

**Discord Channel:**
- Within 5-10 seconds, Claude's response should appear
- Posted by your webhook (might show as "Claude Response" or webhook name)

### Test 2: Try Different Commands

```
!claude Explain quantum computing in simple terms
!claude What's the best way to learn programming?
!claude Write a haiku about automation
```

### What Should Happen (Full Flow):

1. **You type:** `!claude <your message>` in Discord
2. **Discord bot sees it** (Terminal 3 shows message received)
3. **Bot forwards to n8n** via localhost webhook
4. **n8n receives it** (execution appears in UI)
5. **n8n → SSH → Claude Code** (Ask Claude node executes)
6. **Claude responds** with answer
7. **n8n → Discord webhook** (Send to Discord node posts)
8. **Response appears in Discord** (from your webhook bot)

### Troubleshooting If It Doesn't Work:

**If bot doesn't see message:**
- Is bot online in Discord? (green dot next to name)
- Did you use the prefix? Must start with `!claude`
- Check Terminal 3 for errors

**If n8n doesn't receive:**
- Is workflow activated? (toggle should be blue/green)
- Check n8n Executions tab for errors
- Verify webhook path is `discord-claude`

**If Claude doesn't respond:**
- Check SSH credentials in n8n workflow
- Test SSH: `ssh localhost` in WSL terminal
- Check Claude Code is authenticated: `claude --version` in WSL

**If Discord doesn't show response:**
- Verify Discord webhook URL is correct in n8n
- Test webhook manually:
```bash
curl -X POST "YOUR_DISCORD_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"content":"Test message"}'
```

---

## Part 6: Auto-Start Bot with System

### Create systemd service (optional):

```bash
sudo nano /etc/systemd/system/discord-bot.service
```

**Content:**
```ini
[Unit]
Description=Discord Claude Bot
After=network.target

[Service]
Type=simple
User=[username]
WorkingDirectory=/home/[username]/discord-bot
ExecStart=/usr/bin/node /home/[username]/discord-bot/bot.js
Restart=always
Environment="NODE_ENV=production"

[Install]
WantedBy=multi-user.target
```

**Enable:**
```bash
sudo systemctl enable discord-bot
sudo systemctl start discord-bot
sudo systemctl status discord-bot
```

---

## Part 7: Update Startup Script

Update `~/start-orchestration.sh` to include Discord bot:

```bash
nano ~/start-orchestration.sh
```

**Add before the final echo statements:**

```bash
# Start Discord bot
echo "Starting Discord bot..."
cd ~/discord-bot
node bot.js > /tmp/discord-bot.log 2>&1 &
BOT_PID=$!
sleep 2

if ps -p $BOT_PID > /dev/null; then
    echo "✓ Discord bot started (PID: $BOT_PID)"
else
    echo "⚠ Discord bot failed to start"
    echo "  Check logs: tail /tmp/discord-bot.log"
fi
```

---

## Troubleshooting

### Bot doesn't respond to messages

**Check:**
1. Bot is online in Discord (green dot)?
2. MESSAGE CONTENT INTENT enabled in Developer Portal?
3. Bot has permission to read messages in the channel?

**Fix:**
```bash
# In Discord Developer Portal
Bot → Privileged Gateway Intents → Enable MESSAGE CONTENT INTENT
```

### Bot sees message but n8n doesn't receive it

**Check:**
1. Is n8n running? (`curl http://localhost:5678`)
2. Is ngrok running? (`curl http://localhost:4040/api/tunnels`)
3. Is .env file updated with correct ngrok URL?

**Fix:**
```bash
cd ~/discord-bot
nano .env
# Update NGROK_WEBHOOK_URL with current ngrok URL
# Restart bot: Ctrl+C then node bot.js
```

### n8n receives but doesn't send to Discord

**Check:**
1. Discord webhook URL correct in n8n workflow?
2. Test webhook directly:
```bash
curl -X POST "YOUR_DISCORD_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"content":"Test message"}'
```

### Claude takes too long / timeout

**Fix:**
- Add timeout to SSH command in n8n
- Reduce Claude's response length with prompt: "Keep response under 500 characters"

---

## Alternative: Simpler Curl Testing (No Bot)

If you want to test without setting up the Discord bot:

```bash
# Send message directly to n8n
curl -X POST http://localhost:5678/webhook/discord-claude \
  -H "Content-Type: application/json" \
  -d '{"content":"Tell me a joke","username":"TestUser"}'
```

Response will still appear in Discord via webhook!

---

## Summary - Files Created

```
~/discord-bot/
├── package.json          # Node.js dependencies
├── package-lock.json     # Dependency lock file
├── .env                  # Bot configuration (DON'T COMMIT!)
├── bot.js                # Discord bot script
└── node_modules/         # Dependencies
```

---

## Quick Reference

### Start Everything:
```bash
# Terminal 1
wsl -d Ubuntu
n8n

# Terminal 2
wsl -d Ubuntu
ngrok http 5678

# Terminal 3
wsl -d Ubuntu
cd ~/discord-bot
node bot.js
```

### Use in Discord:
```
!claude Tell me a joke
!claude What's the weather like?
!claude Explain quantum computing in simple terms
```

### Stop Everything:
```bash
Ctrl+C in each terminal
```

---

**You're now ready to test the complete Discord → n8n → Claude → Discord flow!**
