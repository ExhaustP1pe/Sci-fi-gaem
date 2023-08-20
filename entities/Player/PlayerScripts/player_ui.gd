extends CanvasLayer
class_name PlayerUI

@onready var _player_health: Panel = $Control/player_health
@onready var _enemy_health: HSlider = $Control/enemy_health/VBoxContainer/enemy_health_slider
@onready var _enemy_health_panel: Panel = $Control/enemy_health
@onready var _player_health_slider: HSlider = $Control/player_health/VBoxContainer/player_health_slider

func _ready() -> void:
	_sync_player_health(get_parent().get_player_health())
	get_parent().connect("was_hit", _sync_player_health)
	_enemy_health_panel.hide()

func set_up_enemy_health(enemy: Enemy) -> void:
	if enemy.enemy_health <= 0:
		var tween = create_tween()
		tween.tween_method(_update_enemy_health_slider,_enemy_health.value,0,.3)
		await tween.finished
		_enemy_health_panel.hide()
		return
	_enemy_health_panel.show()
	var tween = create_tween()
	tween.tween_method(_update_enemy_health_slider,_enemy_health.value,enemy.enemy_health,.3)

func _update_enemy_health_slider(enemy_health: int) -> void:
	_enemy_health.value = enemy_health

func _sync_player_health(player_health: int) -> void:
	var tween = create_tween()
	tween.tween_method(_update_player_health_slider, _player_health_slider.value, player_health, .3)

func _update_player_health_slider(player_health: int) -> void:
	_player_health_slider.value = player_health
