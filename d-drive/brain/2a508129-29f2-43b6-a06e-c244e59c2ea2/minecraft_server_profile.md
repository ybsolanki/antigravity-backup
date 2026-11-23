# Zedox Minecraft Server Profile

A detailed analysis and profile of the **Zedox Network** Minecraft server environment, configurations, staff structure, and plugins.

---

## 🖥️ Server Specifications & Environment

*   **Server Software**: [Paper 1.21.11](https://papermc.io) (Running build `1.21.11-69-main@94d0c97`)
*   **Java Runtime**: Java 25 (OpenJDK 64-Bit Server VM 25.0.1+8-LTS; Eclipse Adoptium Temurin-25.0.1+8)
*   **Operating System**: Windows 10
*   **Memory Allocation**: 3 GB RAM (`-Xms3G -Xmx3G`)
*   **Execution Command**: `java -Xms3G -Xmx3G -jar server.jar --nogui`
*   **Storage Location**: `d:\MinecraftServer`

---

## ⚙️ Core Configuration (`server.properties`)

| Property | Value | Description |
| :--- | :--- | :--- |
| **Server Port** | `25565` | Standard Minecraft Java port |
| **Online Mode** | `false` | Cracked/Offline server (Allows logins from non-premium clients) |
| **Max Players** | `20` | Maximum simultaneous players |
| **Game Mode** | `Survival` | Default gamemode for new players |
| **Difficulty** | `Easy` | Server-wide baseline difficulty |
| **Level Name** | `world` | Root world directory name |
| **Spawn Protection** | `16` | Radius in blocks protected around world spawn |
| **View Distance** | `10` | Render distance in chunks |
| **Simulation Distance**| `10` | Active simulation distance in chunks |
| **MOTD** | `§b§lZEDOX NETWORK §f§l» §d§lSURVIVAL §f| §b§lPVP §f| §e§lECONOMY\n§6§l» §f§nJoin the Adventure\! §6§l« §a§l1.21.x` | Cyan and purple formatted message of the day |

---

## 👥 Server Administration (Operators & Whitelist)

### 🛡️ Operators (Ops)
The following players have Level 4 administrative access:
*   **ZEDOX** (UUID: `751de170-8e53-3d1c-9488-6946ca58c204`)
*   **Zedox_ZEDOX** (UUID: `1128c54d-e441-38a0-88a5-832b6a2b9d00`)
*   **.Ybgaming43** (UUID: `00000000-0000-0000-0009-01ffc676e842`)

> [!NOTE]
> The whitelist is currently **disabled** (`whitelist.json` is empty, and `enforce-whitelist=false` in `server.properties`).

---

## 🔌 Active Plugins & Key Settings

The server runs **12 initialized plugins**:

### 1. GriefPrevention (v16.18.5) — Land Claiming
*   **World Modes**:
    *   `world` (Overworld): **Survival** (Land claiming enabled)
    *   `world_the_end` (The End): **Survival** (Land claiming enabled)
    *   `world_nether` (The Nether): **Disabled** (Land claiming turned off)
*   **Claiming Tools**: Golden Shovel (creation/modification) and Stick (claim checking/investigation).
*   **Claim Accrual**: Players start with `100` claim blocks and accrue `100` blocks per hour of active play up to a maximum of `80,000` blocks.
*   **PvP Settings**: PvP is active in all worlds. Fresh spawns are protected, and logging out in combat triggers a punishment. The active combat timeout is `15` seconds.

### 2. LuckPerms (v5.5.37) — Permissions
*   **Storage Method**: H2 database (`luckperms-h2-v2.mv.db`).
*   **Integration**: Hooked into Vault for chat and permission prefix handling.

### 3. EssentialsX (v2.21.2) — Server Utilities
*   **Storage**: Flat-file JSON structure.
*   **Kits Configuration**:
    *   `tools` (Cooldown: 10s): Starter stone tools.
    *   `dtools` (Cooldown: 600s): Named custom diamond gear (e.g., Gigadrill, Dwarf shovel, Top Hat helm) and triggers a `/broadcast` command.
    *   `notch`, `color`, `firework` (Cooldown: 6000s).

### 4. Geyser-Spigot (v2.9.5) & Floodgate (v2.2.5) — Bedrock Compatibility
*   **Bedrock Listener Port**: UDP `19132`.
*   **Auth Type**: Floodgate is active, permitting Bedrock players to join cracked/offline mode servers. Bedrock player usernames are prefixed with `.` (e.g. `.Shubh0811`, `.kevin1238525`).

### 5. Other Utilities
*   **PlayerWarps (v4.2.1)**: Allows players to publish and manage their custom warps.
*   **WorldEdit (v7.4.0)**: Advanced map editing capabilities.
*   **sTrails (v1.0)**: Cosmetic player trails.
*   **spark**: Built-in CPU and memory profiler.
*   **ViaVersion**: Allows newer Minecraft client versions to connect (currently has loading errors due to a corrupt plugin jar file).

---

## 📍 Registered Warp Locations

### PlayerWarps (Published by ZEDOX)
*   `zombifarm`: Location: `world` (x: `-1389.87`, y: `-52.0`, z: `1120.50`)
*   `mobfarm`: Location: `world` (x: `-711.28`, y: `180.0`, z: `392.15`)

### Essentials Warps
*   `deasrt` (Desert): Location: `world` (x: `245,876.5`, y: `70.0`, z: `168,598.4`)
*   `endermanfarm`: Location: `world_the_end` (x: `72.15`, y: `1.0`, z: `228.94`)
*   `ironfarm`
*   `mobfarm`
*   `portaltop`
*   `sugercen`
*   `xpfarm`

---

## 💾 Backup & Update Strategies

### 1. Automated Backups (`start.bat`)
When the Minecraft server is stopped, `start.bat` executes a PowerShell backup routine:
```powershell
powershell -Command "$date = Get-Date -Format 'yyyyMMdd_HHmmss'; Compress-Archive -Path world, world_nether, world_the_end, plugins -DestinationPath backups\backup_$date.zip -Force"
```
This automatically packs all world dimensions and plugins into a timestamped `.zip` file stored in the `backups\` directory.

### 2. Updating Script (`update_server_v3.ps1`)
Updates are handled via a PowerShell utility script that pulls official downloads:
*   **Paper Jar**: Downloads the latest build of Paper 1.21.11.
*   **Geyser-Spigot**: Downloads the latest Geyser-Spigot build.
*   **ViaVersion**: Downloads the latest stable ViaVersion release.
