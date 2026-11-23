# 🏙️ Hangout Cafe — Publishing Guide

## 🎨 Game Assets

### Logo (512×512)
![Hangout Cafe Logo](C:\Users\EI\.gemini\antigravity\brain\6121e200-00b1-4303-ab51-93efc023df7b\hangout_cafe_logo_1780225943348.png)

### Banner (1920×1080)
![Hangout Cafe Banner](C:\Users\EI\.gemini\antigravity\brain\6121e200-00b1-4303-ab51-93efc023df7b\hangout_cafe_banner_1780225970314.png)

---

## 🚀 Publishing Checklist

### Step 1 — Final Studio Prep
- [ ] Open **HangoutCafe.rbxl** in Roblox Studio
- [ ] Click **File → Publish to Roblox As…**
- [ ] Set Name: `Hangout Cafe`
- [ ] Set Description (see below)
- [ ] Set Genre: `Town and City`
- [ ] Set max players: **20–30** (recommended for a social hangout)

### Step 2 — Upload Assets
Go to **Creator Dashboard → [Your Game] → Configure**:
| Asset | Size | Where |
|-------|------|-------|
| Icon (Logo) | 512×512 px | Game Icon |
| Thumbnail (Banner) | 1920×1080 px | Thumbnails |

### Step 3 — Enable Voice Chat
`Creator Dashboard → Configure → Gear (⚙️) → Communication → Enable Voice Chat ✅`

> This is required for the 🎙️ mic feature in your chat to work for eligible players.

### Step 4 — Age/Access Settings
- Set to **Everyone** (All Ages) for maximum reach
- Turn ON **Allow Copying**: No (protect your work)

### Step 5 — Configure Game Settings in Studio
Go to **Home → Game Settings**:
| Setting | Value |
|---------|-------|
| Max Players | 25 |
| Server Fill | Fill each server |
| HTTP Requests | Enabled |
| Studio Access to APIs | Enabled |
| Avatar Type | R6 + R15 (Both) |

### Step 6 — StreamingEnabled (Already Done ✅)
Your `StreamingService.lua` handles this automatically on startup.

---

## 📝 Recommended Game Description

```
☕ Welcome to Hangout Cafe — the coziest spot around!

🌳 Explore the Cafe & Park with your friends
☕ Order Espresso, Lattes & the glowing SPECIAL BLEND
💃 Dance at the Disco Zone or emote anywhere on the map
🪧 Follow the neon signs to the Cafe Portal & Park Portal
👕 Try on merch looks and reset your avatar anytime
🎙️ Chat with players worldwide — auto-translated to your language!

A chill social hangout with premium Cafe & Park vibes.
```

---

## 🏷️ Recommended Tags / Keywords
`hangout`, `cafe`, `park`, `social`, `chill`, `roleplay`, `coffee`, `disco`, `friends`, `nature`

---

## ✅ All Systems — Final Status

| System | File | Status |
|--------|------|--------|
| ☕ Coffee ordering + drink animation | `CoffeeController.lua` | ✅ |
| 🪧 Sign boards (CAFE / PARK) | `SignService.lua` | ✅ |
| 👕 Clothing reset | `ResetService.lua` | ✅ |
| 🎭 Global emote panel (6 emotes) | `EmoteController.lua` | ✅ |
| 💃 Disco Zone dance | `EmoteService.lua` | ✅ |
| 💬 Custom chat + auto-translate | `ChatController.lua` | ✅ |
| 🎙️ Mic permission check | `ChatController.lua` | ✅ |
| ⚡ StreamingEnabled | `StreamingService.lua` | ✅ |
| 🌐 Teleport portals | `TeleportService.lua` | ✅ |
| 💡 Day/Night lighting | `LightingSync.lua` | ✅ |
| 🪑 Interactive seating | `SeatService.lua` | ✅ |

---

> [!TIP]
> After publishing, share the game link in Discord servers like **Roblox Dev**, **Social Hangout** groups, and your friends. The first 100 visits matter most for the algorithm!

> [!NOTE]
> If you update scripts via Rojo after publishing, you need to **re-publish** from Studio to push changes live.
