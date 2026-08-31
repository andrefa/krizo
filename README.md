# Krizo

> Um tatu cansou de cavar para baixo. A solução obviamente foi construir um jetpack e ir para cima.

Vertical arcade/roguelite mobile game inspired by the feel of classic Flash vertical-climbing games and the progression loop of Motherload.

## Current state

The repo is intentionally **asset-free** for now. Everything visual is placeholder geometry so gameplay can be tuned before final art lands.

Implemented before first engine pass:

- portrait Godot 4 project
- hold/touch jetpack flight
- keyboard and touch steering
- gravity, thrust, terminal fall speed and fuel
- camera that only climbs upward
- procedural chunk generation
- randomized obstacle placement
- fuel pickups
- coin pickups and per-run currency
- altitude and best-altitude tracking
- local JSON save
- persistent coin wallet
- permanent upgrade shop
- tank / thrust / control / efficiency upgrades
- retry loop
- pause/resume
- start screen and game-over stats
- placeholder character animation (lean, squash, flame jitter)
- cleanup of old generated chunks
- central balance constants
- strict GDScript typing compatible with warnings-as-errors

## Run it

Target editor: **Godot 4.7**.

1. Pull the latest `main`.
2. Open `project.godot` in Godot 4.7.
3. Let Godot reimport/upgrade project metadata if it asks.
4. Press F5.

Desktop controls:

- Space / mouse hold: jetpack
- A/D or arrows: steer
- P or Esc: pause

Mobile:

- hold finger to boost
- horizontal finger position steers Krizo

## Structure

```text
scenes/
  game/
    game.tscn
    obstacle.tscn
    fuel_pickup.tscn
    coin_pickup.tscn
  player/
    krizo.tscn
scripts/
  core/
    game_balance.gd
    save_manager.gd
  game/
    game.gd
    run_generator.gd
    obstacle.gd
    fuel_pickup.gd
    coin_pickup.gd
  player/
    krizo.gd
assets/
  art/
  audio/
  fonts/
docs/
  GAME_DESIGN.md
```

## First engine pass checklist

1. Confirm every script parses in Godot 4.7.
2. Tune gravity/thrust until flying feels fun.
3. Verify touch coordinate mapping on a real phone.
4. Tune collision shapes against the placeholder silhouette.
5. Adjust generated obstacle density and safe routes.
6. Verify UI anchoring across common phone ratios.
7. Replace placeholder `Visual` with final Krizo sprites only after movement feels right.

## Product rule

Keep the MVP small. No backend, login, multiplayer or cloud save until the core run loop is actually fun.
