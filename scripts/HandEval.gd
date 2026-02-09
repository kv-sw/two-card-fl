extends Node
class_name HandEval

# Output:
# {
#   "type": "pair"/"high",
#   "primary": int,   # pair rank OR high card rank
#   "secondary": int, # kicker for high-card; -1 for pair
#   "cards": Array
# }
static func best_two(cards: Array[String]) -> Dictionary:
	if cards.size() == 2:
		return _score_two(cards[0], cards[1])

	var best : Dictionary = {}
	var combos := [
		[cards[0], cards[1]],
		[cards[0], cards[2]],
		[cards[1], cards[2]],
	]
	for c in combos:
		var s := _score_two(c[0], c[1])
		if best.is_empty() or _beats(s, best):
			best = s
	return best

static func _score_two(a: String, b: String) -> Dictionary:
	var ra := CardDB.rank_value(a)
	var rb := CardDB.rank_value(b)

	if ra == rb:
		return {
			"type": "pair",
			"primary": ra,
			"secondary": -1,
			"cards": [a, b]
		}

	var hi : int = max(ra, rb)
	var lo : int = min(ra, rb)
	return {
		"type": "high",
		"primary": hi,     # high card
		"secondary": lo,   # kicker
		"cards": [a, b]
	}

static func _beats(x: Dictionary, y: Dictionary) -> bool:
	# Pair beats high
	if x["type"] != y["type"]:
		return x["type"] == "pair"

	# Same type: compare primary then secondary
	if x["primary"] != y["primary"]:
		return x["primary"] > y["primary"]

	return x["secondary"] > y["secondary"]

static func compare(player: Dictionary, dealer: Dictionary) -> int:
	if _beats(player, dealer):
		return 1
	if _beats(dealer, player):
		return -1
	return 0
