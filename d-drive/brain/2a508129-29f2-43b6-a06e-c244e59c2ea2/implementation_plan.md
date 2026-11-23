# Safely Update Minecraft Server & Geyser

Safely upgrade the server jar to the latest stable release (or the latest alpha/snapshot drop) and update the Geyser-Spigot plugin to ensure Bedrock player compatibility, while resolving a corrupted ViaVersion installation.

## User Review Required

> [!WARNING]
> Upgrading a Minecraft server carries risks of block/item data corruption if done incorrectly. 
> We will perform a complete filesystem backup of your worlds and plugins before swapping any files.
>
> You must choose between the two target versions below. **Option A is recommended** for long-term stability and plugin compatibility.

*   **Option A: Stable 26.1.2 (Recommended)**
    *   Highly stable, optimized, and compatible with all your existing plugins (Essentials, GriefPrevention, LuckPerms, etc.).
*   **Option B: Latest Version 26.2 ("Chaos Cubed")**
    *   Features the new *Sulfur Caves*, *Sulfur Cubes*, and Vulkan API support.
    *   *Risk:* Because this version is very new (released June 16, 2026), Paper builds are currently in **ALPHA**, which may cause plugins to crash or behave unexpectedly.

---

## Open Questions

> [!IMPORTANT]
> Which version would you like to update the server to?
> 1.  **Option A: stable 26.1.2** (Recommended for safety)
> 2.  **Option B: latest 26.2** (Latest features, but using alpha builds)

---

## Proposed Changes

### 1. Preparation & Backups
*   **Stop the Server**: We must gracefully stop the server (running on Process ID `6924`) to ensure all chunk data is saved. 
    *   *Action:* We ask you to type `/stop` in your server console, or we can send a soft-kill signal if console is inaccessible.
*   **Create Pre-Update Backup**: Archive the current folders (`world`, `world_nether`, `world_the_end`, `plugins`) into `backups\pre_update_backup.zip`.

### 2. File Updates
Depending on your selection, we will replace the files as follows:

#### [MODIFY] [server.jar](file:///d:/MinecraftServer/server.jar)
*   **Option A Link**: `https://fill-data.papermc.io/v1/objects/542288423062864e56969a44c6927b860152cb827c65ff5f841178602bc99e9a/paper-26.1.2-71.jar`
*   **Option B Link**: `https://fill-data.papermc.io/v1/objects/d175ef544246c69df6689d80f2525bad2faf41aa24c88f08fd6cfca15139495c/paper-26.2-23.jar`

#### [MODIFY] [Geyser-Spigot.jar](file:///d:/MinecraftServer/plugins/Geyser-Spigot.jar)
*   **Download URL**: `https://download.geysermc.org/v2/projects/geyser/versions/2.10.1/builds/1169/downloads/spigot`
*   **Description**: Updates Geyser to build `1169` (v`2.10.1`) supporting both Minecraft Bedrock 26.30 and older versions.

#### [MODIFY] [ViaVersion.jar](file:///d:/MinecraftServer/plugins/ViaVersion.jar)
*   **Download URL**: `https://github.com/ViaVersion/ViaVersion/releases/latest/download/ViaVersion.jar`
*   **Description**: Replaces the corrupted 232-byte ViaVersion jar with a fresh working build to allow older clients to connect.

---

## Verification Plan

### Manual Verification
1.  **Launch Server**: Run `start.bat` and inspect the command prompt for load errors.
2.  **Verify Plugins**: Confirm that all 13 plugins (including Geyser, Floodgate, and ViaVersion) initialize successfully.
3.  **Client Connectivity**:
    *   Have a Java client connect.
    *   Have a Bedrock client connect through Geyser (UDP port 19132).
