class_name GameUI
extends CanvasLayer
## All 2D GUI, built procedurally: main menu with high-score board,
## in-game HUD (score, wave, health, graft count, pause), pause overlay,
## and the game-over screen with name entry + leaderboard.

signal play_pressed
signal again_pressed
signal menu_pressed
signal pause_pressed
signal resume_pressed
signal name_submitted(player_name: String)

const CYAN := Color(0.28, 0.94, 1.0)
const MAGENTA := Color(1.0, 0.3, 0.85)
const DIM := Color(0.65, 0.75, 0.85)
const PANEL_BG := Color(0.03, 0.05, 0.1, 0.88)

var joystick: VirtualJoystick

var _hud: Control
var _menu: Control
var _over: Control
var _pause: Control

var _score_label: Label
var _best_label: Label
var _wave_label: Label
var _tentacle_label: Label
var _hp_bar: ProgressBar
var _hp_fill: StyleBoxFlat
var _banner: Label

var _menu_board: VBoxContainer
var _over_score: Label
var _over_board: VBoxContainer
var _name_row: HBoxContainer
var _name_edit: LineEdit
var _saved_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_joystick()
	_build_hud()
	_build_menu()
	_build_game_over()
	_build_pause()
	hide_all()

# ---------------------------------------------------------------- builders

func _make_label(text: String, size: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _make_button(text: String, size: int = 28) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(280, 64)
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_color", CYAN)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", MAGENTA)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.12, 0.2, 0.9)
	sb.border_color = CYAN
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(14)
	b.add_theme_stylebox_override("normal", sb)
	var sb_hover := sb.duplicate()
	sb_hover.bg_color = Color(0.1, 0.2, 0.32, 0.95)
	b.add_theme_stylebox_override("hover", sb_hover)
	var sb_press := sb.duplicate()
	sb_press.border_color = MAGENTA
	b.add_theme_stylebox_override("pressed", sb_press)
	return b

func _make_panel() -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = PANEL_BG
	sb.border_color = CYAN * Color(1, 1, 1, 0.5)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(18)
	sb.set_content_margin_all(28)
	p.add_theme_stylebox_override("panel", sb)
	return p

func _fullscreen_center() -> CenterContainer:
	var c := CenterContainer.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(c)
	return c

func _build_joystick() -> void:
	joystick = VirtualJoystick.new()
	joystick.set_anchors_preset(Control.PRESET_FULL_RECT)
	joystick.anchor_right = 0.46   # left side of the screen only
	add_child(joystick)

func _build_hud() -> void:
	_hud = Control.new()
	_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hud)

	var top_left := VBoxContainer.new()
	top_left.position = Vector2(24, 18)
	_hud.add_child(top_left)
	_score_label = _make_label("SCORE 0", 30, Color.WHITE)
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	top_left.add_child(_score_label)
	_best_label = _make_label("BEST 0", 18, DIM)
	_best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	top_left.add_child(_best_label)

	_hp_bar = ProgressBar.new()
	_hp_bar.min_value = 0
	_hp_bar.max_value = 100
	_hp_bar.value = 100
	_hp_bar.show_percentage = false
	_hp_bar.custom_minimum_size = Vector2(280, 20)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.05, 0.08, 0.14, 0.85)
	bg.set_corner_radius_all(10)
	_hp_bar.add_theme_stylebox_override("background", bg)
	_hp_fill = StyleBoxFlat.new()
	_hp_fill.bg_color = CYAN
	_hp_fill.set_corner_radius_all(10)
	_hp_bar.add_theme_stylebox_override("fill", _hp_fill)
	top_left.add_child(_hp_bar)

	_wave_label = _make_label("WAVE 1", 30, MAGENTA)
	_wave_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_wave_label.anchor_left = 0.5
	_wave_label.anchor_right = 0.5
	_wave_label.offset_left = -120
	_wave_label.offset_right = 120
	_wave_label.offset_top = 18
	_hud.add_child(_wave_label)

	_tentacle_label = _make_label("GRAFTS 0/8", 22, CYAN)
	_tentacle_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_tentacle_label.offset_left = -260
	_tentacle_label.offset_right = -24
	_tentacle_label.offset_top = -60
	_tentacle_label.offset_bottom = -20
	_hud.add_child(_tentacle_label)

	var pause_btn := _make_button("II", 26)
	pause_btn.custom_minimum_size = Vector2(64, 64)
	pause_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	pause_btn.offset_left = -88
	pause_btn.offset_right = -24
	pause_btn.offset_top = 18
	pause_btn.offset_bottom = 82
	pause_btn.pressed.connect(func(): pause_pressed.emit())
	_hud.add_child(pause_btn)

	_banner = _make_label("", 64, MAGENTA)
	_banner.set_anchors_preset(Control.PRESET_CENTER)
	_banner.offset_left = -400
	_banner.offset_right = 400
	_banner.offset_top = -160
	_banner.offset_bottom = -80
	_banner.modulate.a = 0.0
	_hud.add_child(_banner)

func _build_menu() -> void:
	var center := _fullscreen_center()
	_menu = center
	var panel := _make_panel()
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(box)

	box.add_child(_make_label("VOIDGRAFT", 76, CYAN))
	box.add_child(_make_label("Graft the deep. Outgun the swarm.", 20, DIM))
	box.add_child(HSeparator.new())
	box.add_child(_make_label("HIGH SCORES", 24, MAGENTA))
	_menu_board = VBoxContainer.new()
	_menu_board.add_theme_constant_override("separation", 2)
	box.add_child(_menu_board)
	box.add_child(HSeparator.new())

	var play := _make_button("PLAY", 34)
	play.pressed.connect(func(): play_pressed.emit())
	var play_wrap := CenterContainer.new()
	play_wrap.add_child(play)
	box.add_child(play_wrap)
	box.add_child(_make_label("Drag on the left side of the screen to fly.", 16, DIM))

func _build_game_over() -> void:
	var center := _fullscreen_center()
	_over = center
	var panel := _make_panel()
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(box)

	box.add_child(_make_label("SHIP LOST", 56, MAGENTA))
	_over_score = _make_label("SCORE 0", 34, Color.WHITE)
	box.add_child(_over_score)

	_name_row = HBoxContainer.new()
	_name_row.add_theme_constant_override("separation", 10)
	_name_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_name_edit = LineEdit.new()
	_name_edit.max_length = 12
	_name_edit.placeholder_text = "YOUR NAME"
	_name_edit.custom_minimum_size = Vector2(300, 56)
	_name_edit.add_theme_font_size_override("font_size", 24)
	_name_row.add_child(_name_edit)
	var submit := _make_button("SAVE", 24)
	submit.custom_minimum_size = Vector2(140, 56)
	submit.pressed.connect(_on_submit_name)
	_name_edit.text_submitted.connect(func(_t): _on_submit_name())
	_name_row.add_child(submit)
	box.add_child(_name_row)

	_saved_label = _make_label("", 20, CYAN)
	box.add_child(_saved_label)

	box.add_child(_make_label("HIGH SCORES", 22, MAGENTA))
	_over_board = VBoxContainer.new()
	_over_board.add_theme_constant_override("separation", 2)
	box.add_child(_over_board)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 20)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	var again := _make_button("PLAY AGAIN", 26)
	again.pressed.connect(func(): again_pressed.emit())
	buttons.add_child(again)
	var menu_btn := _make_button("MENU", 26)
	menu_btn.pressed.connect(func(): menu_pressed.emit())
	buttons.add_child(menu_btn)
	box.add_child(buttons)

func _build_pause() -> void:
	_pause = Control.new()
	_pause.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_pause)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause.add_child(center)
	var panel := _make_panel()
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(box)
	box.add_child(_make_label("PAUSED", 48, CYAN))
	var resume := _make_button("RESUME", 28)
	resume.pressed.connect(func(): resume_pressed.emit())
	box.add_child(resume)
	var quit := _make_button("QUIT TO MENU", 24)
	quit.pressed.connect(func(): menu_pressed.emit())
	box.add_child(quit)

# ---------------------------------------------------------------- board

func _fill_board(board: VBoxContainer, entries: Array, highlight_rank: int = -1, max_rows: int = 10) -> void:
	for child in board.get_children():
		child.queue_free()
	if entries.is_empty():
		board.add_child(_make_label("no scores yet — be the first", 18, DIM))
		return
	for i in mini(entries.size(), max_rows):
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(420, 0)
		var color := Color(1.0, 0.95, 0.4) if i == highlight_rank else Color.WHITE
		var rank := _make_label("%d." % (i + 1), 20, color if i == highlight_rank else DIM)
		rank.custom_minimum_size = Vector2(44, 0)
		rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.add_child(rank)
		var name_l := _make_label(str(entries[i]["name"]), 20, color)
		name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_l)
		var score_l := _make_label(str(int(entries[i]["score"])), 20, color)
		score_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(score_l)
		board.add_child(row)

# ---------------------------------------------------------------- state

func hide_all() -> void:
	_hud.visible = false
	_menu.visible = false
	_over.visible = false
	_pause.visible = false
	joystick.visible = false
	joystick.reset()

func show_menu(entries: Array) -> void:
	hide_all()
	_menu.visible = true
	_fill_board(_menu_board, entries, -1, 5)

func show_hud(best: int) -> void:
	hide_all()
	_hud.visible = true
	joystick.visible = true
	_best_label.text = "BEST %d" % best

func show_game_over(score: int, qualifies: bool, entries: Array) -> void:
	joystick.visible = false
	joystick.reset()
	_hud.visible = false
	_over.visible = true
	_over_score.text = "SCORE %d" % score
	_name_row.visible = qualifies
	_saved_label.text = "" if qualifies else " "
	_name_edit.text = GameState.last_name
	_fill_board(_over_board, entries)

func on_score_saved(rank: int, entries: Array) -> void:
	_name_row.visible = false
	_saved_label.text = "SAVED — RANK %d" % (rank + 1) if rank >= 0 else "SAVED"
	_fill_board(_over_board, entries, rank)

func set_pause_visible(v: bool) -> void:
	_pause.visible = v

# ---------------------------------------------------------------- updates

func update_score(score: int) -> void:
	_score_label.text = "SCORE %d" % score

func update_wave(wave: int) -> void:
	_wave_label.text = "WAVE %d" % wave

func update_health(hp: float, max_hp: float) -> void:
	_hp_bar.max_value = max_hp
	_hp_bar.value = hp
	var frac := hp / max_hp
	_hp_fill.bg_color = CYAN.lerp(Color(1.0, 0.25, 0.3), 1.0 - frac)

func update_tentacles(count: int, max_count: int) -> void:
	_tentacle_label.text = "GRAFTS %d/%d" % [count, max_count]

func flash_banner(text: String) -> void:
	_banner.text = text
	_banner.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_banner, "modulate:a", 1.0, 0.25)
	tw.tween_interval(1.2)
	tw.tween_property(_banner, "modulate:a", 0.0, 0.5)

func _on_submit_name() -> void:
	var n := _name_edit.text.strip_edges()
	if n.is_empty():
		n = "PILOT"
	name_submitted.emit(n)
