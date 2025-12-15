# Orchestration Manual - Documentation Index

> **Complete documentation for the n8n + Claude Code + Discord orchestration system**

## 📖 Start Here

### New User? Start With:
**[00-COMPLETE-SETUP-GUIDE.md](00-COMPLETE-SETUP-GUIDE.md)** - Complete A-Z setup from scratch

### Have Docker? Skip to:
**[DOCKER-LAUNCH-QUICKSTART.md](DOCKER-LAUNCH-QUICKSTART.md)** - One-command Docker launch

---

## 📚 Documentation Structure

### Core Guides

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **00-COMPLETE-SETUP-GUIDE.md** | Full A-Z setup process | Setting up from scratch |
| **DOCKER-LAUNCH-QUICKSTART.md** | Docker deployment | Quick launch or production use |
| **DISCORD-BOT-SETUP.md** | Detailed Discord bot setup | Advanced Discord configuration |

### Additional Documentation

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **CONTAINERIZATION-FAQ.md** | Docker questions answered | Deciding between WSL and Docker |

---

## 🚀 Quick Start Paths

### Path 1: Complete Fresh Setup (Recommended)

1. **[00-COMPLETE-SETUP-GUIDE.md](00-COMPLETE-SETUP-GUIDE.md)**
   - Follow Parts 1-7
   - Time: 2-3 hours
   - Result: Working WSL-based system

2. **Test your system**
   - Send `!claude` commands in Discord
   - Verify responses work

3. **Optional: Containerize**
   - **[DOCKER-LAUNCH-QUICKSTART.md](DOCKER-LAUNCH-QUICKSTART.md)** Option B
   - Migrate to Docker for easier management

### Path 2: Docker-First Setup (Advanced Users)

1. **[DOCKER-LAUNCH-QUICKSTART.md](DOCKER-LAUNCH-QUICKSTART.md)**
   - Follow Option B (Complete Fresh Setup)
   - Time: 1-2 hours
   - Result: Containerized system from the start

### Path 3: Quick Launch (Existing Setup)

1. **[DOCKER-LAUNCH-QUICKSTART.md](DOCKER-LAUNCH-QUICKSTART.md)**
   - Follow Option A (Launch Existing Setup)
   - Time: 10 minutes
   - Result: System running

---

## 🎯 Use Case Guide

### I want to...

**...set up the system for the first time**
→ [00-COMPLETE-SETUP-GUIDE.md](00-COMPLETE-SETUP-GUIDE.md)

**...launch the system with Docker**
→ [DOCKER-LAUNCH-QUICKSTART.md](DOCKER-LAUNCH-QUICKSTART.md) - Option A

**...understand Docker vs WSL**
→ [CONTAINERIZATION-FAQ.md](CONTAINERIZATION-FAQ.md)

**...make the system start automatically**
→ [DOCKER-LAUNCH-QUICKSTART.md](DOCKER-LAUNCH-QUICKSTART.md) - Auto-restart with Docker

**...fix a problem**
→ [00-COMPLETE-SETUP-GUIDE.md](00-COMPLETE-SETUP-GUIDE.md) - Troubleshooting section
→ [CONTAINERIZATION-FAQ.md](CONTAINERIZATION-FAQ.md) - Common Docker issues

**...share this with a friend**
→ [DOCKER-LAUNCH-QUICKSTART.md](DOCKER-LAUNCH-QUICKSTART.md) - Option B

**...customize the Discord bot**
→ [DISCORD-BOT-SETUP.md](DISCORD-BOT-SETUP.md)

**...understand the architecture**
→ [00-COMPLETE-SETUP-GUIDE.md](00-COMPLETE-SETUP-GUIDE.md) - Architecture section
→ [CONTAINERIZATION-FAQ.md](CONTAINERIZATION-FAQ.md) - Diagrams

---

## 📋 Setup Checklist

### Prerequisites
- [ ] Windows 10/11 with WSL2 OR Docker Desktop
- [ ] Anthropic Claude Pro subscription OR API key
- [ ] Discord account
- [ ] Basic command line knowledge

### WSL Setup
- [ ] WSL2 Ubuntu installed
- [ ] Node.js installed
- [ ] Claude Code installed and authenticated
- [ ] SSH server running
- [ ] n8n installed and running
- [ ] Discord bot created
- [ ] Discord bot code running
- [ ] n8n workflow imported and configured
- [ ] System tested and working

### Docker Setup
- [ ] Docker Desktop installed
- [ ] .env file configured
- [ ] docker-compose up -d successful
- [ ] All containers running
- [ ] n8n workflow imported
- [ ] Workflow activated
- [ ] System tested and working

---

## 🏗️ System Architecture

### WSL-Based Setup

```
Windows
  ├── WSL Ubuntu (Terminal 1) → n8n
  ├── WSL Ubuntu (Terminal 2) → Discord Bot
  └── Browser → http://localhost:5678 (n8n UI)
```

### Docker-Based Setup

```
Windows
  ├── Docker Desktop
  │   ├── n8n container (port 5678)
  │   ├── claude-runner container (port 2222)
  │   └── discord-bot container
  └── Browser → http://localhost:5678 (n8n UI)
```

---

## 🔧 Component Overview

| Component | Purpose | Technology |
|-----------|---------|------------|
| **n8n** | Workflow orchestration engine | Node.js web app |
| **Claude Code** | AI assistant execution | Anthropic CLI tool |
| **Discord Bot** | Message listener and forwarder | Discord.js |
| **SSH** | Communication between n8n and Claude | OpenSSH |
| **Webhooks** | Discord → Bot → n8n → Discord flow | HTTP/HTTPS |

---

## 💡 Tips & Best Practices

### Getting Started
- Start with WSL setup first - it's easier to understand
- Test each component independently before connecting them
- Keep all three terminal windows visible while testing

### Daily Usage
- WSL: Requires manual start of 2-3 terminals
- Docker: One command `docker-compose up -d`

### Troubleshooting
- Check one component at a time
- Discord bot logs show message flow
- n8n Executions tab shows workflow runs
- Test SSH independently: `ssh localhost`

### Production Use
- Use Docker for auto-restart and reliability
- Back up n8n workflows regularly (export function)
- Monitor Claude API usage (if using API key)
- Set up proper logging for bot activity

---

## 📞 Getting Help

### Quick Checks
1. Is Docker Desktop running? (for Docker setup)
2. Are all WSL terminals running? (for WSL setup)
3. Is workflow activated in n8n?
4. Is bot online in Discord?
5. Check logs: `docker logs discord-bot` or bot terminal

### Common Issues
- **Bot doesn't see messages** → Enable MESSAGE CONTENT INTENT
- **n8n doesn't receive webhook** → Check workflow is activated
- **Claude doesn't respond** → Verify SSH credentials
- **Discord doesn't show response** → Check webhook URL

### Documentation Priority
1. Check relevant troubleshooting section first
2. Review the complete setup guide for that component
3. Check FAQ documents for conceptual questions

---

## 🎓 Learning Path

### Beginner
1. Follow 00-COMPLETE-SETUP-GUIDE.md step by step
2. Test with simple `!claude` commands
3. Experiment with n8n workflow nodes

### Intermediate
1. Create custom workflows in n8n
2. Migrate to Docker for easier management (DOCKER-LAUNCH-QUICKSTART.md)
3. Customize Discord bot behavior

### Advanced
1. Customize Discord bot behavior
2. Create complex multi-agent workflows
3. Integrate with other services (GitHub, Slack, etc.)
4. Deploy to cloud server for 24/7 operation

---

## 📦 What's Included

### Files in This Repository

```
Orchestration-Manual/
├── README.md (this file)
├── 00-COMPLETE-SETUP-GUIDE.md
├── DOCKER-LAUNCH-QUICKSTART.md
├── DISCORD-BOT-SETUP.md
└── CONTAINERIZATION-FAQ.md

Parent Directory (../):
├── docker-compose.yml
├── .env.template
├── start-docker.bat
├── stop-docker.bat
├── wsl-startup-script.sh
├── setup-n8n-credentials.sh
├── workflows/
│   ├── 1-basic-claude-test.json
│   ├── 2-claude-with-sessions.json
│   ├── 3-system-health-monitor.json
│   └── 4-discord-webhook-simple.json
└── discord-bot-docker/
    ├── bot.js
    ├── package.json
    └── package-lock.json
```

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2025-12-14 | Complete reorganization, added Docker support |
| 1.0 | 2025-12-13 | Initial manual creation |

---

## 🤝 Contributing & Sharing

### Sharing This Setup
- Share entire automaton folder
- Include .env.template (NOT .env with your secrets!)
- Point friends to 00-COMPLETE-SETUP-GUIDE.md or DOCKER-LAUNCH-QUICKSTART.md

### Customization
- All markdown files are editable
- Workflows can be exported/imported from n8n
- Docker configs in docker-compose.yml
- Bot behavior in discord-bot-docker/bot.js

---

## ⚡ Quick Commands Reference

### WSL Setup
```bash
# Start n8n
wsl -d Ubuntu
n8n

# Start Discord bot (new terminal)
wsl -d Ubuntu
cd ~/discord-bot
node bot.js

# Test SSH
ssh localhost
```

### Docker Setup
```powershell
# Start everything
docker-compose up -d

# Stop everything
docker-compose down

# View status
docker-compose ps

# View logs
docker logs -f discord-bot
```

---

**🎉 You're all set! Choose your path above and start building!**

**Need help?** Check the troubleshooting sections in each guide or review the FAQ documents.
