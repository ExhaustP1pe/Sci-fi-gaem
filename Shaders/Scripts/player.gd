extends CharacterBody3D

@onready var camera_mount = $camera_mount
@onready var animation_player = $visuals/Constance/AnimationPlayer
@onready var visuals = $visuals

var SPEED = 3.0
const JUMP_VELOCITY = 4.5

@export var walking_speed = 5.0
@export var running_speed = 5.0

var running = false

var is_locked = false

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
		if animation_player.current_animation == "idle" or "Attack":
			visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))

func _physics_process(delta):
	
	if !animation_player.is_playing():
		is_locked = false
	
	if Input.is_action_just_pressed("Attack") and is_on_floor():
		if animation_player.current_animation != "Attack":
			animation_player.play("Attack")
			is_locked = true
	
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if !is_locked:
			if animation_player.current_animation != "jump":
				animation_player.play("jump")
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked and is_on_floor():
			if running:
				if animation_player.current_animation != "Run":
					animation_player.play("Run")
			else:
				if animation_player.current_animation != "Run":
					animation_player.play("Run")
					
			visuals.look_at(position+direction)
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !is_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
			
		if !is_on_floor():
			if animation_player.current_animation != "falling":
				animation_player.play("falling")
			
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if !is_locked:
		move_and_slide()
