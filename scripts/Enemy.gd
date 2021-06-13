extends PushTileElement
class_name Enemy

export (PackedScene) var move_arrow
export (PackedScene) var hit_arrow
export (String) var walk_anim
export (String) var idle_anim

enum all_behaviours {BASE, WOLF, SNAKE, SLENDER}
enum all_actions {MOVE, HIT}

var actions = []
var actions_dir = []
export (all_behaviours) var behaviour = all_behaviours.WOLF

signal end_turn

# Called when the node enters the scene tree for the first time.
func _ready():
	type = Constants.element_types.ENEMY

func do_turn() -> void:
	var i = 0
	for a in actions:
		if a == all_actions.HIT:
			grid.take_damage(position, actions_dir[i], 1)
		elif a == all_actions.MOVE:
			if try_move(actions_dir[i], false):
				yield(self, "end_movement")
			else:
				print("blocked")
		i += 1
		$Timer.start()
		yield($Timer, "timeout")
	emit_signal("end_turn")

func plan_turn():
	actions = []
	actions_dir = []
	
	if behaviour == all_behaviours.BASE:
		base_plan_turn()
	elif behaviour == all_behaviours.WOLF:
		wolf_plan_turn()
	elif behaviour == all_behaviours.SNAKE:
		snake_plan_turn()
	elif behaviour == all_behaviours.SLENDER:
		slender_plan_turn()
	
	var i = 0
	var offset = Vector2()
	var arrow
	for a in actions:
		if a == all_actions.MOVE:
			offset += actions_dir[i]
			arrow = move_arrow.instance()
			arrow.position = grid.map_to_world(offset)
		elif a == all_actions.HIT:
			arrow = hit_arrow.instance()
			arrow.position = grid.map_to_world(offset + actions_dir[i])
		
		add_child(arrow)
		if actions_dir[i].x < 0 or actions_dir[i].y > 0:
			arrow.flip_h = true
		if actions_dir[i].y > 0 or actions_dir[i]. x > 0:
			arrow.flip_v = true
		i += 1


func base_plan_turn():
	var closest:Vector2 = grid.closest_player(position)
	var grid_pos:Vector2 = grid.world_to_map(position)
	
	for i in range(2):
		var dist = closest.distance_squared_to(grid_pos)
		if (dist < 2):
			actions.append(all_actions.HIT)
			actions_dir.append(grid_pos.direction_to(closest))
		else:
			actions.append(all_actions.MOVE)
			var float_dir = grid_pos.direction_to(closest)
			if abs(float_dir.x) > abs(float_dir.y):
				actions_dir.append(Vector2(sign(float_dir.x), 0))
			else:
				actions_dir.append(Vector2(0, sign(float_dir.y)))
			grid_pos += actions_dir[i]


func wolf_plan_turn():
	var closest:Vector2 = grid.closest_player(position)
	var grid_pos:Vector2 = grid.world_to_map(position)
	var dist = closest.distance_squared_to(grid_pos)
	var float_dir = grid_pos.direction_to(closest)
	var int_dir
	if abs(float_dir.x) > abs(float_dir.y):
		int_dir = Vector2(sign(float_dir.x), 0)
	else:
		int_dir = Vector2(0, sign(float_dir.y))
	
	for _i in range(2):
		if dist <= 19:
			actions.append(all_actions.HIT)
			actions_dir.append(int_dir)
		actions.append(all_actions.MOVE)
		actions_dir.append(int_dir)


func snake_plan_turn():
	var closest:Vector2 = grid.closest_player(position)
	var grid_pos:Vector2 = grid.world_to_map(position)
	var dist = closest.distance_squared_to(grid_pos)
	var float_dir = grid_pos.direction_to(closest)
	var int_dir
	var side_dir
	if abs(float_dir.x) > abs(float_dir.y):
		int_dir = Vector2(sign(float_dir.x), 0)
		side_dir = Vector2(0, 1)
	else:
		int_dir = Vector2(0, sign(float_dir.y))
		side_dir = Vector2(1, 0)
	
	actions.append(all_actions.MOVE)
	actions_dir.append(int_dir)
	
	if dist <= 5:
		for _i in range(2):
			actions.append(all_actions.HIT)
		actions_dir.append(int_dir + side_dir)
		actions_dir.append(int_dir - side_dir)


func slender_plan_turn():
	var closest:Vector2 = grid.closest_player(position)
	var grid_pos:Vector2 = grid.world_to_map(position)
	var dist = closest.distance_squared_to(grid_pos)
	var float_dir = grid_pos.direction_to(closest)
	var int_dir
	var side_dir
	if abs(float_dir.x) > abs(float_dir.y):
		int_dir = Vector2(sign(float_dir.x), 0)
		side_dir = Vector2(0, 1)
	else:
		int_dir = Vector2(0, sign(float_dir.y))
		side_dir = Vector2(1, 0)
	
	actions.append(all_actions.MOVE)
	actions_dir.append(int_dir * 2)
	
	if dist <= 9:
		for _i in range(4):
			actions.append(all_actions.HIT)
		actions_dir.append(int_dir)
		actions_dir.append(- int_dir)
		actions_dir.append(side_dir)
		actions_dir.append(- side_dir)


func try_move(direction = Vector2(), fromInput = true) -> bool:
	if not fromInput and not is_moving and direction != Vector2():
		target_direction = direction #.normalized()
		if grid.is_cell_vacant(position, direction, type):
			target_pos = grid.update_child_pos(position, direction, self)
			is_moving = true
			$AnimatedSprite.play(walk_anim)
			return true
	return false


func _on_AnimatedSprite_animation_finished():
	if is_moving:
		$AnimatedSprite.play(walk_anim)
	else:
		$AnimatedSprite.play(idle_anim)
