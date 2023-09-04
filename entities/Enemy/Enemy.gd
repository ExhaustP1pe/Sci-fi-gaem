extends CharacterBody3D
class_name Enemy

@export var _look_velocity: float = 66.6 # The speed at which the enemy can look at its target.
@export var _enemy_speed: float = 10.0 # The movement speed of the enemy.
@export_range(2, 240) var _enemy_vision_range # The angle range in which the enemy can detect the player.
@export var enemy_health: int = 100: # The health of the enemy.
	set(value):
		if not _can_be_attacked: return # If the enemy can't be attacked, ignore changes to health.
		enemy_health = value
		_can_be_attacked = false # Prevent further attacks temporarily.
		_cooldown_timer.start() # Start a cooldown timer.
		if enemy_health < 1:
			queue_free() # Destroy the enemy if its health reaches zero.

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") # Get the default gravity from project settings.
var _can_be_attacked: bool = true # A flag to determine if the enemy can be attacked.

@onready var _agent: NavigationAgent3D = $agent # Reference to the navigation agent for pathfinding.
@onready var _cooldown_timer: Timer = $cooldown # Cooldown timer for attacks.
@onready var _hitbox: Area3D = $hitbox # The hitbox of the enemy.
@onready var _attack_cooldown: Timer = $attack_cooldown # Cooldown timer for attacking.
@onready var _raycast = $raycast # Raycast for detecting the player.

var _something_is_on_hitbox: Player # Reference to what's on the enemy's hitbox.

@onready var player = get_tree().get_first_node_in_group("Player") as Player # Reference to the player.

var _last_player_position: Vector3

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta # Apply gravity if not on the floor.
	
	var my_position = transform.basis.z
	var distance_to_player = (player.global_position - global_position).normalized()
	
	if acos(my_position.dot(distance_to_player)) >= deg_to_rad(_enemy_vision_range):
		_raycast.look_at(player.global_position) # Point the raycast towards the player.
		_raycast.force_raycast_update() # Update the raycast.
		if _raycast.is_colliding(): #if is colliding
			var collider = _raycast.get_collider() #get collider
			if collider is Player:
				_raycast.debug_shape_custom_color = Color.GREEN #change color of raycast to green
				_move_to_target(player.global_position, delta) #start moving to player position
				_last_player_position = player.global_position #save the last player position
			else: 
				_raycast.debug_shape_custom_color = Color.RED #change color of raycast to red
				_move_to_target(_last_player_position, delta) #move to last player position
	move_and_slide() # Move the enemy.

func _move_to_target(target_position: Vector3, delta: float) -> void:
	if not is_on_floor(): return
	_look_to_position(target_position, delta) # Make the enemy look at the target.
	_agent.set_target_position(target_position) # Set the target position for navigation.
	var current_position = global_transform.origin
	var next_location = _agent.get_next_path_position()
	var new_velocity = (next_location - current_position).normalized() * _enemy_speed
	
	velocity.x = new_velocity.x
	velocity.z = new_velocity.z

func _look_to_position(position_to_look: Vector3, delta: float) -> void:
	# Idk how its works, but it works
	var T = global_transform.looking_at(position_to_look, Vector3.UP) # Calculate a rotation matrix to look at the target.
	global_transform.basis.x = lerp(global_transform.basis.x, T.basis.x, _look_velocity * delta) # Smoothly interpolate the rotation.
	global_transform.basis.y = lerp(global_transform.basis.y, T.basis.y, _look_velocity * delta)
	global_transform.basis.z = lerp(global_transform.basis.z, T.basis.z, _look_velocity * delta)
	global_rotation.z = 0 # Reset the Z rotation to zero.
	global_rotation.x = 0 # Reset the X rotation to zero.

func _on_cooldown_timeout() -> void:
	_can_be_attacked = true # Allow the enemy to be attacked again.

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body is Player:
		_something_is_on_hitbox = body
		_attack_cooldown.start() # Start the attack cooldown.

func _on_hitbox_body_exited(body: Node3D) -> void:
	if body is Player:
		_something_is_on_hitbox = null
		_attack_cooldown.stop() # Stop the attack cooldown.

func _on_attack_cooldown_timeout() -> void:
	_something_is_on_hitbox.give_damage(40) # Deal damage to the player.

func _on_agent_target_reached():
	velocity = Vector3.ZERO # Stop moving when the navigation target is reached.
