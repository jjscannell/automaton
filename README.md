# n8n + Claude Code Integration Guide

> Connect n8n to Claude Code (or other AI terminal tools) via SSH for powerful automation workflows.

**Implemented from**: [NetworkChuck's n8n-claude-code-guide](https://github.com/theNetworkChuck/n8n-claude-code-guide) | **Video**: [n8n + Claude Code is OVERPOWERED](https://youtu.be/s96JeuuwLzc)

## About
Long workflows in Claude Code (or any LLM) can drift from context, hallucinate, and make fuzzy decisions. This solution utilizes N8N as a **orchestration layer** while still utilizing the powerful Claude Code environment. Massive credit to NetworkChuck for the implementation. His original README follows below, as are his support links. 

What follows here is my implementation of his solution. My additions include:
- Added a Discord bot in place of Slack
- Containerized my WSL setup in Docker
- Added some example use cases

## 🚀 Choose Your Path

### **Path 1: Docker Setup (Quick Start - 1 hour)**
This is a Docker image containing two WSL instances: one runs Claude Code, one runs N8N. You add your credentials to the `.env` file and your are ready to run.

1. Install Docker Desktop
2. Configure `.env` file
3. Run `docker-compose up -d`
4. Configure Discord bot

👉 **[Orchestration-Manual/DOCKER-LAUNCH-QUICKSTART.md](Orchestration-Manual/DOCKER-LAUNCH-QUICKSTART.md)**

### **Path 2: WSL Setup (Educational - 2-3 hours)**
This is a step by step installation of the entire process, useful if you want to see how all the gears turn.

1. Install WSL2 Ubuntu
2. Install Node.js, Claude Code, n8n
3. Configure SSH and Discord bot
4. Set up workflows

👉 **[Orchestration-Manual/00-COMPLETE-SETUP-GUIDE.md](Orchestration-Manual/00-COMPLETE-SETUP-GUIDE.md)**

### **Path 3: Discord Bot (Remote Control your Claude Code)**
Not required for the orchestration.

1. Discord Developer Portal Setup
2. Install Discord Bot Script
3. Import and Configure n8n Workflow
4. Verify Everything is Running
5. Test the Complete System
6. Auto-Start Bot with System

👉 **[Orchestration-Manual/DISCORD-BOT-SETUP.md](Orchestration-Manual/DISCORD-BOT-SETUP.md)**


### **Path 4: Sample Workflows (N8N JSON Files)**
As of the initial commit, most of these are untested. A brainstorm of potential use cases.

1.  basic-claude-test
2.  claude-with-sessions
3.  discord-webhook-simple
4.  system-health-monitor
5.  intelligent-issue-triage
6.  code-review-learning-system
7.  continuous-codebase-health-monitor
8.  multi-agent-code-development-pipeline
9.  multi-repo-dependency-update
10. distributed-testing-deployment-pipeline

👉 **[workflows](workflows)**

---

## Documentation Structure

### Quick Navigation

| I want to... | Go to... |
|-------------|----------|
| **Start with Docker** | [Orchestration-Manual/DOCKER-LAUNCH-QUICKSTART.md](Orchestration-Manual/DOCKER-LAUNCH-QUICKSTART.md) |
| **Learn from scratch** | [Orchestration-Manual/00-COMPLETE-SETUP-GUIDE.md](Orchestration-Manual/00-COMPLETE-SETUP-GUIDE.md) |
| **Set up Discord bot** | [Orchestration-Manual/DISCORD-BOT-SETUP.md](Orchestration-Manual/DISCORD-BOT-SETUP.md) |
| **Understand Docker vs WSL** | [Orchestration-Manual/CONTAINERIZATION-FAQ.md](Orchestration-Manual/CONTAINERIZATION-FAQ.md) |
| **Browse all docs** | [Orchestration-Manual/README.md](Orchestration-Manual/README.md) |

### Complete Documentation

All documentation is organized in the **[Orchestration-Manual/](Orchestration-Manual/)** folder:

**Core Guides:**
- **[00-COMPLETE-SETUP-GUIDE.md](Orchestration-Manual/00-COMPLETE-SETUP-GUIDE.md)** - Complete A-Z setup (WSL-based, 2-3 hours)
- **[DOCKER-LAUNCH-QUICKSTART.md](Orchestration-Manual/DOCKER-LAUNCH-QUICKSTART.md)** - One-command Docker launch (1 hour)
- **[DISCORD-BOT-SETUP.md](Orchestration-Manual/DISCORD-BOT-SETUP.md)** - Detailed Discord bot configuration
- **[CONTAINERIZATION-FAQ.md](Orchestration-Manual/CONTAINERIZATION-FAQ.md)** - Docker vs WSL comparison

**See [Orchestration-Manual/README.md](Orchestration-Manual/README.md) for complete documentation index**

### 🛠️ Ready-to-Use Files

- `start-docker.bat` / `stop-docker.bat` - Docker management
- `docker-compose.yml` - Complete containerized setup
- `workflows/` - Pre-built n8n workflow templates
- `discord-bot-docker/` - Discord bot for containers

---

## Table of Contents [NetworkChuck's Original]

- [Prerequisites](#prerequisites)
- [Architecture Overview](#architecture-overview)
- [Setup Guide](#setup-guide)
  - [1. Install Claude Code](#1-install-claude-code)
  - [2. Configure n8n SSH Credentials](#2-configure-n8n-ssh-credentials)
  - [3. Test the Connection](#3-test-the-connection)
- [Basic Usage](#basic-usage)
  - [Simple Claude Command](#simple-claude-command)
  - [Adding Context (Working Directory)](#adding-context-working-directory)
  - [Using Skills and Agents](#using-skills-and-agents)
- [Session Management](#session-management)
  - [Creating a Session ID](#creating-a-session-id)
  - [Resuming Sessions](#resuming-sessions)
- [Advanced Workflows](#advanced-workflows)
  - [Slack Integration (Mobile Access)](#slack-integration-mobile-access)
- [Troubleshooting](#troubleshooting)
- [Resources](#resources)

---

## Prerequisites

You'll need three things:

1. **n8n Instance** - Self-hosted or cloud
2. **AI Terminal Tool** - Claude Code (recommended), Gemini CLI, or Codex
3. **Coffee** - That's just the rules

### Claude Code Requirements

- Requires an [Anthropic Pro subscription](https://claude.ai/pro) or API access
- Can be installed on any Linux-based machine (including Mac, Windows WSL)

### Where to Install Claude Code

You can install Claude Code on:

| Location | Pros | Cons |
|----------|------|------|
| Same VPS as n8n | Simple setup, same machine | Resource sharing |
| Dedicated Ubuntu server | Best performance, local file access | Additional infrastructure |
| Raspberry Pi | Low cost, always on | Limited resources |
| Hostinger VPS | Cloud-based, easy setup | Monthly cost |

---

## Architecture Overview

```
┌─────────────┐         SSH          ┌──────────────────┐
│    n8n      │ ───────────────────► │  Linux Server    │
│  (workflow) │                      │  (Claude Code)   │
└─────────────┘                      └──────────────────┘
                                              │
                                              ▼
                                     ┌──────────────────┐
                                     │  Your Files      │
                                     │  Your Skills     │
                                     │  Your Context    │
                                     └──────────────────┘
```

The magic? **SSH**. That's it. n8n uses the SSH node to remotely execute Claude Code commands on your server.

---

## Setup Guide

### 1. Install Claude Code

On your Linux server (Ubuntu example):

```bash
# Install Node.js (if not installed)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Claude Code globally
npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version

# Authenticate (follow prompts)
claude auth
```

### 2. Configure n8n SSH Credentials

1. In n8n, add an **SSH** node to your workflow
2. Click **Create New Credential**
3. Fill in your server details:

| Field | Value |
|-------|-------|
| **Host** | Your server IP (e.g., `192.168.1.100` or public IP) |
| **Port** | `22` (default SSH) |
| **Username** | Your SSH username |
| **Authentication** | Password or Private Key |
| **Password/Key** | Your credentials |

4. Click **Save** - Look for "Connection tested successfully"

### 3. Test the Connection

First, test with a basic command:

```bash
hostname
```

If that works, test Claude Code:

```bash
claude --version
```

You should see the Claude Code version in the output.

---

## Basic Usage

### Simple Claude Command

Use the `-p` (print) flag for headless mode - send a prompt and get a response:

**SSH Node Command:**
```bash
claude -p "Why do pugs look so weird?"
```

The `-p` flag puts Claude in "print mode" - it processes your prompt and returns the result without interactive input.

### Adding Context (Working Directory)

Give Claude access to your project files by changing directory first:

**SSH Node Command:**
```bash
cd /path/to/your/project && claude -p "Is this video going to be any good?"
```

Claude will read files in that directory to inform its response. This is the power - **context from your local files**.

### Using Skills and Agents

Put Claude in "dangerous mode" to enable tool use and agent deployment:

**SSH Node Command:**
```bash
claude --dangerously-skip-permissions -p "Use your unifi skill to check wifi status, network performance, and security. Deploy three agents, one for each task. Keep response under 2000 characters."
```

This enables Claude to:
- Use installed skills (like UniFi, Slack, etc.)
- Deploy multiple agents in parallel
- Execute code and scripts
- Access APIs and external services

---

## Session Management

The real power comes from maintaining conversations across multiple n8n executions.

### Creating a Session ID

Add a **Code** node before your SSH node to generate a UUID:

**Code Node (JavaScript):**
```javascript
const uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
  const r = Math.random() * 16 | 0;
  const v = c == 'x' ? r : (r & 0x3 | 0x8);
  return v.toString(16);
});

return [{ json: { sessionId: uuid } }];
```

**SSH Node Command:**
```bash
claude -p "How many access points are up right now?" --session-id {{ $json.sessionId }}
```

### Resuming Sessions

To continue a conversation, use the `-r` (resume) flag with the same session ID:

**SSH Node Command (Follow-up):**
```bash
claude -r --session-id {{ $('Code').item.json.sessionId }} -p "Why is one of them down?"
```

The `-r` flag resumes the previous session, so Claude remembers the context of your earlier questions.

---

## Advanced Workflows

### Slack Integration (Mobile Access)

Create a workflow that lets you chat with Claude Code from your phone via Slack:

#### Workflow Structure:

```
[Slack Trigger] → [Code: Generate UUID] → [SSH: Initial Claude Command]
                                                      ↓
                                              [Slack: Send Response]
                                                      ↓
                                              [Slack: Ask Continue?]
                                                      ↓
                                                [If Node]
                                               /        \
                                        [False]        [True]
                                           ↓              ↓
                              [Loop: SSH Resume]     [End Workflow]
                                      ↓
                              [Slack: Response]
                                      ↓
                              [Back to Ask Continue]
```

#### Key Components:

1. **Slack Trigger**: Listens for messages mentioning your bot
2. **Code Node**: Generates session UUID (see above)
3. **SSH Node (Initial)**: First Claude command with `--session-id`
4. **Slack Response**: Posts Claude's response back to channel
5. **Slack Dropdown**: "Are you done? [Yes] [No]"
6. **If Node**: Routes based on user selection
7. **SSH Node (Resume)**: Uses `-r --session-id` for follow-ups
8. **Loop**: Continues until user selects "Yes"

#### Example Prompts from Slack:

```
@bot deploy two agents to battle it out: which is better, nano or neovim?
Research, contrast, compare, give me a solid answer. Keep response under 2000 characters.
```

```
@bot use your NAS skill to check how my stuff server is doing
```

---

## Troubleshooting

Common issues and solutions:

### Claude Command Not Found

The SSH session may not load your shell profile. Solutions:

1. **Use full path:**
   ```bash
   /usr/local/bin/claude -p "your prompt"
   ```

2. **Source profile first:**
   ```bash
   source ~/.bashrc && claude -p "your prompt"
   ```

3. **Add to system PATH:**
   ```bash
   sudo ln -s $(which claude) /usr/local/bin/claude
   ```

### Permission Denied Errors

If Claude can't access files or run tools:

1. Ensure the SSH user has proper permissions
2. Use `--dangerously-skip-permissions` for tool access
3. Check file ownership in your project directories

### Session Not Resuming

Make sure you're:
1. Using the exact same session ID
2. Including the `-r` flag when resuming
3. Not letting too much time pass (sessions may expire)

### Response Too Long

Slack has a 4000 character limit. Add to your prompts:
```
Keep response under 2000 characters.
```

### SSH Connection Timeout

For long-running Claude operations:
1. Increase SSH timeout in n8n node settings
2. Consider breaking complex tasks into smaller prompts

---

## Resources

- **NetworkChuck Academy**: [n8n Course](https://academy.networkchuck.com) | [Claude Code Course](https://academy.networkchuck.com)
- **Claude Code Docs**: [Official Documentation](https://docs.anthropic.com/claude-code)
- **n8n Docs**: [SSH Node](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.ssh/)
- **Previous Videos**:
  - [n8n Part 1](https://youtu.be/ONgECvZNI3o) - Getting Started with n8n
  - [n8n Part 2](https://youtu.be/budTmdQfXYU) - n8n Now Runs My ENTIRE Homelab (Terry)
  - [AI in the Terminal](https://youtu.be/MsQACpcuTkU) - Claude Code, Gemini CLI, Codex Introduction

---

## What's Next?

In the next video, we're building a full **IT Department** with:
- n8n as the orchestrator
- Claude Code, Gemini CLI, and Codex as the workers
- Automated monitoring, alerting, and remediation

Subscribe to catch it when it drops!

---

**Created by NetworkChuck** | [YouTube](https://youtube.com/@NetworkChuck) | [Discord](https://discord.gg/networkchuck)
