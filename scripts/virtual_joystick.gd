class_name VirtualJoystick
extends Control
## On-screen touch joystick. Cover the left portion of the screen with this
## control; the stick base appears wherever the player first touches
## (floating joystick). `output` is a Vector2 in the unit disc:
## x = right, y = down (matches the XZ ground plane top-down mapping).
##
## Everything is drawn procedurally with _draw() — no textures.

const RADIUS := 110.0
const KNOB_RADIUS := 44.0
const BASE_COLOR := Color(0.28, 0.94, 1.0, 0.10)
const RING_COLOR := Color(0.28, 0.94, 1.0, 0.45)
const KNOB_COLOR := Color(0.28, 0.94, 1.0, 0.55)
const HINT_COLOR := Color(0.28, 0.94, 1.0, 0.16)

var output := Vector2.ZERO

var _touch_index := -1
var _center := Vector2.ZERO
var _knob := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func reset() -> void:
	_touch_index = -1
	output = Vector2.ZERO
	queue_redraw()

func _input(event: InputEvent) -> void:
	if not visible or not is_inside_tree():
		return
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1 and get_global_rect().has_point(event.position):
			_touch_index = event.index
			_center = event.position
			_knob = event.position
			output = Vector2.ZERO
			queue_redraw()
		elif not event.pressed and event.index == _touch_index:
			reset()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		var delta: Vector2 = event.position - _center
		if delta.length() > RADIUS:
			delta = delta.normalized() * RADIUS
		_knob = _center + delta
		output = delta / RADIUS
		queue_redraw()

func _draw() -> void:
	if _touch_index == -1:
		# Resting hint circle so players know where to touch.
		var hint := size * Vector2(0.5, 0.62)
		draw_circle(hint, RADIUS * 0.55, HINT_COLOR)
		draw_arc(hint, RADIUS * 0.55, 0.0, TAU, 48, RING_COLOR * Color(1, 1, 1, 0.5), 2.0)
		return
	var origin := get_global_rect().position
	var c := _center - origin
	var k := _knob - origin
	draw_circle(c, RADIUS, BASE_COLOR)
	draw_arc(c, RADIUS, 0.0, TAU, 64, RING_COLOR, 3.0)
	draw_circle(k, KNOB_RADIUS, KNOB_COLOR)
	draw_arc(k, KNOB_RADIUS, 0.0, TAU, 32, RING_COLOR, 2.0)
