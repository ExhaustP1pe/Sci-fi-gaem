extends CharacterBody3D

@onready var camera_mount = $camera_mount
@onready var _animation_player: AnimationPlayer = $visuals/Constance/AnimationPlayer
@onready var visuals = $visuals

var SPEED = 3.0
const JUMP_VELOCITY = 4.5

@export var walking_speed: float = 3.0
@export var running_speed: float = 5.0

var _running: bool = false

var _is_locked: bool = false

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
		if _animation_player.current_animation == "idle" or _animation_player.current_animation == "Attack":
			visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))

func _physics_process(delta):
	if not _animation_player.is_playing():
		_is_locked = false
	_attack()
	_run()
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		_jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	_make_velocity(direction)
	move_and_slide()

func _jump() -> void:
	if _animation_player.current_animation != "jump": _animation_player.play("jump")
	velocity.y = JUMP_VELOCITY

func _attack() -> void:
	if not Input.is_action_just_pressed("Attack"): return
	if not is_on_floor(): return
	if _animation_player.current_animation == "Attack": return
	_animation_player.play("Attack")
	_is_locked = true

func _run() -> void:
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		_running = true
	else:
		SPEED = walking_speed
		_running = false

func _make_velocity(direction) -> void:
	if direction:
		if not is_on_floor(): return
		if _is_locked: return
		if _running and _animation_player.current_animation != "Run":
			_animation_player.play("Run")
		elif not _running and _animation_player.current_animation != "walk":
			print("a")
			_animation_player.play("walk")
			visuals.look_at(position+direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if _animation_player.current_animation != "idle": _animation_player.play("idle")
		if not is_on_floor() and _animation_player.current_animation != "falling":
			_animation_player.play("falling")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
