extends Node2D

#export (String) var next_level = "none"

onready var Credits = preload("res://scenes/Credits.tscn")
onready var HowTo = preload("res://scenes/HowToPlay.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Play_pressed():
	#if next_level != "none":
		#get_tree().change_scene(next_level)
	get_tree().change_scene("res://scenes/Levels/Level1/Level.tscn")
	$AudioStreamPlayer.play()


func _on_Quit_pressed():
	get_tree().quit()


func _on_Credits_pressed():
	var ins = Credits.instance()
	add_child(ins)
	$AudioStreamPlayer.play()


func _on_HowTo_pressed():
	var ins = HowTo.instance()
	add_child(ins)
	$AudioStreamPlayer.play()
