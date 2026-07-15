extends Node3D
## VOIDGRAFT — main game controller.
##
## Builds the whole world procedurally in _ready() (environment, arena,
## starfield, player, UI), then runs the wave director: enemy tentacles
## spawn from off screen, grow in size and number as waves advance, and on
## death break into parts that graft onto the player's ship.
##
## Also provides the shared combat services used by every weapon:
##   damage_tentacle_at()      – area damage vs tentacle spline points
##   get_nearest_tentacle_point() – targeting query
##   spawn_projectile() / fire_laser() / spawn_burst() / collect_part()

enum State { MENU, PLAYING, GAME_OVER }

const SPAWN_RADIUS := 27.0
const WAVE_DURATION := 20.0
const MAX_WAVE_TENTACLES := 11

var arena_radius := 22.0

var state: State = State.MENU
var score := 0
var wave := 1

var _wave_timer := 0.0
var _spawn_timer := 1.5
var _survival_tick := 0.0

var player: Player
var ui: GameUI

func _ready() -> void:
	randomize()
	_build_environment()
	_build_arena()
	_build_starfield()
	_build_dust()

	player = Player.new()
	player.main = self
	add_child(player)

	ui = GameUI.new()
	add_child(ui)
	player.joystick = ui.joystick

	ui.play_pressed.connect(_start_game)
	ui.again_pressed.connect(_restart)
	ui.menu_pressed.connect(_to_menu)
	ui.pause_pressed.connect(_pause)
	ui.resume_pressed.connect(_resume)
	ui.name_submitted.connect(_on_name_submitted)
	player.health_changed.connect(func(hp, max_hp): ui.update_health(hp, max_hp))
	player.died.connect(_on_player_died)

	if GameState.auto_start:
		GameState.auto_start = false
		_start_game()
	else:
		ui.show_menu(GameState.high_scores)

func is_playing() -> bool:
	return state == State.PLAYING

# ---------------------------------------------------------------- flow

func _start_game() -> void:
	state = State.PLAYING
	score = 0
	wave = 1
	_wave_timer = 0.0
	_spawn_timer = 1.0
	player.controls_enabled = true
	ui.show_hud(GameState.best_score())
	ui.update_score(0)
	ui.update_wave(1)
	ui.update_health(player.hp, Player.MAX_HP)
	ui.update_tentacles(0, Player.MAX_TENTACLES)
	ui.flash_banner("WAVE 1")

func _restart() -> void:
	GameState.auto_start = true
	get_tree().paused = false
	get_tree().reload_current_scene()

func _to_menu() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _pause() -> void:
	if state != State.PLAYING:
		return
	get_tree().paused = true
	ui.set_pause_visible(true)

func _resume() -> void:
	get_tree().paused = false
	ui.set_pause_visible(false)
	ui.joystick.reset()

func _on_player_died() -> void:
	if state != State.PLAYING:
		return
	state = State.GAME_OVER
	spawn_burst(player.global_position, Color(0.4, 0.95, 1.0), 60, 10.0)
	spawn_burst(player.global_position, Color(1.0, 0.6, 0.2), 40, 7.0)
	player.shake(2.0)
	ui.show_game_over(score, GameState.qualifies(score), GameState.high_scores)

func _on_name_submitted(player_name: String) -> void:
	var rank := GameState.add_score(player_name, score)
	ui.on_score_saved(rank, GameState.high_scores)

# ---------------------------------------------------------------- director

func _process(delta: float) -> void:
	if state != State.PLAYING:
		return

	_survival_tick += delta
	if _survival_tick >= 1.0:
		_survival_tick -= 1.0
		score += 1
		ui.update_score(score)

	_wave_timer += delta
	if _wave_timer >= WAVE_DURATION:
		_wave_timer = 0.0
		wave += 1
		ui.update_wave(wave)
		ui.flash_banner("WAVE %d" % wave)

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = maxf(4.4 - wave * 0.25, 1.6)
		var alive := get_tree().get_nodes_in_group("tentacles").size()
		if alive < mini(2 + wave, MAX_WAVE_TENTACLES):
			_spawn_tentacle()

func _spawn_tentacle() -> void:
	var t := Tentacle.new()
	t.main = self
	t.player = player
	t.style = [Tentacle.Style.WAVE, Tentacle.Style.SWING, Tentacle.Style.SWIRL].pick_random()
	t.full_length = minf(15.0 + wave * 1.8, 34.0) * randf_range(0.85, 1.15)
	t.girth = minf(0.5 + wave * 0.05, 1.1)
	t.max_hp = 16.0 + wave * 7.0
	t.amplitude = randf_range(2.4, 4.4)
	t.speed_scale = randf_range(0.8, 1.3)
	t.track_speed = 0.35 + wave * 0.02
	t.score_value = 10 + wave * 5
	t.died.connect(_on_tentacle_died)
	# Position must be set before add_child so _ready() can aim inward.
	var angle := randf() * TAU
	t.position = Vector3(sin(angle), 0, cos(angle)) * SPAWN_RADIUS
	add_child(t)

func _on_tentacle_died(t: Tentacle) -> void:
	score += t.score_value
	ui.update_score(score)
	player.shake(0.5)

	var points := t.hit_points()
	if points.is_empty():
		return
	spawn_burst(points[points.size() - 1], Color(1.0, 0.3, 0.9), 30, 7.0)
	spawn_burst(points[points.size() / 2], Color(0.7, 0.2, 0.8), 20, 5.0)

	# Break apart: chunks fly off the spline and home to the ship.
	var part_count := clampi(2 + wave / 3, 2, 5)
	for i in part_count:
		var part := TentaclePart.new()
		part.main = self
		part.player = player
		add_child(part)
		var idx := randi_range(points.size() / 3, points.size() - 1)
		part.global_position = points[idx]

# ---------------------------------------------------------------- combat

func damage_tentacle_at(pos: Vector3, radius: float, damage: float) -> bool:
	var r2 := radius * radius
	for t in get_tree().get_nodes_in_group("tentacles"):
		if t.dying:
			continue
		for p in t.hit_points():
			if p.distance_squared_to(pos) < r2:
				t.take_damage(damage)
				return true
	return false

## Returns the best aim point (Vector3) within max_range, or null.
func get_nearest_tentacle_point(from: Vector3, max_range: float) -> Variant:
	var best: Variant = null
	var best_d2 := max_range * max_range
	for t in get_tree().get_nodes_in_group("tentacles"):
		if t.dying:
			continue
		var p: Vector3 = t.target_point()
		var d2 := from.distance_squared_to(p)
		if d2 < best_d2:
			best_d2 = d2
			best = p
	return best

func spawn_projectile(pos: Vector3, dir: Vector3) -> void:
	var p := Projectile.new()
	p.main = self
	p.direction = dir.normalized()
	add_child(p)
	p.global_position = pos

func fire_laser(from: Vector3, to: Vector3, damage: float) -> void:
	var dir := to - from
	var dist := dir.length()
	if dist < 0.1:
		return
	var beam := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.05
	mesh.bottom_radius = 0.05
	mesh.height = dist
	beam.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 1.0, 0.9, 0.9)
	mat.emission_enabled = true
	mat.emission = Color(0.2, 1.0, 0.75)
	mat.emission_energy_multiplier = 3.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam.material_override = mat
	add_child(beam)
	var y := dir / dist
	var x := y.cross(Vector3.UP)
	if x.length_squared() < 0.001:
		x = Vector3.RIGHT
	x = x.normalized()
	var z := x.cross(y).normalized()
	beam.global_transform = Transform3D(Basis(x, y, z), (from + to) * 0.5)
	var tw := create_tween()
	tw.tween_property(mat, "albedo_color:a", 0.0, 0.18)
	tw.tween_callback(beam.queue_free)

	damage_tentacle_at(to, 1.5, damage)
	spawn_burst(to, Color(0.2, 1.0, 0.75), 8, 3.5)

func collect_part(pos: Vector3) -> void:
	if player.dead:
		return
	spawn_burst(pos, Color(0.4, 1.0, 1.0), 10, 3.0)
	if player.add_tentacle():
		score += 5
		ui.update_tentacles(player.tentacle_count(), Player.MAX_TENTACLES)
	else:
		score += 25   # ship is fully grafted: convert to bonus score
	player.heal(3.0)
	ui.update_score(score)

## One-shot radial particle burst, self-freeing.
func spawn_burst(pos: Vector3, color: Color, count: int, speed: float) -> void:
	var burst := GPUParticles3D.new()
	burst.amount = count
	burst.lifetime = 0.7
	burst.one_shot = true
	burst.explosiveness = 1.0
	burst.local_coords = false
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = 0.25
	pm.spread = 180.0
	pm.gravity = Vector3.ZERO
	pm.initial_velocity_min = speed * 0.4
	pm.initial_velocity_max = speed
	pm.damping_min = speed * 0.5
	pm.damping_max = speed * 0.9
	pm.scale_min = 0.5
	pm.scale_max = 1.2
	var ramp := Gradient.new()
	ramp.set_color(0, Color(color.r, color.g, color.b, 1.0))
	ramp.set_color(1, Color(color.r * 0.3, color.g * 0.3, color.b * 0.3, 0.0))
	var ramp_tex := GradientTexture1D.new()
	ramp_tex.gradient = ramp
	pm.color_ramp = ramp_tex
	burst.process_material = pm
	var quad := QuadMesh.new()
	quad.size = Vector2(0.3, 0.3)
	var qmat := StandardMaterial3D.new()
	qmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	qmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	qmat.vertex_color_use_as_albedo = true
	qmat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	quad.material = qmat
	burst.draw_pass_1 = quad
	add_child(burst)
	burst.global_position = pos
	burst.emitting = true
	get_tree().create_timer(1.4).timeout.connect(burst.queue_free)

# ---------------------------------------------------------------- world

func _build_environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.008, 0.012, 0.035)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.25, 0.3, 0.45)
	env.ambient_light_energy = 1.0
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.7
	env.glow_bloom = 0.1
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, 35, 0)
	sun.light_energy = 0.9
	sun.light_color = Color(0.8, 0.85, 1.0)
	add_child(sun)

func _build_arena() -> void:
	var floor_disc := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = arena_radius + 5.0
	disc.bottom_radius = arena_radius + 5.0
	disc.height = 0.1
	disc.radial_segments = 48
	floor_disc.mesh = disc
	var fmat := StandardMaterial3D.new()
	fmat.albedo_color = Color(0.02, 0.03, 0.07)
	fmat.metallic = 0.3
	fmat.roughness = 0.7
	floor_disc.material_override = fmat
	floor_disc.position = Vector3(0, -0.6, 0)
	add_child(floor_disc)

	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = arena_radius - 0.2
	torus.outer_radius = arena_radius + 0.15
	ring.mesh = torus
	var rmat := StandardMaterial3D.new()
	rmat.albedo_color = Color(0.28, 0.94, 1.0)
	rmat.emission_enabled = true
	rmat.emission = Color(0.15, 0.6, 0.9)
	rmat.emission_energy_multiplier = 1.6
	ring.material_override = rmat
	ring.position = Vector3(0, -0.35, 0)
	add_child(ring)

func _build_starfield() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	var star := SphereMesh.new()
	star.radius = 0.09
	star.height = 0.18
	star.radial_segments = 6
	star.rings = 3
	var smat := StandardMaterial3D.new()
	smat.albedo_color = Color(0.9, 0.95, 1.0)
	smat.emission_enabled = true
	smat.emission = Color(0.8, 0.9, 1.0)
	smat.emission_energy_multiplier = 1.2
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	star.material = smat
	mm.mesh = star
	mm.instance_count = 350
	for i in mm.instance_count:
		var r := randf_range(6.0, 75.0)
		var a := randf() * TAU
		var pos := Vector3(cos(a) * r, randf_range(-16.0, -4.0), sin(a) * r)
		var s := randf_range(0.4, 1.6)
		var xf := Transform3D(Basis().scaled(Vector3.ONE * s), pos)
		mm.set_instance_transform(i, xf)
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	add_child(mmi)

func _build_dust() -> void:
	# Slow ambient motes drifting over the arena for depth/parallax.
	var dust := GPUParticles3D.new()
	dust.amount = 70
	dust.lifetime = 7.0
	dust.preprocess = 7.0
	dust.local_coords = false
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(arena_radius, 2.0, arena_radius)
	pm.direction = Vector3(1, 0, 0.3)
	pm.spread = 40.0
	pm.gravity = Vector3.ZERO
	pm.initial_velocity_min = 0.3
	pm.initial_velocity_max = 1.0
	pm.scale_min = 0.3
	pm.scale_max = 1.0
	var ramp := Gradient.new()
	ramp.set_color(0, Color(0.5, 0.8, 1.0, 0.0))
	ramp.set_color(1, Color(0.5, 0.8, 1.0, 0.0))
	ramp.add_point(0.3, Color(0.5, 0.8, 1.0, 0.25))
	var ramp_tex := GradientTexture1D.new()
	ramp_tex.gradient = ramp
	pm.color_ramp = ramp_tex
	dust.process_material = pm
	var quad := QuadMesh.new()
	quad.size = Vector2(0.14, 0.14)
	var qmat := StandardMaterial3D.new()
	qmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	qmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	qmat.vertex_color_use_as_albedo = true
	qmat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	quad.material = qmat
	dust.draw_pass_1 = quad
	dust.position = Vector3(0, 1.0, 0)
	add_child(dust)
