# n8n Workflow Collection for Claude Code Orchestration

This directory contains sample n8n workflows demonstrating advanced orchestration patterns for Claude Code agents. These workflows showcase capabilities that are difficult or impossible to achieve with Claude Code alone, including state management, rate limiting, multi-agent coordination, and self-learning systems.

## ⚠️ Important Notice

**These are sample, untested workflows provided for experimentation and learning purposes.**

- Workflows have not been tested in production environments
- You should review, test, and modify them for your specific use case
- Ensure proper security configurations before deploying
- Replace placeholder values (webhook URLs, credentials, etc.)

## 📋 Table of Contents

- [Workflow Complexity Guide](#workflow-complexity-guide)
- [Prerequisites](#prerequisites)
- [Workflow Descriptions](#workflow-descriptions)
- [Setup Instructions](#setup-instructions)
- [Configuration Guide](#configuration-guide)
- [Contributing](#contributing)

## 🎯 Workflow Complexity Guide

Workflows are numbered by increasing complexity to facilitate learning:

- **00-01**: Template & Simple - Learn the basics
- **02-04**: Medium - Interactive and scheduled workflows
- **05-06**: Medium-High - Multi-agent coordination
- **07-08**: High - Advanced orchestration and learning
- **09-10**: Very High - Production-grade CI/CD patterns

## 📚 Prerequisites

### Required Setup

1. **n8n Installation**
   ```bash
   npm install -g n8n
   # or use Docker
   docker run -it --rm --name n8n -p 5678:5678 n8nio/n8n
   ```

2. **Claude Code SDK**
   - Install and configure Claude Code CLI
   - Ensure it's accessible from your n8n host

3. **SSH Access** (for workflows using SSH node)
   - Configure SSH credentials in n8n
   - Ensure Claude Code is available on the SSH target machine

4. **External Integrations** (optional)
   - Discord webhook for notifications
   - Slack webhook for alerts
   - GitHub webhooks for PR/Issue automation

## 📖 Workflow Descriptions

### 00 - Template Workflow with Error Handling
**Complexity**: Template
**Use Case**: Base template demonstrating best practices

**Features**:
- Error handling with try/catch patterns
- Rate limiting (10 requests per minute)
- Retry logic with exponential backoff (max 3 retries)
- Request ID tracking
- Comprehensive logging

**Setup**: This is a reference template. Copy patterns from this workflow into your own.

---

### 01 - Basic Claude Test
**Complexity**: Simple
**Use Case**: Test Claude Code integration

**Features**:
- Manual trigger
- Simple Claude command execution
- Basic error handling

**Setup**:
1. Import workflow into n8n
2. Configure SSH credentials
3. Click "Test workflow" to run

**Example Use**: Verify Claude Code is working correctly.

---

### 02 - Claude with Session Management
**Complexity**: Simple
**Use Case**: Multi-turn conversations with context

**Features**:
- UUID session generation
- Session-based Claude interactions
- Error handling

**Setup**:
1. Import workflow
2. Configure SSH credentials
3. Test to see session ID in output

**Example Use**: Maintain conversation context across multiple interactions.

---

### 03 - Discord to Claude Interactive Bot
**Complexity**: Medium
**Use Case**: Discord bot powered by Claude Code

**Features**:
- Webhook trigger for Discord messages
- Message validation (max 2000 chars)
- Session management per request
- Response formatting for Discord
- Comprehensive error reporting

**Setup**:
1. Create Discord webhook URL
2. Import workflow and configure webhook trigger
3. Replace `YOUR_DISCORD_WEBHOOK_URL_HERE` with your webhook URL
4. Configure SSH credentials
5. Set up Discord webhook to POST to your n8n webhook URL

**Example Use**: Users send messages to Discord channel → Claude responds.

---

### 04 - System Health Monitor with Alerts
**Complexity**: Medium
**Use Case**: Automated system health monitoring

**Features**:
- Scheduled checks every 15 minutes
- System health analysis (CPU, memory, disk)
- Trend tracking (stores last 20 checks)
- Consecutive failure detection
- Smart alerting (only alerts on sustained issues)

**Setup**:
1. Import workflow
2. Replace `YOUR_DISCORD_WEBHOOK_URL` with your alert destination
3. Configure SSH credentials
4. Workflow activates automatically

**Example Use**: Monitor server health, get alerted before problems escalate.

---

### 05 - Intelligent Issue Triage & Auto-Resolution
**Complexity**: Medium-High
**Use Case**: Automated GitHub issue management

**Features**:
- GitHub webhook integration
- Rate limiting (5 issues per minute)
- Issue classification (BUG, FEATURE, QUESTION, DUPLICATE)
- Multi-agent routing by category
- Triage history tracking (last 100 issues)

**Setup**:
1. Import workflow
2. Configure webhook trigger path
3. Set up GitHub webhook to POST to: `https://your-n8n.com/webhook/github-issue-webhook`
4. Configure SSH credentials
5. Test with sample GitHub issue

**Example Use**: New GitHub issue → Automatically classified → Routed to appropriate agent → Triage logged.

---

### 06 - Code Review Learning & Enforcement System
**Complexity**: Medium-High
**Use Case**: AI-powered code review that learns from feedback

**Features**:
- PR webhook integration
- Pattern learning (stores anti-patterns and good patterns)
- Review history tracking (last 50 reviews)
- Weekly learning agent updates patterns
- Trend reporting
- Adaptive review rules

**Setup**:
1. Import workflow
2. Configure GitHub PR webhook
3. Configure SSH credentials
4. Workflow learns from review outcomes over time

**Example Use**: PR opened → Analyzed for issues → Review posted → Human reacts → System learns → Future reviews improve.

---

### 07 - Continuous Codebase Health Monitor
**Complexity**: High
**Use Case**: Multi-dimensional codebase health tracking

**Features**:
- Parallel agent execution (Security, Quality, Test, Performance)
- Time-series metrics storage (last 120 checks)
- Trend analysis and anomaly detection
- Auto-fix agent for simple issues
- Smart alerting with severity levels

**Setup**:
1. Import workflow
2. Replace `YOUR_SLACK_WEBHOOK_URL` with alert destination
3. Configure SSH credentials
4. Runs every 6 hours automatically

**Example Use**: Every 6 hours → 4 agents check codebase → Results aggregated → Trends analyzed → Alerts sent if degrading → Auto-fix attempted.

---

### 08 - Multi-Agent Code Development Pipeline
**Complexity**: High
**Use Case**: Autonomous development from task backlog

**Features**:
- Orchestrator reads BACKLOG.md hourly
- Planning Agent creates implementation plan
- Coding Agent implements features
- Review Agent checks code quality
- Testing Agent runs tests
- Documentation Agent updates docs
- Automatic commit and PR creation
- Retry logic for review failures (max 2 iterations)
- Task state tracking

**Setup**:
1. Create `BACKLOG.md` in your project root with tasks
2. Import workflow
3. Configure SSH credentials
4. Workflow checks for tasks every hour

**Example Use**: Add task to BACKLOG.md → Orchestrator picks it up → Planning → Coding → Review → Testing → Documentation → PR created → Backlog updated.

**BACKLOG.md Format**:
```markdown
# Backlog

## Pending
- [ ] Add user authentication
- [ ] Implement caching layer

## In Progress
- [~] Fix login bug (started by workflow)

## Completed
- [x] Add Docker support
```

---

### 09 - Multi-Repository Dependency Update Orchestrator
**Complexity**: Very High
**Use Case**: Coordinated dependency updates across multiple repos

**Features**:
- Scans multiple repositories daily
- Dependency graph analysis
- Priority-based update ordering
- Sequential updates with blast radius control
- Full test suite per repo
- Automatic rollback on test failure
- 10-minute monitoring between repos
- Update history tracking

**Setup**:
1. Import workflow
2. Edit "Initialize Update Session" node to list your repositories
3. Configure SSH credentials
4. Runs daily at 2 AM

**Example Use**: Daily scan → Dependencies ordered by graph → Update repo 1 → Test → Success → Wait 10 min → Update repo 2 → Repeat.

---

### 10 - Distributed Testing & Deployment Pipeline
**Complexity**: Very High
**Use Case**: Production-grade CI/CD with progressive rollout

**Features**:
- Parallel test execution (Unit, Integration, E2E, Security)
- Multi-environment deployment (DEV → STAGING → PROD)
- Health monitoring between deployments
- Maintenance window scheduling
- Progressive rollout (10% → 100%)
- Automatic rollback on health check failure
- Deployment history tracking

**Setup**:
1. Import workflow
2. Set up GitHub webhook for push to main
3. Configure SSH credentials
4. Configure environment deployment scripts
5. Test with sample push

**Example Use**: Git push to main → Tests run in parallel → DEV deploy → Monitor 10 min → STAGING deploy → Monitor 30 min → Schedule PROD → Wait for 2 AM → PROD deploy 10% → Monitor → PROD deploy 100% → Complete.

---

## 🔧 Setup Instructions

### General Setup Steps

1. **Install n8n**
   ```bash
   npm install -g n8n
   n8n start
   ```
   Access at `http://localhost:5678`

2. **Import Workflows**
   - Open n8n web interface
   - Click "Import from File"
   - Select workflow JSON file
   - Click "Import"

3. **Configure Credentials**

   **SSH Credentials** (required for most workflows):
   - Go to Credentials → New → SSH
   - Enter host, username, password/key
   - Save with ID "1" (or update workflow references)

   **Discord/Slack Webhooks**:
   - Create webhook in Discord/Slack settings
   - Replace `YOUR_DISCORD_WEBHOOK_URL` in workflows
   - Or store as credential for better security

4. **Configure Webhooks**

   For workflows with webhook triggers:
   - Note the webhook URL from n8n (e.g., `https://your-n8n.com/webhook/path`)
   - Configure external service (GitHub, Discord) to POST to this URL

5. **Activate Workflows**
   - Toggle workflow to "Active"
   - Check execution logs for errors

### Environment Variables

Recommended to set these in n8n:

```bash
# Claude Code
CLAUDE_API_KEY=your_api_key

# Webhook URLs (store as credentials)
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
```

## ⚙️ Configuration Guide

### Common Configuration Tasks

**1. Adjust Rate Limits**

Edit the "Rate Limiter" node:
```javascript
const RATE_LIMIT = 10; // Change to your desired limit
const WINDOW_MS = 60000; // Time window in milliseconds
```

**2. Modify Retry Behavior**

In SSH execution nodes:
```json
{
  "retryOnFail": true,
  "maxTries": 3,
  "waitBetweenTries": 2000
}
```

**3. Change Schedule Times**

Edit Schedule Trigger nodes:
```json
{
  "rule": {
    "interval": [
      {
        "field": "hours",
        "hoursInterval": 6  // Change interval
      }
    ]
  }
}
```

**4. Customize Monitoring Duration**

Edit Wait nodes:
```json
{
  "amount": 600000,  // 10 minutes in ms
  "unit": "ms"
}
```

**5. Adjust Alert Thresholds**

Edit condition nodes to change when alerts trigger:
```javascript
const threshold = 10; // Percentage change threshold
const hasNegativeTrend = currentSuccessRate < avgSuccessRate - threshold;
```

## 🚀 Advanced Usage

### Combining Workflows

You can trigger workflows from other workflows:

1. **Webhook Chaining**: Workflow A completes → HTTP Request node calls Webhook of Workflow B
2. **Database State Sharing**: Use n8n's static data to share state between workflows
3. **Event-Based Triggers**: Multiple workflows listen to same webhook, process in parallel

### Best Practices

1. **Error Handling**: Always use `continueOnFail: true` for agent nodes
2. **Logging**: Log important state changes to console for debugging
3. **Rate Limiting**: Prevent API throttling with rate limiter nodes
4. **Monitoring**: Track execution history in static data
5. **Security**: Never commit API keys; use n8n credentials
6. **Testing**: Test workflows in isolation before activating

### Performance Optimization

- **Parallel Execution**: Use multiple output branches for independent operations
- **Batch Processing**: Process multiple items in single execution
- **Static Data**: Use workflow static data instead of external database for small datasets
- **Webhook vs Polling**: Prefer webhooks over scheduled triggers when possible

## 🤝 Contributing

We welcome contributions from the community!

### How to Contribute

1. **Test and Improve**: Try these workflows in your environment and report issues
2. **Share Your Workflows**: Create new workflows for different use cases
3. **Documentation**: Improve setup instructions or add troubleshooting tips
4. **Bug Fixes**: Fix issues you encounter and submit improvements

### Contribution Guidelines

**Submitting New Workflows**:
- Follow the existing numbering scheme
- Include comprehensive error handling
- Document all required credentials
- Provide clear setup instructions
- Test workflow before submitting

**Reporting Issues**:
- Describe the workflow and node that failed
- Include error messages and logs
- Specify your n8n version and environment
- Provide steps to reproduce

**Improving Documentation**:
- Keep instructions clear and concise
- Include examples where helpful
- Update README when adding workflows

### Workflow Contribution Template

When submitting a new workflow, include:

```markdown
## Workflow Name
**Complexity**: [Simple/Medium/High/Very High]
**Use Case**: [One-line description]

**Features**:
- Feature 1
- Feature 2

**Setup**:
1. Step 1
2. Step 2

**Example Use**: [Describe a concrete example]

**Configuration**:
- Required credentials
- Environment variables
- External integrations
```

### Community

- **Issues**: https://github.com/ArchitectVS7/automaton-staging/issues
- **Discussions**: Share your use cases and improvements
- **Pull Requests**: Submit workflow improvements and new workflows

## 📝 License

These workflows are provided as-is for educational and experimental purposes. Modify and adapt them for your needs.

## 🙏 Acknowledgments

Built with:
- **n8n** - Workflow automation platform
- **Claude Code** - AI-powered coding assistant
- **Community contributions** - Thank you to all contributors!

---

**Note**: Always review workflows before deploying to production. These are samples designed to demonstrate patterns and possibilities, not production-ready solutions. Adapt security, error handling, and monitoring to your specific requirements.
