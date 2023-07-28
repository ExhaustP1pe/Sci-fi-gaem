extends PlayerState

func update(delta: float) -> void:
	if not player.get_hitbox().monitoring: return #if not monitoring, return this code and wait
	var enemies = player.get_hitbox().get_overlapping_bodies() #Catch the objects it is colliding with
	for enemy in enemies: #Make a loop 
		if enemy is CharacterBody3D: 
			enemy.queue_free()# make code to make enemy hit
		else: #If not enemy
			player.get_hitbox().monitoring = false #stop monitoring
			state_machine.transition_to("Idle") #and go back to idle

func end_animation(animation_name: String) -> void:
	state_machine.transition_to("Idle")
