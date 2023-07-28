extends Node
class_name StateMachine

signal transitioned(state_name)

@export var initial_state: NodePath #Initial State
@export var _animation_player: AnimationPlayer 

@onready var state: Statee = get_node(initial_state)

func _ready() -> void:
	await owner.ready #Wait for the parent of this node to be ready
	for child in get_children(): #Loop through the children, which are the states
		child.state_machine = self #Assign the variable state_machine to this script
		child.before_exit() #Call the exit function of the states to disable their processing until the time is right
	state.enter() #After the loop, get the initial state and enter it

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event) #Manage the handle_input of the state
	
func _process(delta: float) -> void:
	state.update(delta) #Manage the update of the state
	
func _physics_process(delta: float) -> void:
	state.physics_update(delta) #Manage the physics_update of the state

func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	if not has_node(target_state_name): #If there is no state with the name
		printerr("Doesn't exit this state: ", target_state_name) #Print an error
		return #Return
	if _animation_player.is_connected("animation_finished", state.end_animation): #If the animation_player is already connected to the state
		_animation_player.disconnect("animation_finished", state.end_animation) #Disconnect it
	state.before_exit() #Exit the state
	state = get_node(target_state_name) #Get the next state 
	state.before_enter(msg) #Enter it
	if _animation_player.current_animation != target_state_name:
		_animation_player.play(target_state_name) #Play the animation
		if state.has_method("end_animation"): #If the state has the method "end_animation"
			_animation_player.connect("animation_finished", state.end_animation) #Connect the animation_player to it
	emit_signal("transitioned", state.name) #Emit a signal
