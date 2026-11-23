# 🧠 Antigravity Brain Backup

This repository is a backup of my **Antigravity AI assistant** data — including conversation transcripts, project source code, and configuration — created on **2026-11-23** before switching to a new laptop.

> **GitHub username:** ybsolanki  
> **Email:** solankikappu82@gmail.com

---

## 📁 Structure

```
antigravity-backup/
├── brain/                          # Conversation transcripts (JSONL)
│   ├── 380929b6-.../logs/          # Current convo (this backup session)
│   ├── 766f420f-.../logs/          # ZEDOX Browser project convo
│   └── e30fcb60-.../logs/          # ZEDOX icon/logo convo
│
├── projects/
│   └── shield-browser/             # Privacy browser project (Electron + PWA)
│       ├── desktop/                # Electron desktop app source
│       └── web/                    # PWA web source
│
├── config/
│   ├── config.json                 # Antigravity plugin config
│   ├── AGENTS.md                   # Custom AI rules/instructions
│   └── projects/                   # Project workspace configs
│
└── README.md                       # This file
```

---

## 💬 Conversation History Summary

| Conversation | Topic |
|---|---|
| `766f420f` | **ZEDOX Browser** — Built a Brave-like privacy browser (Electron + PWA) with cookie blocking, ad blocking, search history hiding, and a custom new-tab page |
| `e30fcb60` | **ZEDOX Icon** — Generated the ZEDOX Browser app icon/logo |
| `c59be819` | **PC troubleshooting** — Help with a site not loading |
| `ec55ef2d` | **Ubuntu Linux Quiz** — Tried to create a Google Form quiz |
| `380929b6` | **This session** — Backing up brain to GitHub |

---

## 🚀 Projects

### ZEDOX Browser (Shield Browser)
- **Path:** `projects/shield-browser/`
- **Tech:** Electron (desktop) + Express + vanilla JS (PWA)
- **Features:** Cookie blocking, ad blocking, search history privacy, custom new-tab page, cool logo
- **Also on GitHub:** https://github.com/ybsolanki/zedox-mashtalk (separate repo)

---

## 🛠️ How to Restore on New Laptop

1. Install [Antigravity](https://antigravity.dev) on the new laptop
2. Clone this repo:  
   `git clone https://github.com/ybsolanki/antigravity-backup.git`
3. Restore project:  
   - Copy `projects/shield-browser/` to your workspace
   - Run `npm install` in `desktop/` and `web/` folders
4. Restore config:  
   - Copy `config/AGENTS.md` to `C:\Users\<you>\.gemini\config\AGENTS.md`
   - Copy `config/config.json` to `C:\Users\<you>\.gemini\config\config.json`
5. The conversation transcripts in `brain/` are readable JSONL files you can review anytime

---

## ⚙️ Custom AI Rules (AGENTS.md)

The `config/AGENTS.md` file contains custom rules set for the AI:
- Science visualization: prefer interactive sidecar viewers (Mol*, etc.)

---

*Backed up with ❤️ by Antigravity AI on 2026-11-23*
