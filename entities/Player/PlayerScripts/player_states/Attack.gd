extends PlayerState

func enter(msg = {}) -> void:
	state_machine.get_animation_player().connect("animation_finished", end_animation)

func update(delta: float) -> void:
#	get_parent()._animation_player.play("Attack")
	if not player.get_hitbox().monitoring: return #if not monitoring, return this code and wait
	var enemies = player.get_hitbox().get_overlapping_bodies() #Catch the objects it is colliding with
	for enemy in enemies: #Make a loop 
		if enemy is Enemy: 
			enemy.enemy_health -= 50# make code to make enemy hit
			player.get_hitbox().monitoring = false
			player.set_enemy_health(enemy)
		else: #If not enemy
			player.get_hitbox().monitoring = false #stop monitoring
			state_machine.transition_to("Idle") #and go back to idle

func end_animation(animation_name: String) -> void:
	state_machine.transition_to("Idle") #change to idle after attack
	state_machine.get_animation_player().disconnect("animation_finished", end_animation)
