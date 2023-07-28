extends PlayerState

func enter(_msg := {}) -> void:
	player.velocity = Vector3.ZERO #Set the player's velocity to zero

func update(delta: float) -> void:
	if not player.is_on_floor(): #If the player is not on the ground
		state_machine.transition_to("Falling") #Change the state to Falling
		return #Return
	if Input.is_action_just_pressed("jump"): #If the player pressed the jump button
		state_machine.transition_to("Jump") #Change the state to Jump
	if player.get_input_direction() != Vector2.ZERO: #If the player is moving
		state_machine.transition_to("Walk") #Change the state to Walk

func handle_input(event: InputEvent) -> void:
	if not player.is_on_floor(): return #If not is_on_floor, return
	if event.is_action_pressed("Attack"): #If the player pressed the attack button
		state_machine.transition_to("Attack") #Change the state to Attack
	if event.is_action_pressed("Block"): #If the player pressed the block button
		state_machine.transition_to("Block") #Change the state to Block
