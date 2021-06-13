extends TileMap
class_name Grid

signal win
signal lose
signal enemy_died

var tile_size = get_cell_size()
# The map_to_world function returns the position of the tile's top left corner in isometric space,
# we have to offset the objects on the Y axis to center them on the tiles
var tile_offset = Vector2(0, tile_size.y / 2)

var grid_size = Vector2(9, 9)

var MAX_AP = 2
var action_points = MAX_AP
var patterns = []
var found_patterns = {}
var effect_patterns = {}

var enemy_num = 0
var recieved_end_turns = 0
var enemy_playing = 0

var hazard_grid
var grid = []
onready var Player = preload("res://scenes/Ally.tscn")
onready var Obstacle = preload("res://scenes/TileElement.tscn")
onready var Wolf = preload("res://scenes/enemies/Wolf.tscn")
onready var Snake = preload("res://scenes/enemies/Snake.tscn")
onready var Slender = preload("res://scenes/enemies/Slender.tscn")
# We need to add the Player and Obstacles as children of the YSort node so when the player is below
# an obstacle on the screen Y axis, he'll be drawn above it
onready var Sorter = get_child(0)

# With the Tilemap in isometric mode, Godot takes in account the center of the tiles 
# if the tilemap is properly configured in the inspector (Cell/Tile Origin)
# so we can remove the half_tile_size variable from the top-down grid example
# Aside from that, nothing changed, the grid works exactly the same!
func _ready():
	hazard_grid = get_parent().get_child(2)
	var patterns_scene = get_parent().get_child(0)
	for c in patterns_scene.get_children():
		patterns.append(c)
		found_patterns[c] = []
		effect_patterns[c] = []
		c.connect("pressed", self, "_on_pattern_pressed", [c])
	
	for x in range(grid_size.x):
		grid.append([])
		for _y in range(grid_size.y):
			grid[x].append(null)
			#print(get_cell(x, _y))

func init(player_coords, enemy_coords, enemy_types, obstacle_coords):
	action_points = MAX_AP
	
	var patterns_scene = get_parent().get_child(0)
	for c in patterns_scene.get_children():
		found_patterns[c] = []
		effect_patterns[c] = []

	enemy_num = 0
	recieved_end_turns = 0
	enemy_playing = 0
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			grid[x][y] = null
	get_tree().call_group("elements", "queue_free")
	
	for v in player_coords:
		create_player(v)
	
	var i = 0
	for v in enemy_coords:
		create_enemy(v, enemy_types[i])
		i += 1
	
	for v in obstacle_coords:
		create_obstacle(v)
		
	get_tree().call_group("enemies", "plan_turn")
	check_patterns()
	
func create_player(v):
	var new = Player.instance()
	new.position = map_to_world(v) + tile_offset
	Sorter.add_child(new)
	grid[v.x][v.y] = new

func create_enemy(v, enemy_type):
	var new
	if enemy_type == Level.enemies.WOLF:
		new = Wolf.instance()
	elif enemy_type == Level.enemies.SNAKE:
		new = Snake.instance()
	elif enemy_type == Level.enemies.SLENDER:
		new = Slender.instance()
	new.position = map_to_world(v) + tile_offset
	Sorter.add_child(new)
	grid[v.x][v.y] = new
	enemy_num += 1
	new.connect("end_turn", self, "_on_endturn_recieve")

func create_obstacle(v):
	var new = Obstacle.instance()
	new.position = map_to_world(v) + tile_offset
	Sorter.add_child(new)
	grid[v.x][v.y] = new


func _input(event):
	if action_points > 0:
		var direction = Vector2()
		if event.is_action_pressed("move_up"):
			direction.y = -1
		elif event.is_action_pressed("move_down"):
			direction.y = 1
		elif event.is_action_pressed("move_left"):
			direction.x = -1
		elif event.is_action_pressed("move_right"):
			direction.x = 1

		if direction != Vector2():
			for x in range(grid_size.x):
				for y in range(grid_size.y):
					var real_x = x
					var real_y = y
					
					if direction.x > 0:
						real_x = grid_size.x - x - 1
					elif direction.y > 0:
						real_y = grid_size.y - y - 1
					
					var ins:TileElement = grid[real_x][real_y]
					if (ins != null):
						ins.try_move(direction, true)

			action_points -= 1
			if action_points <= 0:
				$EndTurnTimer.start()
				for pat in patterns:
					pat.disabled = true
					found_patterns[pat] = []
					effect_patterns[pat] = []
			else:
				check_patterns()
		

func check_patterns():
	for pat in patterns:
		pat.disabled = true
		found_patterns[pat] = []
		effect_patterns[pat] = []

	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var ins:TileElement = grid[x][y]
			if ins == null or not ins.type in Constants.player_types:
				continue
			for pat in patterns:
				for _i in range(4):
					var do = true
					var k = 0
					for v in pat.pattern:
						var ins2:TileElement = get_cell_content(Vector2(x + v.x, y + v.y))
						if ins2 == null or not ins2.type in Constants.player_types or (pat.pattern_levels[k] == 3 and ins2.type != Constants.element_types.PLAYER_3) or (pat.pattern_levels[k] == 2 and not ins2.type in [Constants.element_types.PLAYER_2, Constants.element_types.PLAYER_3]):
							do = false
							break
						k += 1
					if do:
						var affected = []
						var effects = []
						var i = 0
						for v in pat.affected:
							if pat.affected_effects[i] != pat.effects.DAMAGE_DIR:
								affected.append(Vector2(x + v.x, y + v.y))
								effects.append(pat.affected_effects[i])
							else:
								for j in range(8):
									affected.append(Vector2(x, y) + j * v)
									effects.append(pat.effects.DAMAGE)
							i += 1
						if not pattern_already_found(pat, affected):
							found_patterns[pat].append(affected)
							effect_patterns[pat].append(effects)
						pat.disabled = false
					pat.rotate()


func pattern_already_found(pattern, affected):
	for array in found_patterns[pattern]:
		var n = 0
		for v in affected:
			if v in array:
				n += 1
		if n == affected.size():
			return true
	return false


func _on_pattern_pressed(pattern):
	pattern.disabled = true
	var i = 0
	for array in found_patterns[pattern]:
		var j = 0
		for cell in array:
			var effect = effect_patterns[pattern][i][j]
			if effect == pattern.effects.DAMAGE:
				cell_take_damage(cell, pattern.dmg, false)
			elif effect == pattern.effects.SPAWN:
				create_player(cell)
			elif effect == pattern.effects.KILL:
				var ins = get_cell_content(cell)
				if ins != null:
					ins.queue_free()
			elif effect == pattern.effects.NEW_ACTION:
				action_points += 1
			j += 1
		i += 1
	found_patterns[pattern] = []
	effect_patterns[pattern] = []


func get_cell_content(pos=Vector2()):
	if pos.x < 0 or pos.x >= grid_size.x or pos.y < 0 or pos.y >= grid_size.y:
		return null
	return grid[pos.x][pos.y]


func is_cell_vacant(pos=Vector2(), direction=Vector2(), type=Constants.element_types.NONE):
	var grid_pos = world_to_map(pos) + direction

	if grid_pos.x < grid_size.x and grid_pos.x >= 0:
		if grid_pos.y < grid_size.y and grid_pos.y >= 0:
			var ins:TileElement = grid[grid_pos.x][grid_pos.y]
			return ins == null or (ins.pushable and is_cell_vacant(ins.position, direction.normalized())) or Constants.can_fusion(type, ins.type)
	return false

# Nothing new in this function either, the TileMap class takes care of the cartesian to iso conversion
func update_child_pos(pos, direction, instance):
	var grid_pos = world_to_map(pos)
	var new_grid_pos = grid_pos + direction
	
	grid[grid_pos.x][grid_pos.y] = null
	var old:TileElement = grid[new_grid_pos.x][new_grid_pos.y]
	if old != null and Constants.can_fusion(instance.type, old.type):
		instance.update_type(Constants.do_fusion(instance.type, old.type))
		old.queue_free()
		print("fusion")
	elif old != null and old.pushable:
		old.try_move(direction.normalized(), false)
	grid[new_grid_pos.x][new_grid_pos.y] = instance

	var target_pos = map_to_world(new_grid_pos) + tile_offset

	# Print statements help to understand what's happening. We're using GDscript's string format operator % to convert
	# Vector2s to strings and integrate them to a sentence. The syntax is "... %s" % value / "... %s ... %s" % [value_1, value_2]
	# print("Pos %s, dir %s" % [pos, direction])
	# print("Grid pos, old: %s, new: %s" % [grid_pos, new_grid_pos])
	# print(target_pos)
	return target_pos


func _on_endturn_recieve():
	recieved_end_turns += 1
	enemy_playing += 1
	if recieved_end_turns >= enemy_num:
		get_tree().call_group("enemies", "plan_turn")
		action_points = MAX_AP
		recieved_end_turns = 0
		check_patterns()
		if get_tree().get_nodes_in_group("player_units").size() <= 0:
			emit_signal("lose")
		if (enemy_num <= 0):
			print("win")
			emit_signal("win")
	else:
		get_tree().get_nodes_in_group("enemies")[enemy_playing].do_turn()


func closest_player(pos=Vector2()) -> Vector2:
	var grid_pos = world_to_map(pos)
	var min_dist = 200
	var chosen:Vector2 = Vector2(-1, -1)
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var ins:TileElement = grid[x][y]
			if ins != null and ins.type in Constants.player_types:
				var dist = grid_pos.distance_squared_to(Vector2(x, y))
				if dist <= min_dist:
					min_dist = dist
					chosen = Vector2(x, y)
	return chosen

func take_damage(pos=Vector2(), dir=Vector2(), dmg=1):
	var grid_pos = world_to_map(pos) + dir
	cell_take_damage(grid_pos, dmg)

func cell_take_damage(grid_pos=Vector2(), dmg=1, hurt_ally=true):
	var ins:TileElement = get_cell_content(grid_pos)
	if ins != null and ins.type != Constants.element_types.OBSTACLE and (hurt_ally or ins.type == Constants.element_types.ENEMY):
		if ins.take_damage(dmg):
			if ins.type == Constants.element_types.ENEMY:
				enemy_num -= 1
				enemy_playing -= 1
				emit_signal("enemy_died")
			ins.queue_free()
			grid[grid_pos.x][grid_pos.y] = null


func end_turn(force=false):
	if not force and action_points > 0:
		return

	get_tree().call_group("previews", "queue_free")
	for pat in patterns:
		pat.disabled = true
		found_patterns[pat] = []
		effect_patterns[pat] = []
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var instance = get_cell_content(Vector2(x, y))
			if instance == null:
				continue
			var hazard = hazard_grid.get_cell(x, y)
			if hazard == 11 and (instance.type == Constants.element_types.ENEMY or instance.type in Constants.player_types):
				if instance.take_damage(1):
					if instance.type == Constants.element_types.ENEMY:
						enemy_num -= 1
						enemy_playing -= 1
						emit_signal("enemy_died")
					instance.queue_free()
					grid[x][y] = null
			elif hazard == 12 and instance.type == Constants.element_types.ENEMY:
				if instance.take_damage(1):
					enemy_num -= 1
					enemy_playing -= 1
					emit_signal("enemy_died")
					instance.queue_free()
					grid[x][y] = null
			elif hazard == 13 and instance.type in Constants.player_types:
				if instance.take_damage(1):
					instance.queue_free()
					grid[x][y] = null

	if enemy_num > 0:
		enemy_playing = 0
		get_tree().get_nodes_in_group("enemies")[0].do_turn()
	else:
		action_points = MAX_AP
		emit_signal("win")

func _on_EndTurnTimer_timeout():
	end_turn()
