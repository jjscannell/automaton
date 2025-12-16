# Discord Bot Integration Guide

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DISCORD BOT INTEGRATION                         │
└─────────────────────────────────────────────────────────────────────────┘

  Discord User                                              Discord Channel
       │                                                          ▲
       │ !claude Tell me a joke                                   │
       ▼                                                          │
┌─────────────┐                                          ┌─────────────────┐
│ Discord Bot │                                          │ Discord Webhook │
│  (bot.js)   │                                          │   (Response)    │
└─────────────┘                                          └─────────────────┘
       │                                                          ▲
       │ HTTP POST                                                │
       │ {content, username, channelId...}                        │
       ▼                                                          │
┌─────────────────────────────────────────────────────────────────┴───────┐
│                              n8n Workflow                               │
│  ┌──────────┐   ┌─────────┐   ┌────────────┐   ┌────────┐   ┌────────┐ │
│  │ Webhook  │ → │  Parse  │ → │ Generate   │ → │  SSH   │ → │ HTTP   │ │
│  │ Trigger  │   │ Message │   │ Session ID │   │ Claude │   │ POST   │ │
│  └──────────┘   └─────────┘   └────────────┘   └────────┘   └────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ SSH Command
                                      ▼
                            ┌─────────────────┐
                            │  Claude Runner  │
                            │ (Claude Code)   │
                            │                 │
                            │ /workspace/     │
                            │ (your files)    │
                            └─────────────────┘
```

## Quick Start (Docker - Recommended)

### Prerequisites

1. [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed
2. Discord account with a server you can add bots to
3. 5 minutes of setup time

### Step 1: Create Discord Bot

1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Click **"New Application"** → Name it (e.g., "Claude Bot")
3. Go to **"Bot"** in the sidebar
4. Click **"Reset Token"** → **Copy and save** the token
5. Enable these **Privileged Gateway Intents**:
   - ✅ PRESENCE INTENT
   - ✅ SERVER MEMBERS INTENT
   - ✅ **MESSAGE CONTENT INTENT** (critical!)
6. Click **"Save Changes"**

### Step 2: Create Discord Webhook

1. In Discord, right-click your target channel
2. **Edit Channel** → **Integrations** → **Webhooks**
3. **New Webhook** → Name it "Claude Responses"
4. **Copy Webhook URL** and save it

### Step 3: Configure Environment

Create/edit `.env` in the project root:

```env
# Required
DISCORD_BOT_TOKEN=your_bot_token_here

# Optional (for Anthropic API instead of Pro subscription)
ANTHROPIC_API_KEY=

# Docker SSH credentials (don't change unless needed)
SSH_USERNAME=automaton
SSH_PASSWORD=automaton

# Optional (for external webhook access)
NGROK_AUTHTOKEN=
```

### Step 4: Invite Bot to Server

1. Go to **OAuth2** → **URL Generator** in Developer Portal
2. Select scopes: `bot`, `applications.commands`
3. Select permissions: `Send Messages`, `Read Message History`, `View Channels`
4. Copy the generated URL → Open in browser → Select your server

### Step 5: Launch Everything

```bash
# Start all services
docker-compose up -d

# Watch logs
docker-compose logs -f
```

### Step 6: Configure n8n Workflow

1. Open [http://localhost:5678](http://localhost:5678)
2. Import workflow: `workflows/4-discord-webhook-simple.json`
3. Edit **"Send to Discord"** node → Paste your Discord Webhook URL
4. **Save** and **Activate** the workflow (toggle ON)

### Step 7: Test It!

In Discord, type:
```
!claude Tell me a joke about automation
```

You should see Claude's response appear within 10-30 seconds!

---

## WSL Deployment (Alternative)

If you prefer running directly in WSL without Docker:

### Step 1: Set Up the Bot

```bash
# Create bot directory
cd ~
mkdir discord-bot && cd discord-bot

# Initialize and install
npm init -y
npm install discord.js axios dotenv

# Create .env file
cat > .env << 'EOF'
DISCORD_BOT_TOKEN=your_token_here
N8N_WEBHOOK_URL=http://localhost:5678/webhook/discord-claude
BOT_PREFIX=!claude
EOF

# Copy bot script
cp /path/to/automaton/discord-bot-docker/bot.js .
```

### Step 2: Run the Stack

Open three terminals:

**Terminal 1 - n8n:**
```bash
n8n
```

**Terminal 2 - Discord Bot:**
```bash
cd ~/discord-bot && node bot.js
```

**Terminal 3 - ngrok (optional, for external access):**
```bash
ngrok http 5678
```

---

## Bot Commands

| Command | Description | Example |
|---------|-------------|---------|
| `!claude <message>` | Send any prompt to Claude | `!claude Explain quantum computing` |
| `!claude analyze this code` | With codebase context | Change directory in n8n first |

The prefix `!claude` is configurable via the `BOT_PREFIX` environment variable.

---

## Customization

### Change Bot Prefix

Edit `.env`:
```env
BOT_PREFIX=!ai
```

Then restart the bot:
```bash
docker-compose restart discord-bot
```

### Add File Context

Modify the SSH command in your n8n workflow:
```bash
cd /workspace/your-project && claude -p "{{ $json.message }}" --session-id {{ $json.sessionId }}
```

### Enable Dangerous Mode (Skills & Agents)

For full Claude Code capabilities:
```bash
claude --dangerously-skip-permissions -p "{{ $json.message }}" --session-id {{ $json.sessionId }}
```

---

## Message Payload Reference

The bot forwards this JSON to n8n:

```json
{
  "content": "User's message (prefix removed)",
  "username": "DiscordUsername",
  "userId": "123456789012345678",
  "channelId": "987654321098765432",
  "messageId": "111222333444555666",
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

Use these in n8n expressions:
- `{{ $json.content }}` - The user's message
- `{{ $json.username }}` - Who sent it
- `{{ $json.channelId }}` - For conditional routing

---

## Troubleshooting

### Bot Not Responding to Messages

**Symptom**: You type `!claude hello` but nothing happens.

**Fixes**:
1. **Check MESSAGE CONTENT INTENT** is enabled in Developer Portal
2. **Check bot is online** (green dot in Discord member list)
3. **Check logs**: `docker logs discord-bot`

### Bot Sees Message But No Response

**Symptom**: Bot logs show message received, but no Discord response.

**Fixes**:
1. **Check n8n workflow is activated** (toggle should be ON)
2. **Check Discord Webhook URL** in the "Send to Discord" node
3. **Test webhook manually**:
   ```bash
   curl -X POST "YOUR_WEBHOOK_URL" \
     -H "Content-Type: application/json" \
     -d '{"content":"Test message"}'
   ```

### "Error forwarding to n8n"

**Symptom**: Bot replies with error message.

**Fixes**:
1. **Is n8n running?** Check `docker logs n8n-orchestration`
2. **Docker networking**: Bot must use `http://n8n:5678` not `localhost`
3. **Restart services**: `docker-compose restart`

### Claude Times Out

**Symptom**: Long delay then error, or no response.

**Fixes**:
1. **Check Claude auth**: `docker exec -it claude-code-runner claude --version`
2. **Re-authenticate**: `docker exec -it claude-code-runner claude auth`
3. **Add response limit to prompt**: "Keep response under 2000 characters"

### SSH Connection Failed

**Symptom**: n8n shows SSH error.

**Fixes**:
1. **Docker**: Use host `claude-runner` (not `localhost`)
2. **WSL**: Use host `localhost`, port `22`
3. **Credentials**: Check `.env` matches n8n SSH credential settings

---

## Service Health Checks

```bash
# Check all services
docker-compose ps

# Individual service logs
docker logs discord-bot
docker logs n8n-orchestration
docker logs claude-code-runner

# Test n8n webhook
curl http://localhost:5678/healthz

# Test SSH connection
ssh -p 2222 automaton@localhost  # Password: automaton

# Test Claude inside container
docker exec -it claude-code-runner claude --version
```

---

## Security Notes

1. **Never commit `.env`** - It's in `.gitignore` for a reason
2. **Bot token is secret** - Regenerate if exposed
3. **Webhook URL is semi-secret** - Anyone with it can post to your channel
4. **`--dangerously-skip-permissions`** - Only use for trusted automation
5. **Restrict bot to specific channels** if needed via Discord permissions

---

## Files Reference

```
automaton/
├── discord-bot-docker/
│   ├── bot.js           # Discord bot source code
│   └── package.json     # Node.js dependencies
├── workflows/
│   └── 4-discord-webhook-simple.json  # Pre-built n8n workflow
├── docker-compose.yml   # All services configuration
├── .env                 # Your secrets (not committed)
└── DISCORD-BOT-INTEGRATION.md  # This file
```


## Next Steps

- **Add more commands**: Extend `bot.js` to handle different prefixes for different tasks
- **Multi-channel routing**: Use `channelId` to route to different workflows
- **User permissions**: Check `userId` before allowing certain operations
- **Response formatting**: Use Discord embeds for prettier responses

For detailed n8n workflow examples, see [Orchestration-Manual/](Orchestration-Manual/).

---

**Questions?** Check the [full documentation](Orchestration-Manual/README.md) or open an issue!
