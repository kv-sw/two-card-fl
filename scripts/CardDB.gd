extends Node
class_name CardDB

const RANKS := ["2","3","4","5","6","7","8","9","T","J","Q","K","A"]
const SUITS := ["S","H","D","C"]

static func full_deck() -> Array[String]:
	var deck: Array[String] = []
	for s in SUITS:
		for r in RANKS:
			deck.append(r + s)
	return deck

static func rank_value(card_id: String) -> int:
	# "AS" -> "A"
	var r := card_id.substr(0, 1)
	return RANKS.find(r)  # 0..12

static func card_texture(card_id: String) -> Texture2D:
	return load("res://assets/cards/%s.png" % card_id)

static func back_texture() -> Texture2D:
	return load("res://assets/cards/back.png")
