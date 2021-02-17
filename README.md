# CapsuleWars
> A 3D multiplayer FPS (First Person Shooter) made in Godot, using GDScript.

A small project developed to allow up to 6 players play a short and fun FPS match online. The game has many features present in the majority of games of the genre and shows some of Godot's engine capabilities.

## Footage
[![](https://img.youtube.com/vi/ne4kvwK5yFY/0.jpg)](https://youtu.be/ne4kvwK5yFY)

## Installation

Windows:

1. Download the CapsuleWars.rar file from [releases](https://github.com/lucassene/CapsuleWars/releases).
2. Install it in your disk. You need *both* the .exe and .pck files.

## Hosting a game

1. Hit the "Host a game" button.
2. If you want, you can change the default port (23571). Just type it in the *Port* Field in the lobby inside the game, otherwise, leave it blank.
3. If you have a router/modem that supports UPnP, check the "Use UPnP" on. Otherwise, you will need to port forward the desired port in your device's configuration. If you need any help, try this [website](https://www.noip.com/support/knowledgebase/general-port-forwarding-guide/).
4. With the above steps out of the way, just hit the *Host* button.
5. Give your *external* IP to the people you want to play with and wait them to join (google "whats my ip").
6. After everyone is ready, hit the *Begin* button.

## Joining a game

1. Have the external IP of the person which will be hosting
2. Hit the "Join a game" button.
3. Type the IP in the *IP* field in the lobby inside the game.
4. If the host changed the default port, type it in the *Port field*, ortherwise, leave it blank.
5. Hit the *Join* button.
6. Hit the "Ready" button when you're done.

## Features

This games presents features, such as:
- A multiplayer game that uses P2P (Peer-to-peer) connection.
- UPnP support.
- Cel shading for the capsules.
- A lobby screen where players can host/join a game, with a chatlog providing feedback on the connection statuses.
- A player Finite State Machine.
- Heavy usage of signals (callbacks).
- Player position interpolation to minimize lag effect.
- Inherited scenes.
- Exported variables that can alter different weapon's behaviour inside the editor, without the need of any coding.
- Usage of particles in blood and bullets.
- A scalable UI.
- Simple animations made with the bult-in Godot's Animation Player.
- Usage of singletons (autoloads).
- The level was prototyped with CSG primitives. Some of them were changed afterward to regular meshes to improve performance.
- Designed with scalability in mind.


## Release History
* 1.0.3-beta
    * Added UPnP support
    * Added damage indicator
    * Improved lobby
    * Increased Pulse Rifle magazine
    * Decreased Sniper Rifle magazine
    * Fixed weapons positions when holstered
    * Improved death splash

* 1.0.2-beta
    * Improved player name and life bar interface
    * Tweaks in weapons
    * Flinch received are now weapon-based
    * Added damage received feedback
    * Added knife hit feedback
    * Added controller support
    * Better scoreboard cell sizes
    * Player can now change loadout after joining a session
    * Bigger spawn area of detection

* 1.0.1-beta
    * Some bug fixes and tweaks
    * Added left-handed input support

* 1.0.0-beta
    * First beta version release

## Meta

> If you have played the game, please let me know how it was. Send me an email telling it, I'll be forever grateful.

Lucas Sene Grandchamp – lsgrandchamp@gmail.com

[https://github.com/lucassene](https://github.com/lucassene)
