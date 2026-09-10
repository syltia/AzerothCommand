# Azeroth Command custom changes

This file tracks behavior intentionally different from upstream AzerothAdmin v24.

## Interface
- Azeroth Command visible branding.
- Dark default palette using normalized WoW RGB values.
- Button borders follow the selected button color.
- Theme reset action.

## Mini toolbar
- Vertical/horizontal orientation is saved in the profile.
- Orientation is changed from a visible MISC button.
- Right-click is deliberately not used for orientation because it conflicts with normal menu interaction.

## Server tools
- Top-right action sends `.reload ale`.
- Server `Reload Scripts` sends `.reload ale`.
- `.reload all` is blocked in the GUI after an unsafe full reload caused a worldserver crash during testing.
- Reload-table selector starts on `creature_template`.

## Localization
- enUS and frFR are loaded.
- Visible legacy `AzerothAdmin` branding is translated to `Azeroth Command` at runtime.
- Internal `AzerothAdmin` Lua/AceAddon names are kept for upstream compatibility.

## Project structure
- Main addon manifest is `AzerothCommand.toc`.
- Companion model addon remains named `AzerothAdmin_Models` internally for now, but depends on `AzerothCommand`.
- The unused duplicate `Data/Models.lua` is removed from the main addon tree; model data lives only in the LoadOnDemand companion addon.
