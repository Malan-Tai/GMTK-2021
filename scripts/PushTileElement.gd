extends TileElement
class_name PushTileElement

# Called when the node enters the scene tree for the first time.
func _ready():
	pushable = true
	type = Constants.element_types.PUSH

func try_move(direction = Vector2(), fromInput = true) -> bool:
	if not fromInput and not is_moving and direction != Vector2():
		target_direction = direction.normalized()
		if grid.is_cell_vacant(position, direction):
			target_pos = grid.update_child_pos(position, direction, self)
			is_moving = true
			return true
	return false
