# Walkthrough: Blox Fruits PowerTool v2.0

I have successfully expanded the `PowerTool.luau` script into a comprehensive automation suite for Blox Fruits. The script now handles the entire gameplay loop from quest acceptance to NPC farming with professional-grade stealth.

## Key Features

### 1. Automated Quest Protocol
- **Dynamic Selection**: Automatically identifies the best quest for your current level.
- **Island Navigation**: Uses safe, high-speed tweening to travel between islands (e.g., Starter -> Jungle -> Desert).
- **Auto-Accept**: Automatically interacts with Quest NPCs via remote events to start the recommended quest.

### 2. Phantom Farmer Engine
- **Targeted Farming**: Automatically locates and teleports above the specific NPCs required for your active quest.
- **Safe Combat**: Positioned 15 studs above enemies to avoid damage while automatically activating your equipped weapon.
- **Auto-Equip**: Ensures a weapon is always held when starting the farm cycle.
- **Mob Magnet**: (Optional) Pulls enemies together to maximize farming efficiency.

### 3. Professional Stealth & UI
- **Metatable Bypasses**: Hooks `__index` and `__namecall` to hide script-modified properties (like Fly movements) from the game's anti-cheat.
- **Premium UI**: A sleek, dark-themed interface with glassmorphism effects and custom toggles.
- **Safe Parentage**: Attempts to hide the UI within `CoreGui` to further reduce detection footprint.

## How to Use

1. **Load the Script**: Execute either `UniversalTracker.luau` (for items) or `PowerTool.luau` (for automation).
2. **Enable Features**:
   - **FLIGHT RECTIFIER**: For manual movement.
   - **AUTO-QUEST PROTOCOL**: To start the quest cycle.
   - **PHANTOM FARMER**: To begin the combat cycle.
3. **Island Hopping**: The script will automatically travel to the correct island if you don't have the current quest active.

> [!TIP]
> Use **AUTO-QUEST** and **PHANTOM FARMER** together for a completely hands-off leveling experience.

---
**Paths:**
- [PowerTool.luau](file:///D:/Antigravity/BloxFruitsScript/PowerTool.luau)
- [UniversalTracker.luau](file:///D:/Antigravity/BloxFruitsScript/UniversalTracker.luau)
