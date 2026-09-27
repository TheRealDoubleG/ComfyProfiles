# ComfyProfiles

**Version 0.3 – Beta**  
**Target: World of Warcraft: Forever 1.60.1 / Interface 16001**  
Author: **TheRealDoubleG**  
Discord: **the.real.double.g**

Central profile coordinator for the Comfy Suite on WoW Forever.

A central front end above the standalone profile engines already built into each Comfy addon.

ComfyProfiles is developed specifically for **WoW: Forever**. Retail/Modern WoW, Midnight and WoW Classic are not compatibility targets.

## 0.1 Beta
- Added named Suite profiles across loaded Comfy addons.
- Added change preview and recovery snapshot before application.
- Added import/export for Suite presets.
- Does not require AceDB and does not take ownership of another addon's SavedVariables.

## Design notes
Unified Profile Manager and ProfileManager show the value of central profile coordination, previews and recovery. ComfyProfiles applies those lessons to the existing Comfy profile APIs.

The referenced third-party addons were used only to study public feature ideas, long-term bug patterns and architecture lessons. ComfyProfiles uses original Comfy Suite code and Blizzard UI assets.

## Commands
- /comfyprofiles
- /cprofiles

## Safety
Profile application is explicit, previewable where relevant, and recovery data is saved before destructive changes.
