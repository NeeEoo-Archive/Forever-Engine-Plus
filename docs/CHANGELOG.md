# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Originally used by [ninjamuffin99](https://github.com/ninjamuffin99) in the [original Funkin' repo](https://github.com/ninjamuffin99/Funkin/blob/master/CHANGELOG.md).

## [0.2.0]
- Added a customizable credits menu - Everything you need for the credits menu (categories, peoples...) can be added in assets/data/credits.json!
- Added the flashing lights option
- Added options access into the HScript API
- Added some extra calls to scripts, like stepHit for shaders, update for the song's script, etc
- Added icons bops to freeplay
- Modified some modcharting scripts from the fnf-modding-tools library
- Tweaked a bit the main menu
- Fixed the shader bug when resizing the window thanks to [lunarcleint](https://www.youtube.com/watch?v=izZtJAmdfsI) on his bug fixes video
- Fixed the visible judgements and combo images bug when caching them at the countdown on PlayState
- Fixed the bg color tween on freeplay
- The charting state and editors are now only available on debug builds
- Removed some useless traces from PlayStates
- Expanded the songs and weeks system:
* The songs and weeks can be added in assets/data/weeks.json
* Custom story bg image
* Custom difficulties
* Custom week image
* You can hide weeks/songs on story mode and freeplay
* Characters on the story mode menu is now not mandatory, just type "NONE" somewhere in the array to hide the character, "NONE" three times to hide them all
* Easily modable story menu characters with jsons and seperated spritesheets
* Icons and story menu characters are now seperated, so we are not forced to name the icon and character with the same name
* I dont remember if there is more lol but unlocking system soon
## [0.1.0]
- Expanded characters with custom icons, healthbar colors etc
- Added HScript support thanks to my friend Leather128
- Added runtime shaders support with scripting
- Added cutscenes support
- Added timebar option (ig)
- Added some editors, available by pressing 7 on the main menu
- Fixed the resync vocals bug
- Removed validScore on the Song typedef on Song.hx (basically for charts), because it was useless
- Added a script for songs on PlayState (script.hxs) to add shaders, set cutscenes etc
