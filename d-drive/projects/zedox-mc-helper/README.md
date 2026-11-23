# Zedox Helper Bot (`zedoxhelper`)

An AI-powered Minecraft helper bot built with Mineflayer and Google Gemini.

## Features
- **AI Brain**: Talk to the bot naturally in-game chat.
- **Natural Language Commands**:
    - "Follow me" -> Bot follows you.
    - "Stay there" or "Stop" -> Bot stops.
    - "Collect some iron_ore" -> Bot searches and mines nearby ore.
    - "Go to 100 64 200" -> Bot navigates to coordinates.
- **Direct Commands** (Prefix with `,`):
    - `,follow`
    - `,goto <x> <y> <z>`
    - `,status`
    - `,stop`

## Setup

1. **API Key**: 
   - Open `.env` and replace `your_gemini_api_key_here` with your API key from [Google AI Studio](https://aistudio.google.com/).
2. **Server Configuration**:
   - The bot is currently set to connect to `localhost:25565`. 
   - If your server is on a different IP/Port, update `MC_HOST` and `MC_PORT` in `.env`.
3. **Run**:
   - Double-click `start.bat` to launch the bot.

## Requirements
- Node.js installed.
- Minecraft Server (Version 1.21.1 recommended, but compatible with others).
- Offline mode (cracked) is supported as `online-mode=false` was detected in your server settings.
