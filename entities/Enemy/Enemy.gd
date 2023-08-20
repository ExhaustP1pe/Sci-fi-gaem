extends CharacterBody3D
class_name Enemy

@export var _look_velocity: float = 66.6
@export var _enemy_speed: float = 10.0
@export var enemy_health: int = 100:
	set(value):
		if not _can_be_attacked: return
		enemy_health = value
		_can_be_attacked = false
		_cooldown_timer.start()
		if enemy_health < 1:
			queue_free()

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _can_be_attacked: bool = true

@onready var _agent: NavigationAgent3D = $agent
@onready var _cooldown_timer: Timer = $cooldown
@onready var _hitbox: Area3D = $hitbox
@onready var _attack_cooldown: Timer = $attack_cooldown

var _something_is_on_hitbox: Player

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	_move_to_player()
	move_and_slide()

func _move_to_player() -> void:
	if not is_on_floor():return
	var player = get_tree().get_first_node_in_group("Player") as Player
	_look_to_position(player.global_position, get_physics_process_delta_time())
	_agent.set_target_position(player.global_position)
	var current_position = global_transform.origin
	var next_location = _agent.get_next_path_position()
	var new_velocity = (next_location - current_position).normalized() * _enemy_speed
	
	velocity.x = new_velocity.x
	velocity.z = new_velocity.z

func _look_to_position(position_to_look: Vector3,delta: float) -> void:
	var T = global_transform.looking_at(position_to_look, Vector3.UP)
	global_transform.basis.x=lerp(global_transform.basis.x, T.basis.x, _look_velocity*delta)
	global_transform.basis.y=lerp(global_transform.basis.y, T.basis.y, _look_velocity*delta)
	global_transform.basis.z=lerp(global_transform.basis.z, T.basis.z, _look_velocity*delta)
	global_rotation.z = 0
	global_rotation.x = 0

func _on_cooldown_timeout() -> void:
	_can_be_attacked = true

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body is Player:
		_something_is_on_hitbox = body
		_attack_cooldown.start()

func _on_hitbox_body_exited(body: Node3D) -> void:
	if body is Player:
		_something_is_on_hitbox = null
		_attack_cooldown.stop()

func _on_attack_cooldown_timeout() -> void:
	_something_is_on_hitbox.give_damage(40)
