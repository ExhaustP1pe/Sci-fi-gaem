extends PlayerState

func physics_update(delta: float) -> void:
	player.velocity.y -= player.gravity * delta #Make the player fall due to gravity
	
	player.set_move(player.get_actual_speed()) #Move the player with their current speed
	player.look_with_camera() #Make the player look in the direction they are walking
	
	if player.is_on_floor(): #If the player is on the ground
		if player.get_input_direction() == Vector2.ZERO: #And if the player is not moving
			state_machine.transition_to("Idle") #Transition to Idle state
		else: #Otherwise
			state_machine.transition_to("Walk") #Transition to Walk state
