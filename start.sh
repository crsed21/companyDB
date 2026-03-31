#!/bin/bash
echo "============================================"
echo "  KZ Business Database - Starting server"
echo "============================================"
echo

# Install dependencies
pip3 install anthropic -q 2>/dev/null || pip install anthropic -q

# Open browser after 1.5s
(sleep 1.5 && open http://localhost:8000 2>/dev/null || xdg-open http://localhost:8000 2>/dev/null) &

# Start server
python3 server.py
