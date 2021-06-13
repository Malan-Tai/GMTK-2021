extends Node2D
class_name Level

enum enemies {WOLF, SNAKE, SLENDER}

export (Array, Vector2) var player_coords = [Vector2(), Vector2(4, 4)]
export (Array, Vector2) var enemy_coords = [Vector2(8, 8), Vector2(7, 8)]
export (Array, enemies) var enemy_types = [enemies.WOLF, enemies.SNAKE]
export (Array, Vector2) var obstacle_coords = [Vector2(3, 4)]

export (String) var next_level = "none"

var preview_visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$Grid.init(player_coords, enemy_coords, enemy_types, obstacle_coords)


func _on_TogglePreview_pressed():
	preview_visible = not preview_visible
	if preview_visible:
		get_tree().call_group("previews", "show")
	else:
		get_tree().call_group("previews", "hide")


func _on_Restart_pressed():
	$Grid.init(player_coords, enemy_coords, enemy_types, obstacle_coords)


func _on_Grid_lose():
	$Grid.init(player_coords, enemy_coords, enemy_types, obstacle_coords)


func _on_Grid_win():
	if next_level != "none":
		get_tree().change_scene(next_level)


func _on_Grid_enemy_died():
	$Witch.play("angry")


func _on_Witch_animation_finished():
	$Witch.play("idle")
