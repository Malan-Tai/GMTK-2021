extends PushTileElement
class_name Ally

func cartesian_to_isometric(vector):
	return Vector2(vector.x - vector.y, (vector.x + vector.y) / 2)

func _ready():
	# The Player is now a child of the YSort node, so we have to go 1 more step up the node tree
	type = Constants.element_types.PLAYER_1

func try_move(direction = Vector2(), _fromInput = true) -> bool:
	if not is_moving and direction != Vector2():
		target_direction = direction.normalized()
		if grid.is_cell_vacant(position, direction, type):
			target_pos = grid.update_child_pos(position, direction, self)
			is_moving = true
			return true
	return false


func update_type(new_type):
	type = new_type
	if (type == Constants.element_types.PLAYER_1):
		$AnimatedSprite.play("idle_1")
	elif (type == Constants.element_types.PLAYER_2):
		$AnimatedSprite.play("idle_2")
	elif (type == Constants.element_types.PLAYER_3):
		$AnimatedSprite.play("idle_3")

func take_damage(_dmg=1) -> bool:
	if type == Constants.element_types.PLAYER_1:
		return true
	if type == Constants.element_types.PLAYER_2:
		update_type(Constants.element_types.PLAYER_1)
	elif type == Constants.element_types.PLAYER_3:
		update_type(Constants.element_types.PLAYER_2)
	return false

