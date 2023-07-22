extends CharacterBody3D

@onready var camera_mount = $camera_mount
@onready var animation_player = $visuals/Constance/AnimationPlayer
@onready var visuals = $visuals
@onready var _hitbox: Area3D = $visuals/Constance/Armature/Skeleton3D/hitbox

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
	_camera_movement(event)

func _camera_movement(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, -0.741765, 0.741765) #Clamp's the camera rotation
		if animation_player.current_animation == "idle" or "Attack":
			visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))

func _physics_process(delta):
	if Input.is_action_just_pressed("Attack") and is_on_floor():
		if animation_player.current_animation == "Attack" or animation_player.current_animation == "Block": return
		is_locked = true
		animation_player.play("Attack")
		await get_tree().create_timer(.9,false).timeout
		_hitbox.show()
		_hitbox.monitoring = true
		
	if Input.is_action_just_pressed("Block") and is_on_floor():
		if animation_player.current_animation == "Block": return
		animation_player.play("Block")
		is_locked = true
	elif Input.is_action_just_released("Block") and is_on_floor():
		animation_player.play("idle")
		is_locked = false
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if !is_locked:
			if animation_player.current_animation == "jump": return
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


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	_hitbox.hide()
	_hitbox.monitoring = false
	is_locked = false

func _on_hitbox_body_entered(body: Node3D) -> void:
	body.queue_free()
