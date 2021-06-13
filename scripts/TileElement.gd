extends KinematicBody2D
class_name TileElement

signal end_movement

const MAX_SPEED = 1200

var target_pos = Vector2()
var target_direction = Vector2()
var is_moving:bool = false
var pushable:bool = false
var type
var hp = 2

var grid

func cartesian_to_isometric(vector):
	return Vector2(vector.x - vector.y, (vector.x + vector.y) / 2)

func _ready():
	# The Player is now a child of the YSort node, so we have to go 1 more step up the node tree
	grid = get_parent().get_parent()
	type = Constants.element_types.OBSTACLE

func try_move(_direction = Vector2(), _fromInput = true) -> bool:
	return false

func _physics_process(delta) -> void:
	if is_moving:
		# We have to convert the player's motion to the isometric system.
		# The target_direction is normalized a few lines above so the player moves at the same speed in all directions.
		var motion = cartesian_to_isometric(MAX_SPEED * target_direction * delta)

		var distance_to_target = position.distance_to(target_pos)
		var move_distance = motion.length()

		# In the previous example, the player could land on floating positions
		# We force him to stop exactly on the target by setting the position instead of using the move method
		# As the grid handles the "collisions", we can use the two functions interchangeably:
		# move(motion) <=> set_pos(get_pos() + motion)
		if move_distance > distance_to_target:
			set_deferred("position", target_pos)
			is_moving = false
			emit_signal("end_movement")
		else:
			set_deferred("position", position + motion)

func take_damage(dmg=1) -> bool:
	hp -= dmg
	return hp <= 0




