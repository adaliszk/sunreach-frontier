extends Node

signal cycle_tick(state: int)
signal turn_tick(state: int)
signal night_tick(state: int)
signal day_tick(state: int)

var _TIMER: Timer

var _CYCLE = -1
var _MAX_CYCLE = 8
var _TURN = 0

var _HAS_STARTED = false

const SPEED_VALUES = [INF, 2.0, 1.0, 0.5]
enum SPEED { PAUSE, NORMAL, DOUBLE, TRIPLE }


func _ready() -> void:
	connect("cycle_tick", _on_cycle_tick.bind(self))
	connect("turn_tick", _on_turn_tick.bind(self))

	emit_signal("cycle_tick", _CYCLE + 1)
	emit_signal("turn_tick", _TURN + 1)

	_TIMER = Timer.new()
	_TIMER.connect("timeout", tick.bind(self))
	set_speed(SPEED.NORMAL)
	add_child(_TIMER)


func set_speed(speed: SPEED) -> void:
	_TIMER.wait_time = SPEED_VALUES[speed]


func get_speed() -> String:
	var index = SPEED.values().find(_TIMER.wait_time)
	return SPEED.keys()[index]


func get_timeout() -> float:
	return _TIMER.wait_time


func start_ticks() -> void:
	_HAS_STARTED = true
	_TIMER.start()


func stop_ticks() -> void:
	_TIMER.stop()


func reset_ticks() -> void:
	_CYCLE = 0
	_TURN = 1


func has_started() -> bool:
	return _HAS_STARTED


func tick(_event) -> void:
	emit_signal("cycle_tick", _CYCLE + 1)


func get_turn() -> int:
	return _TURN


func get_cycle() -> int:
	return _CYCLE


func get_max_cycle() -> int:
	return _MAX_CYCLE


func _on_turn_tick(_state: int, _event) -> void:
	_TURN = _TURN + 1
	_CYCLE = 0


func _on_cycle_tick(_state: int, _event) -> void:
	_CYCLE = _state

	if _state > _MAX_CYCLE:
		emit_signal("turn_tick", _TURN)

	if _state < 7:
		emit_signal("day_tick", _TURN + _CYCLE)
		return

	emit_signal("night_tick", _TURN + (_CYCLE - 7))
