extends Node
class_name Statee

var state_machine: StateMachine = null


func handle_input(_event: InputEvent)-> void:
	pass

func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
	

func before_enter(_msg := {}) -> void:
	set_process(true)
	set_physics_process(true)
	set_process_unhandled_input(true)
	enter(_msg)

func enter(_msg := {}) -> void:
	pass

func before_exit() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)
	exit()

func exit() -> void:
	pass

func end_animation(animation_name: String) -> void:
	pass
