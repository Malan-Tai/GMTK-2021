extends TextureButton
class_name AttackPattern

enum effects {DAMAGE, DAMAGE_DIR, SPAWN, NEW_ACTION, KILL}

export (int) var dmg = 2 # damage dealt if it does deal dmg
export (Array, Vector2) var pattern = [Vector2(0, -3)] # offset cells where there needs to be a player unit
export (Array, int) 	var pattern_levels = [1]
export (Array, Vector2) var affected = [Vector2(0, -1), Vector2(0, -2)] # cells affected by one of the effects
export (Array, effects) var affected_effects = [effects.DAMAGE, effects.DAMAGE] # effects affecting above cells, following index

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func rotate():
	var new_pats = []
	for v in pattern:
		new_pats.append(Vector2(-v.y, v.x))
	pattern = new_pats
		
	var new_aff = []
	for v in affected:
		new_aff.append(Vector2(-v.y, v.x))
	affected = new_aff
