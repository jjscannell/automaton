#!/bin/bash

# Claude Code Orchestration System - WSL Startup Script
# Copy this file to ~/start-orchestration.sh in WSL

echo "========================================"
echo "  Starting Orchestration System"
echo "========================================"
echo ""

# Start SSH server
echo "Starting SSH server..."
sudo service ssh start
if [ $? -eq 0 ]; then
    echo "✓ SSH server started"
else
    echo "✗ SSH server failed to start"
    exit 1
fi

# Start n8n in background
echo "Starting n8n..."
n8n > /tmp/n8n.log 2>&1 &
N8N_PID=$!
sleep 3

# Check if n8n started successfully
if ps -p $N8N_PID > /dev/null; then
    echo "✓ n8n started (PID: $N8N_PID)"
    echo "  Dashboard: http://localhost:5678"
else
    echo "✗ n8n failed to start"
    echo "  Check logs: tail /tmp/n8n.log"
    exit 1
fi

# Start ngrok if authtoken is configured
echo "Starting ngrok tunnel..."
if [ -f ~/.config/ngrok/ngrok.yml ]; then
    ngrok http 5678 > /tmp/ngrok.log 2>&1 &
    NGROK_PID=$!
    sleep 2

    if ps -p $NGROK_PID > /dev/null; then
        echo "✓ ngrok started (PID: $NGROK_PID)"
        echo "  Dashboard: http://localhost:4040"
        echo "  Getting public URL..."
        sleep 1
        PUBLIC_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"https://[^"]*' | grep -o 'https://[^"]*' | head -1)
        if [ -n "$PUBLIC_URL" ]; then
            echo "  Public URL: $PUBLIC_URL"
        fi
    else
        echo "⚠ ngrok failed to start (optional)"
    fi
else
    echo "⚠ ngrok not configured (skipping)"
    echo "  To enable: ngrok config add-authtoken YOUR_TOKEN"
fi

echo ""
echo "========================================"
echo "  System Ready!"
echo "========================================"
echo ""
echo "Services running:"
echo "  • n8n:   http://localhost:5678"
echo "  • ngrok: http://localhost:4040"
echo "  • SSH:   localhost:22"
echo ""
echo "To stop all services:"
echo "  pkill n8n && pkill ngrok && sudo service ssh stop"
echo ""
echo "Logs:"
echo "  n8n:   tail -f /tmp/n8n.log"
echo "  ngrok: tail -f /tmp/ngrok.log"
echo ""

# Keep script running to show logs
echo "Press Ctrl+C to stop monitoring..."
tail -f /tmp/n8n.log
