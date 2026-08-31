# Rocket Krizo

> Um tatu cansou de cavar para baixo. A solução obviamente foi construir um jetpack e ir para cima.

Godot 4.7 prototype based on the original **Rocket Krizo: The Skydigger** game design, rebuilt as a 2D mobile arcade/roguelite with placeholder geometry until final assets arrive.

## Playable now

- starts with Krizo standing in his underground base
- automatic launch/ignition through a vertical tunnel
- hold + drag mouse/touch flight controls
- unrestricted horizontal travel with a camera that follows sideways
- altitude score in meters
- altitude-driven environment transition: tunnel → sky → clouds → upper atmosphere → space
- procedural clouds and stars
- static obstacles plus warned moving side hazards
- obstacle impacts are recoverable; **only falling below the camera ends the run**
- fuel pickups and coin trails
- original GDD boosts: **Gas, Turbo, Nitro, Plasma**
- Nitro/Plasma **Highspeed Mode** with delayed horizontal steering and dynamic camera zoom
- local best-altitude line shown inside the world
- persistent coins, run count, discoveries and achievements
- persistent garage upgrades: Tank, Thrust, Control, Efficiency
- local cosmic-map approximation via discovered altitude regions
- start, pause, garage, retry and game-over flows
- strict GDScript typing for Godot 4.7 warnings-as-errors

## Controls

Desktop:

- hold left mouse and drag: boost + steer
- Space: boost
- A/D or arrows: fallback steering
- P or Esc: pause

Mobile:

- hold and drag finger: boost + steer

During Nitro/Plasma Highspeed Mode, Krizo keeps accelerating upward while steering responds more slowly by design.

## Run it

1. Pull latest `main`.
2. Open `project.godot` in **Godot 4.7**.
3. Press F5.

## Structure

```text
scenes/
  game/
    game.tscn
    obstacle.tscn
    fuel_pickup.tscn
    coin_pickup.tscn
    boost_pickup.tscn
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
    boost_pickup.gd
  player/
    krizo.gd
assets/
  art/
  audio/
  fonts/
docs/
  GAME_DESIGN.md
```

See `docs/GAME_DESIGN.md` for the mapping between the 2017 GDD and the current implementation, including intentionally deferred systems that need assets, backend infrastructure, or additional design detail.
