# Rocket Krizo — implementation design

This project now follows the original **Rocket Krizo: The Skydigger v1.30 (2017)** gameplay direction as closely as practical in the current Godot 4.7, 2D, asset-stub prototype. The modern character interpretation is an armadillo with a jetpack; the original document described Krizo as a mole.

## Fantasy
Krizo rejects the instinct to keep digging downward and turns his curiosity toward the sky, eventually travelling from his underground base through the atmosphere and into a fantastical universe.

## Run structure
1. Start standing in the underground launch base.
2. Press Launch and receive an automatic ignition sequence through the launch tunnel.
3. Take control after the initial propulsion.
4. Gain altitude measured in meters.
5. Explore changing altitude regions and collect resources.
6. Use Gas, Turbo, Nitro and Plasma boosts.
7. Survive static and warned moving obstacles; impacts knock Krizo around but do not directly end the run.
8. Fail only by falling below the allowed camera limit.
9. Bank coins, discoveries, achievements and best altitude.
10. Upgrade the rocket and launch again.

## Control modes
### Normal flight
Hold touch / left mouse to fire the jetpack. Pointer position determines horizontal steering while upward progress remains dominant. Horizontal world travel is not clamped to the original viewport.

### Highspeed Mode
Triggered by Nitro and Plasma. Krizo has strong constant vertical progress while pointer steering controls horizontal movement with intentionally slower response. The camera zooms out dynamically while Highspeed is active.

## Original boosts
- **Gas:** common, short upward impulse.
- **Turbo:** less common, much stronger impulse.
- **Nitro:** rare, powerful boost that activates Highspeed Mode.
- **Plasma:** rarest, stronger and longer Highspeed Mode.

## Failure
Obstacle collisions are recoverable. They cause knockback and a small fuel penalty. A run ends only when Krizo falls sufficiently below the camera.

## Altitude regions
Current placeholder implementation:
- 0–90 m: launch tunnel
- 90–350 m: sky
- 350–700 m: clouds
- 700–1200 m: upper atmosphere
- 1200+ m: space

Background color, obstacle tint and procedural decoration change with altitude. Clouds appear in the atmosphere and stars begin to populate space.

## Procedural universe
The beginning of every run is intentionally similar. Above the launch corridor, chunks become randomized. Static obstacles, moving warned hazards, fuel, coin trails, boosts and background decoration are generated around Krizo's current horizontal position.

## Progression
The original design calls for rocket customization and item-based progression. The current playable approximation is permanent garage upgrades:
- Tank
- Thrust
- Control
- Efficiency

Local persistence also tracks:
- best altitude
- coins
- run count
- discovered regions (cosmic map approximation)
- altitude achievements

## Record marker
The saved personal best appears as a physical line in the world at its altitude. Online friend records remain deferred until an online service exists.

## Intentionally deferred
The original document names several systems without enough mechanical detail, or which require content/backend work beyond this asset-free prototype:
- other playable animals
- full rocket cosmetic customization
- explicit equippable-item inventory
- friend leaderboards / online record markers
- exploration-on-foot gameplay on other worlds
- 3D presentation
- ads/revive monetization

Those should be implemented from actual design decisions rather than guessed from one-line feature mentions.
