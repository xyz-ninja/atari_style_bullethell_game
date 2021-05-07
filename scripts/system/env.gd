extends Node

var game

func get_item_info_params_by_type(_type):
	var type = _type

	var info_params = {
		name = "unknown",
		desc = "no desc",
		icon_x_offset = 0,
		icon_y_offset = 0,
	}

	if type == game.ITEMS.CHAMBER_OF_REFLECTION:
		info_params.name = "Chamber of Reflection"
		info_params.desc = "Invulnerability lasts longer"
		info_params.icon_x_offset = 0

	elif type == game.ITEMS.TRACHOMA_EYE:
		info_params.name = "Trachoma Eye"
		info_params.desc = "Enemies can be seen further and they appear later"
		info_params.icon_x_offset = 1
	elif type == game.ITEMS.MAGNETIC_SKULL:
		info_params.name = "Magnetic Skull"
		info_params.desc = "Greater skull collection radius"
		info_params.icon_x_offset = 2
	elif type == game.ITEMS.UGLY_SKULL:
		info_params.name = "Ugly Skull"
		info_params.desc = "More skulls"
		info_params.icon_x_offset = 3
	elif type == game.ITEMS.BLOODY_CALLUS:
		info_params.name = "Bloody Callus"
		info_params.desc = "Enemies are pushed further"
		info_params.icon_x_offset = 4
	elif type == game.ITEMS.LASH_OF_REPOSE:
		info_params.name = "Lash of Repose"
		info_params.desc = "Faith builds up more slowly"
		info_params.icon_x_offset = 5
	elif type == game.ITEMS.ASH_MAW:
		info_params.name = "Ash Maw"
		info_params.desc = "+1 item to choose from. Others don't burn anymore"
		info_params.icon_x_offset = 6

	# КАРТЫ
	elif type == game.ITEMS.CARD_OF_SPADES_1:
		info_params.name = "Torn Card"
		info_params.desc = "Level 1 is now stronger"
		info_params.icon_x_offset = 0
		info_params.icon_y_offset = 1
	elif type == game.ITEMS.CARD_OF_SPADES_2:
		info_params.name = "2 of Spades"
		info_params.desc = "Level 2 is now stronger"
		info_params.icon_x_offset = 1
		info_params.icon_y_offset = 1
	elif type == game.ITEMS.CARD_OF_SPADES_3:
		info_params.name = "3 of Spades"
		info_params.desc = "Level 3 is now stronger"
		info_params.icon_x_offset = 2
		info_params.icon_y_offset = 1
	elif type == game.ITEMS.CARD_OF_SPADES_4:
		info_params.name = "4 of Spades"
		info_params.desc = "Level 4 is now stronger"
		info_params.icon_x_offset = 3
		info_params.icon_y_offset = 1
	elif type == game.ITEMS.CARD_OF_SPADES_5:
		info_params.name = "5 of Spades"
		info_params.desc = "Level 5 is now stronger"
		info_params.icon_x_offset = 4
		info_params.icon_y_offset = 1
	elif type == game.ITEMS.CARD_OF_SPADES_6:
		info_params.name = "6 of Spades"
		info_params.desc = "Level 6 is now stronger"
		info_params.icon_x_offset = 5
		info_params.icon_y_offset = 1
	elif type == game.ITEMS.CARD_OF_SPADES_7:
		info_params.name = "7 of Spades"
		info_params.desc = "Level 7 is now stronger"
		info_params.icon_x_offset = 6
		info_params.icon_y_offset = 1
	elif type == game.ITEMS.CARD_OF_SPADES_8:
		info_params.name = "8 of Spades"
		info_params.desc = "Level 8 is now stronger"
		info_params.icon_x_offset = 7
		info_params.icon_y_offset = 1
	elif type == game.ITEMS.CARD_OF_SPADES_9:
		info_params.name = "9 of Spades"
		info_params.desc = "Level 9 is now stronger"
		info_params.icon_x_offset = 8
		info_params.icon_y_offset = 1
	elif type == game.ITEMS.CARD_OF_SPADES_10:
		info_params.name = "10 of Spades"
		info_params.desc = "Level 10 is now stronger"
		info_params.icon_x_offset = 9
		info_params.icon_y_offset = 1

	# ATTACK
	elif type == game.ITEMS.DEVIL_DAGGER:
		info_params.name = "Devil Dagger"
		info_params.desc = "Knives are stronger now"
		info_params.icon_x_offset = 0
		info_params.icon_y_offset = 2

	elif type == game.ITEMS.LEFT_TENTACLE:
		info_params.name = "Left Tentacle"
		info_params.desc = "Additional throws from the left"
		info_params.icon_x_offset = 1
		info_params.icon_y_offset = 2

	elif type == game.ITEMS.RIGHT_TENTACLE:
		info_params.name = "Right Tentacle"
		info_params.desc = "Additional throws from the right"
		info_params.icon_x_offset = 2
		info_params.icon_y_offset = 2

	elif type == game.ITEMS.MUTATED_WORM:
		info_params.name = "Mutated Worm"
		info_params.desc = "Extra throws down"
		info_params.icon_x_offset = 3
		info_params.icon_y_offset = 2

	elif type == game.ITEMS.CACTUS_RASH:
		info_params.name = "Cactus Quid Rash"
		info_params.desc = "Enemies take damage on touch"
		info_params.icon_x_offset = 4
		info_params.icon_y_offset = 2

	return info_params

func get_level_info_by_num(_num):
	var num = _num
	
	var info_params = {header = "unknown level"}

	if num == 1:
		info_params.header = "\nDESECRATED CEMETERY"
	elif num == 2:
		info_params.header = "\nLAVENDER FIELDS"
	elif num == 3:
		info_params.header = "\nCURSED TUNNELS"
	elif num == 4:
		info_params.header = "\nFETID CATHEDRAL"
	elif num == 5:
		info_params.header = "\nFORGOTTEN PATH"

	return info_params

func set_game(_game):
	game = _game