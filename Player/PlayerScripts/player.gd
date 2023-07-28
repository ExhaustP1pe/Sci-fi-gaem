extends CharacterBody3D
class_name Player

@onready var camera_mount = $camera_mount
@onready var animation_player = $visuals/Constance/AnimationPlayer
@onready var visuals = $visuals
@onready var _hitbox: Area3D = $visuals/Constance/Armature/Skeleton3D/hitbox_attachment/hitbox

const JUMP_VELOCITY = 4.5

@export var walking_speed = 3.0
@export var running_speed = 8.0

var _actual_speed: float

var _input_direction: Vector2
var _direction: Vector3

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5

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
	_input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	_direction = (transform.basis * Vector3(_input_direction.x, 0, _input_direction.y)).normalized()

func get_input_direction() -> Vector2:
	return _input_direction

func get_direction() -> Vector3:
	return _direction #return direction to move

func get_model() -> Node3D:
	return visuals #return model

func look_with_camera() -> void:
	if get_direction():
		visuals.look_at(position + _direction) 

func set_move(speed: float) -> void:
	velocity.x = get_direction().x * speed
	velocity.z = get_direction().z * speed
	_actual_speed = speed 
	move_and_slide()
	
func get_actual_speed() -> float:
	return _actual_speed

func get_hitbox() -> Area3D:
	return _hitbox
