# Walkthrough - Sky Obby & Speed Coil Reward

We have successfully implemented a fully scripted, 5-stage **Sky Obby** that generates programmatically on server startup. It is connected to the cafe via portals and features custom checkpoint recovery, low gravity zones, fading obstacles, and a glowing **Speed Coil** reward!

---

## What Was Added

### 1. Programmatic Obby Generation
* To keep the cafe's performance high and workspace clean, the obby generates at `X=500, Y=150, Z=500` in the sky.
* The stages are built automatically from server code:
  * **Stage 1 (Pastel Steps):** Friendly rising platforms.
  * **Stage 2 (Fading Tiles):** Neon pink fading blocks that lose collision shortly after being touched.
  * **Stage 3 (Truss Climb):** Vertical truss and platform.
  * **Stage 4 (Kill Lasers):** A gray bridge spanned by red lasers that reset health on touch.
  * **Stage 5 (Low-Gravity Cloud Leap):** Circular clouds spaced far apart, triggering a floaty gravity drop.

### 2. Checkpoint & Quick Recovery System
* **Instant Fall-Back:** If you fall off any stage, the server instantly teleports you back to your furthest checkpoint **without killing you or reloading your character**. It is fast and frustration-free!
* **Respawn Protection:** If you reset or die on a laser, the server teleports you directly to your furthest checkpoint on spawn.

### 3. Portal Connections
* A cyan neon portal (`Teleport2_Start`) spawns near the cafe. Walking into it teleports you to the Obby entrance.
* A return portal (`Teleport3_Start`) spawns on the winner's platform at the end of the obby, sending you back to the cafe center.

### 4. Custom Speed Coil Tool
* Reaching the final platform awards a glowing **Speed Coil**.
* When equipped:
  * Increases your `WalkSpeed` to **32**.
  * Spawns a glowing neon blue trail behind your character.
  * Plays a speed hum sound effect.
* Unequipping restores standard speed and cleans up the visual/audio effects.

---

## Verification & Testing Instructions

1. **Stop & Play:** If your playtest is running, click **Stop** in Roblox Studio, wait a second for Rojo to sync the files, and click **Play** (or press **F5**).
2. **Find the Cafe Portal:**
   * Look around the cafe spawn/outdoor area. You will find a glowing cyan portal pad.
3. **Teleport to Obby:**
   * Step on the portal pad. You will be teleported up to the Sky Obby base.
4. **Play the Obby:**
   * **Stage 1:** Jump up the pastel blocks to Checkpoint 1 (ding sound, indicator bulb turns green).
   * **Stage 2:** Run quickly across the fading pink tiles. If you fall, you will be instantly teleported back to Checkpoint 1!
   * **Stage 3 & 4:** Climb the truss, activate Checkpoint 3, cross the laser bridge. Confim lasers kill you.
   * **Stage 5:** Jump onto the clouds. Your gravity will automatically drop to **50**, letting you make huge, floaty leaps to the finish line!
5. **Collect your Reward:**
   * Step on the golden pad at the end. You will receive the Speed Coil, and a server message will announce your win!
   * Step on the return portal to head back to the cafe.
