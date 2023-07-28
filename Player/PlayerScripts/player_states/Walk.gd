extends PlayerState

func physics_update(delta: float) -> void:
	if not player.is_on_floor(): #If the player is not on the ground
		state_machine.transition_to("Falling") #Transition to Falling state
		return
	
	player.set_move(player.walking_speed) #Set the player's velocity to walking_speed
	player.look_with_camera() #Make the player look in the direction they are moving
	
	if player.get_input_direction() == Vector2.ZERO: #If the player is not moving
		state_machine.transition_to("Idle") #Transition to Idle state
	if Input.is_action_pressed("run"): #If the run button is pressed
		state_machine.transition_to("Run") #Transition to Run state

func handle_input(event: InputEvent) -> void:
	if not player.is_on_floor(): return #If the player is not on the ground, return
	if event.is_action_pressed("jump"): #If the jump button is pressed
		state_machine.transition_to("Jump") #Transition to Jump state
	if event.is_action_pressed("Attack"): #If the attack button is pressed
		state_machine.transition_to("Attack") #Transition to Attack state
	if event.is_action_pressed("Block"): #If the block button is pressed
		state_machine.transition_to("Block") #Transition to Block state
