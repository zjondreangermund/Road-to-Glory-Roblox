# Local Setup

## Requirements
- Roblox Studio
- Rojo
- Git

## First run
1. Clone this repository.
2. Open Roblox Studio and create/open a blank place.
3. From the repository folder run `rojo serve`.
4. Connect the Rojo Studio plugin to the running project.
5. Sync the project into Studio.
6. Press Play.

V0.1 creates its own prototype pitch, two goal triggers and football at runtime, so a custom map is not required yet.

## Controls
- E: Shoot
- Q: Pass
- F: Toggle dribble
- Mobile: SHOOT, PASS and DRIBBLE touch buttons are created automatically.

## Current prototype rule
The player's facing/camera direction determines the kick direction. The server validates kick distance and owns the football physics.
