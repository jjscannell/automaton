const { Client, GatewayIntentBits } = require('discord.js');
const axios = require('axios');

// Bot configuration from environment variables
const BOT_TOKEN = process.env.DISCORD_BOT_TOKEN;
const WEBHOOK_URL = process.env.N8N_WEBHOOK_URL || 'http://n8n:5678/webhook/discord-claude';
const BOT_PREFIX = process.env.BOT_PREFIX || '!claude';

if (!BOT_TOKEN) {
  console.error('ERROR: DISCORD_BOT_TOKEN environment variable is required!');
  process.exit(1);
}

// Create Discord client
const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
  ],
});

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
      timeout: 120000 // 2 minute timeout for Claude
    });

    console.log(`✓ Forwarded to n8n successfully`);

    // n8n will handle sending the response back via Discord webhook
    // So we don't need to reply here

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
  console.error('Please check your DISCORD_BOT_TOKEN environment variable');
  process.exit(1);
});
