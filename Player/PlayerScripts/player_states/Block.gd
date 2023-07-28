extends PlayerState

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("Block"): #If the player releases the block button
		state_machine.transition_to("Idle") #Transition to Idle state
