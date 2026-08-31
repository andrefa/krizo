extends RefCounted
class_name GameBalance

const WORLD_LEFT := 92.0
const WORLD_RIGHT := 628.0
const PIXELS_PER_METER := 20.0
const CAMERA_LEAD := 300.0

const BASE_GRAVITY := 900.0
const BASE_THRUST := 1480.0
const BASE_HORIZONTAL_SPEED := 250.0
const BASE_FUEL_CAPACITY := 5.0
const BASE_BURN_RATE := 1.0
const BASE_RECHARGE_RATE := 0.12

const CHUNK_HEIGHT := 520.0
const PRELOAD_CHUNKS := 5
const DESPAWN_DISTANCE := 1700.0

static func fuel_capacity() -> float:
	return BASE_FUEL_CAPACITY + SaveManager.upgrade_level("tank") * 0.75

static func thrust() -> float:
	return BASE_THRUST + SaveManager.upgrade_level("thrust") * 70.0

static func horizontal_speed() -> float:
	return BASE_HORIZONTAL_SPEED + SaveManager.upgrade_level("control") * 18.0

static func burn_rate() -> float:
	return max(0.55, BASE_BURN_RATE - SaveManager.upgrade_level("efficiency") * 0.055)

static func difficulty_for_altitude(meters: int) -> float:
	return clamp(float(meters) / 1200.0, 0.0, 1.0)
