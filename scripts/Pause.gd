extends Node2D

signal resumed
onready var HowTo = preload("res://scenes/HowToPlay.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_HowTo_pressed():
	var ins = HowTo.instance()
	add_child(ins)


func _on_Resume_pressed():
	emit_signal("resumed")
	queue_free()


func _on_Title_pressed():
	get_tree().change_scene("res://scenes/Levels/MainMenu.tscn")
