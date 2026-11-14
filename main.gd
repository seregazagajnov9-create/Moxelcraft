extends Node3D

const WORLD_SIZE := 10
const BLOCK_SIZE := 1.0

var player: CharacterBody3D
var cam: Camera3D

func _ready():
	_generate_world()
	_spawn_player()

func _generate_world():
	for x in range(-WORLD_SIZE, WORLD_SIZE):
		for z in range(-WORLD_SIZE, WORLD_SIZE):
			var h := int(2.0 * sin(x / 5.0) + 2.0 * cos(z / 5.0)) + 2
			for y in range(h + 1):
				var col := Color(0.3, 0.7, 0.3)
				if y < h - 2:
					col = Color(0.5, 0.5, 0.5)
				elif y < h:
					col = Color(0.5, 0.35, 0.2)
				_make_block(Vector3(x, y, z), col)

func _make_block(pos: Vector3, col: Color):
	var body := StaticBody3D.new()
	body.position = pos
	add_child(body)

	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3.ONE
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	mesh.material_override = mat
	body.add_child(mesh)

	var shape := CollisionShape3D.new()
	var bshape := BoxShape3D.new()
	bshape.size = Vector3.ONE
	shape.shape = bshape
	body.add_child(shape)

func _spawn_player():
	player = CharacterBody3D.new()
	player.position = Vector3(0, 8, 0)
	add_child(player)

	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.8
	col.shape = cap
	col.position = Vector3(0, 0.9, 0)
	player.add_child(col)

	cam = Camera3D.new()
	cam.position = Vector3(0, 1.6, 0)
	player.add_child(cam)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50, -30, 0)
	add_child(light)

	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	sky.sky_material = ProceduralSkyMaterial.new()
	e.sky = sky
	env.environment = e
	add_child(env)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

const SPEED := 6.0
const JUMP := 7.0
var gravity := 20.0

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		player.rotate_y(-event.relative.x * 0.003)
		cam.rotate_x(-event.relative.y * 0.003)
		cam.rotation.x = clamp(cam.rotation.x, -1.5, 1.5)

func _physics_process(dt):
	if not player.is_on_floor():
		player.velocity.y -= gravity * dt
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		player.velocity.y = JUMP

	var dir := Vector3.ZERO
	if Input.is_key_pressed(KEY_W): dir -= player.transform.basis.z
	if Input.is_key_pressed(KEY_S): dir += player.transform.basis.z
	if Input.is_key_pressed(KEY_A): dir -= player.transform.basis.x
	if Input.is_key_pressed(KEY_D): dir += player.transform.basis.x
	player.velocity.x = dir.x * SPEED
	player.velocity.z = dir.z * SPEED
	player.move_and_slide()
