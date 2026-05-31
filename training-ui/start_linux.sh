#!/bin/bash

# Navigate to the script's directory
cd "$(dirname "$0")"

# Port: use the first argument if given, otherwise default to 8080
# (3000 is avoided to prevent clashes with other local apps).
UI_PORT="${1:-3001}"

echo "Starting Anima Training UI on http://localhost:${UI_PORT} ..."

# Check if node_modules exists, if not prompt to install
if [ ! -d "node_modules" ]; then
    echo "node_modules not found. Installing dependencies..."
    npm install
fi

# Start the application
npm start -- --port="${UI_PORT}"

echo ""
echo "Application exited (check for errors above)."
