# Migration Plan: Move Antigravity Brain, Data, Scratch & Caches from C: Drive to D: Drive

## Overview
Drive `C:` currently has only **~5.03 GB** of free space, while Drive `D:` has **~908.6 GB** of available space. 
The Antigravity system directory at `C:\Users\EI\.gemini` currently occupies **~14.1 GB** on Drive `C:`.

This plan moves all Antigravity brain logs, conversations, scratch files, IDE caches, and browser recordings to `D:\.gemini` and links them using **Windows NTFS Directory Junctions (`mklink /J`)**.

---

## Storage Breakdown (`C:\Users\EI\.gemini`)
| Component | Folder Path | Current Size | Target Location on D: |
|---|---|---|---|
| **Scratch Workspace** | `C:\Users\EI\.gemini\antigravity\scratch` | ~6.69 GB | `D:\.gemini\antigravity\scratch` |
| **IDE Data & Caches** | `C:\Users\EI\.gemini\antigravity-ide` | ~4.45 GB | `D:\.gemini\antigravity-ide` |
| **Browser Recordings** | `C:\Users\EI\.gemini\antigravity\browser_recordings` | ~1.80 GB | `D:\.gemini\antigravity\browser_recordings` |
| **Brain & Conversations** | `C:\Users\EI\.gemini\antigravity\brain` & `conversations` | ~0.62 GB | `D:\.gemini\antigravity\brain` & `conversations` |
| **Browser Profile** | `C:\Users\EI\.gemini\antigravity-browser-profile` | ~0.50 GB | `D:\.gemini\antigravity-browser-profile` |
| **Total** | `C:\Users\EI\.gemini` | **~14.1 GB** | `D:\.gemini` |

---

## User Review Required

> [!IMPORTANT]
> - **Seamless Redirection**: Using Windows NTFS Directory Junctions (`mklink /J`), Windows will treat `C:\Users\EI\.gemini` as a transparent link pointing directly to `D:\.gemini`.
> - **No Broken Paths**: Applications, tools, scripts, and Antigravity will continue working without needing any path changes.
> - **Immediate Storage Relief**: Moving these files will free up over **14 GB** on Drive `C:` immediately, and all future AI brain/cache growth will go to Drive `D:`.

---

## Open Questions
- None. The migration plan uses native Windows junction points, which is the safest and most transparent method.

---

## Proposed Migration Steps

### Phase 1: Mirror Data to Drive D:
1. Create `D:\.gemini` directory structure.
2. Use `robocopy` to copy all data from `C:\Users\EI\.gemini` to `D:\.gemini` preserving structure, timestamps, and file attributes.

### Phase 2: Link Directories via Windows Junctions
1. For heavy non-locked subdirectories (`scratch`, `browser_recordings`, `antigravity-ide`, `antigravity-browser-profile`), remove the C: copy after copy verification and create junctions (`cmd /c mklink /J ...`).
2. For active session brain files, link subfolders safely so active log handles are preserved.

### Phase 3: Cleanup & Space Verification
1. Remove redundant copied files from C: once junctions are active.
2. Verify available space on C: and D: drives.

---

## Verification Plan

### Automated Tests / Commands
- Run `robocopy` verification to check file counts and sizes between source and target.
- Run `dir /A:L C:\Users\EI\.gemini\...` to confirm junction target targets `D:\.gemini\...`.
- Check `Get-PSDrive C` to verify freed space.

### Manual Verification
- Verify that agent artifacts, scratch files, and brain logs read/write normally.
