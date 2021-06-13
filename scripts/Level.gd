extends Node2D
class_name Level

enum enemies {WOLF, SNAKE, SLENDER}

export (Array, Vector2) var player_coords = [Vector2(), Vector2(4, 4)]
export (Array, Vector2) var enemy_coords = [Vector2(8, 8), Vector2(7, 8)]
export (Array, enemies) var enemy_types = [enemies.WOLF, enemies.SNAKE]
export (Array, Vector2) var obstacle_coords = [Vector2(3, 4)]

export (String) var next_level = "none"

onready var Pause = preload("res://scenes/Pause.tscn")
var paused = false

var preview_visible = true
var mute = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Grid.init(player_coords, enemy_coords, enemy_types, obstacle_coords)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if not paused:
			paused = true
			var ins = Pause.instance()
			ins.connect("resumed", self, "unpause")
			add_child_below_node(get_children()[get_child_count() - 1], ins)
		else:
			paused = false
			get_child(get_child_count() - 1).queue_free()

func unpause():
	paused = false

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
		if next_level == "win":
			get_tree().change_scene("res://scenes/Victory.tscn")
		else:
			get_tree().change_scene(next_level)


func _on_Grid_enemy_died():
	$Sounds.stream = load("res://assets/sound/mort méchant .wav")
	$Sounds.stream.set_loop_mode(0)
	$Sounds.play()
	$Witch.play("angry")


func _on_Witch_animation_finished():
	$Witch.play("idle")


func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.play()


func _on_Mute_pressed():
	mute = not mute
	$AudioStreamPlayer.stream_paused = mute


func _on_Grid_play_sound(sound):
	print(sound)
	$Sounds.stream = load(sound)
	$Sounds.stream.set_loop_mode(0)
	$Sounds.play()



