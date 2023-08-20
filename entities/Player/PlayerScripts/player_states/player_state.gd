extends Statee
class_name PlayerState

var player: Player #reference to player

func _ready() -> void:
	await owner.ready #await to 
	
	player = owner as Player
	
	assert(player != null)
