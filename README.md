# Krizo

> Um tatu cansou de cavar para baixo. A solução obviamente foi construir um jetpack e ir para cima.

Prototype of a vertical arcade/roguelite mobile game inspired by the feel of classic Flash vertical-climbing games and the progression loop of Motherload.

## Current prototype

This first commit intentionally uses **code-drawn placeholder assets**. No final art is included yet.

Already playable:

- hold mouse / touch / Space to fire the jetpack
- A/D or arrows to steer on desktop
- gravity, thrust and fuel consumption
- gentle fuel recharge while not boosting
- upward-only camera tracking
- altitude counter
- fuel HUD
- collision with rocks and retry flow
- fuel pickups
- simple squash/tilt/flame animation from code
- portrait mobile viewport (720×1280)

## Requirements

- Godot 4.3+ recommended

Open `project.godot` and press **F6/F5**.

## Structure

```text
scenes/
  game/
    game.tscn
    obstacle.tscn
    fuel_pickup.tscn
  player/
    krizo.tscn
scripts/
  game/
    game.gd
    obstacle.gd
    fuel_pickup.gd
  player/
    krizo.gd
assets/
  art/        # final character/environment art later
  audio/      # music + SFX later
  fonts/
```

## Design direction

The MVP should stay brutally small:

1. Make flying feel good.
2. Build an interesting vertical route.
3. Add collectible resources.
4. Add a basic between-runs upgrade loop.
5. Replace placeholders with Krizo's final art.
6. Add mobile polish, sound and monetization only after the core loop is fun.

## Placeholder philosophy

The current Krizo is deliberately made from `Polygon2D` nodes instead of temporary copyrighted art. This lets us tune silhouette, collision, scale, animation and camera behavior before committing to sprites.

When final sprites arrive, the `Visual` node inside `scenes/player/krizo.tscn` can be replaced by `AnimatedSprite2D` without changing the movement code.
