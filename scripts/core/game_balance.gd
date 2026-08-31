extends RefCounted
class_name GameBalance

const WORLD_LEFT: float = 92.0
const WORLD_RIGHT: float = 628.0
const PIXELS_PER_METER: float = 20.0
const CAMERA_LEAD: float = 300.0

const BASE_GRAVITY: float = 900.0
const BASE_THRUST: float = 1480.0
const BASE_HORIZONTAL_SPEED: float = 250.0
const BASE_FUEL_CAPACITY: float = 5.0
const BASE_BURN_RATE: float = 1.0
const BASE_RECHARGE_RATE: float = 0.12

const CHUNK_HEIGHT: float = 520.0
const PRELOAD_CHUNKS: int = 5
const DESPAWN_DISTANCE: float = 1700.0

static func fuel_capacity() -> float:
	return BASE_FUEL_CAPACITY + float(SaveManager.upgrade_level("tank")) * 0.75

static func thrust() -> float:
	return BASE_THRUST + float(SaveManager.upgrade_level("thrust")) * 70.0

static func horizontal_speed() -> float:
	return BASE_HORIZONTAL_SPEED + float(SaveManager.upgrade_level("control")) * 18.0

static func burn_rate() -> float:
	return maxf(0.55, BASE_BURN_RATE - float(SaveManager.upgrade_level("efficiency")) * 0.055)

static func difficulty_for_altitude(meters: int) -> float:
	return clampf(float(meters) / 1200.0, 0.0, 1.0)
