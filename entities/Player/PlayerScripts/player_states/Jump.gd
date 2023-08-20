extends PlayerState

func enter(msg := {}) -> void:
	player.velocity.y = player.JUMP_VELOCITY #Make the player jump
	state_machine.get_animation_player().connect("animation_finished", end_animation)

func _physics_process(delta: float) -> void:
	player.set_move(player.get_actual_speed()) #Move the player with their current speed
	player.velocity.y -= player.gravity * delta #Make the player fall due to gravity
	player.look_with_camera() #Make the player look in the direction they are walking
	
	if player.is_on_floor(): #If the player is on the ground
		if player.get_input_direction() == Vector2.ZERO: #And if the player is not moving
			state_machine.transition_to("Idle") #Transition to Idle state
		else: #Otherwise
			state_machine.transition_to("Walk") #Transition to Walk state

func end_animation(animation_name: String) -> void: #When the animation ends and the player is still in the air
	state_machine.transition_to("Falling") #Transition to Falling state
	state_machine.get_animation_player().disconnect("animation_finished", end_animation)
