# Azeroth Command

Azeroth Command is a customized fork of [AzerothAdmin](https://github.com/superstyro/AzerothAdmin) for **AzerothCore 3.3.5a**.

The goal of this fork is to keep the proven AzerothAdmin command layer while providing a cleaner WoW-style dark interface and server-administration conveniences for an AzerothCore + ALE/Eluna setup.

## Current customizations

- Azeroth Command branding.
- Dark interface palette using normalized WoW RGB values.
- Button borders follow the selected button color.
- One-click **Reload ALE** (`.reload ale`).
- `Reload Scripts` also uses `.reload ale`.
- Dangerous `.reload all` is blocked in the GUI; reload table defaults to `creature_template`.
- Mini toolbar can be switched between vertical and horizontal from the MISC tab.
- Theme reset button restores the default Azeroth Command dark palette.
- English and French locales enabled.
- Legacy `/azerothadmin` and `/aa` commands retained for compatibility; `/azerothcommand` and `/ac` are added.

## Installation

Copy the addon folder to:

```text
World of Warcraft/Interface/AddOns/AzerothCommand
```

The folder must be named **AzerothCommand** because the addon uses that path for its assets. If you downloaded GitHub's source ZIP, rename the extracted `AzerothCommand-master` folder to `AzerothCommand`.

Then restart WoW or use `/reload`.

This addon is **client-side only**. It sends GM commands to AzerothCore; no Azeroth Command server module is required.

## Compatibility note

The internal Lua/AceAddon namespace and SavedVariables still use `AzerothAdmin` names on purpose. Keeping those internal identifiers avoids breaking upstream code and existing user settings while the visible project is branded Azeroth Command.

## Upstream and license

Upstream: https://github.com/superstyro/AzerothAdmin

Azeroth Command remains distributed under the upstream **GPLv3** license. Original copyright notices and attribution are preserved in source files.
