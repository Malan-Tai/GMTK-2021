extends Object
class_name Constants

enum element_types {NONE, OBSTACLE, PUSH, ENEMY, PLAYER_1, PLAYER_2, PLAYER_3}
const player_types = [element_types.PLAYER_1, element_types.PLAYER_2, element_types.PLAYER_3]

static func can_fusion(type1, type2):
	return (type1 == element_types.PLAYER_1 or type1 == element_types.PLAYER_2)and type2 == type1
	
static func do_fusion(type1, type2):
	if type1 == type2 and type1 == element_types.PLAYER_1:
		return element_types.PLAYER_2
	if type1 == type2 and type1 == element_types.PLAYER_2:
		return element_types.PLAYER_3
