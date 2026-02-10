extends Control

@onready var dealer1: CardView = $"RootHBox/Table/DealerArea/DealerCenter/DealerRow/DealerCard1"
@onready var dealer2: CardView = $"RootHBox/Table/DealerArea/DealerCenter/DealerRow/DealerCard2"
@onready var community: CardView = $"RootHBox/Table/CommunityArea/CommunityRow/CommunityCard"
@onready var player1: CardView = $"RootHBox/Table/PlayerArea/PlayerCenter/PlayerRow/PlayerCard1"
@onready var player2: CardView = $"RootHBox/Table/PlayerArea/PlayerCenter/PlayerRow/PlayerCard2"

@onready var confirm_button: Button = $"RootHBox/Table/ConfirmCenter/ConfirmButton"
@onready var result_label: Label = $"ResultPanel/ResultLabel"

enum ActionMode { CONFIRM, NEW_ROUND }
var action_mode: ActionMode = ActionMode.CONFIRM

var deck: Array[String] = []
var dealer_cards: Array[String] = []
var player_cards: Array[String] = []
var community_card: String = ""

var selected_discard: CardView = null
var round_active: bool = false
var decision_locked: bool = false

func _ready():
	# connect click signals for player cards
	player1.card_clicked.connect(_on_player_card_clicked)
	player2.card_clicked.connect(_on_player_card_clicked)

	confirm_button.pressed.connect(_on_action_button_pressed)

	# Start immediately
	_on_deal()

func _on_action_button_pressed() -> void:
	if action_mode == ActionMode.CONFIRM:
		_on_confirm()
	else:
		_on_deal()

func _reset_ui() -> void:
	# Default state (no active round yet)
	action_mode = ActionMode.CONFIRM
	confirm_button.text = "Confirm"
	confirm_button.disabled = true

	result_label.text = ""
	round_active = false
	decision_locked = false
	selected_discard = null

	_clear_overlays()

	_set_card_view(dealer1, "", false)
	_set_card_view(dealer2, "", false)
	_set_card_view(community, "", false)
	_set_card_view(player1, "", false)
	_set_card_view(player2, "", false)

	player1.selectable = false
	player2.selectable = false

func _clear_overlays() -> void:
	for cv in [dealer1, dealer2, community, player1, player2]:
		cv.set_selected(false)
		cv.clear_result_borders()

func _on_deal() -> void:
	_reset_ui()

	# Now start a fresh round
	round_active = true
	decision_locked = false
	selected_discard = null

	# Ensure button is back to Confirm mode for the new round
	action_mode = ActionMode.CONFIRM
	confirm_button.text = "Confirm"
	confirm_button.disabled = false

	deck = CardDB.full_deck()
	deck.shuffle()

	dealer_cards = [deck.pop_back(), deck.pop_back()]
	player_cards = [deck.pop_back(), deck.pop_back()]
	community_card = deck.pop_back()

	# Show player face up; dealer face down; community down
	_set_card_view(player1, player_cards[0], true)
	_set_card_view(player2, player_cards[1], true)
	_set_card_view(dealer1, dealer_cards[0], true)
	_set_card_view(dealer2, dealer_cards[1], false)
	_set_card_view(community, community_card, false)

	player1.selectable = true
	player2.selectable = true

	result_label.text = "Click a card and press Confirm to discard it.\n\nOr press Confirm without selecting a card to keep your hand."

func _on_player_card_clicked(cv: CardView) -> void:
	if not round_active or decision_locked:
		return

	# Toggle selection. Only one discard allowed.
	if selected_discard == cv:
		selected_discard.set_selected(false)
		selected_discard = null
	else:
		if selected_discard != null:
			selected_discard.set_selected(false)
		selected_discard = cv
		selected_discard.set_selected(true)

func _on_confirm() -> void:
	if not round_active or decision_locked:
		return

	decision_locked = true
	player1.selectable = false
	player2.selectable = false
	confirm_button.disabled = true

	# Reveal dealer + community
	_set_card_view(dealer1, dealer_cards[0], true)
	_set_card_view(dealer2, dealer_cards[1], true)
	_set_card_view(community, community_card, true)

	# Determine player's final 2-card hand
	var final_player_cards: Array[String] = player_cards.duplicate()
	if selected_discard != null:
		if selected_discard == player1:
			final_player_cards = [community_card, player_cards[1]]
		else:
			final_player_cards = [player_cards[0], community_card]

	# Dealer best from 3 cards
	var dealer_best: Dictionary = HandEval.best_two([dealer_cards[0], dealer_cards[1], community_card])
	var player_best: Dictionary = HandEval.best_two(final_player_cards)

	var cmp: int = HandEval.compare(player_best, dealer_best)
	if cmp == 1:
		result_label.text = "Player WIN!"
	elif cmp == -1:
		result_label.text = "Player LOSE."
	else:
		result_label.text = "PUSH."

	# Result borders (thin, clean)
	var player_color := Color(0.2, 0.8, 1.0, 0.95)
	var dealer_color := Color(1.0, 0.4, 0.2, 0.95)

	# Clear first
	for v in [player1, player2, community, dealer1, dealer2]:
		v.clear_result_borders()

	# Player used views (slot-based)
	var player_used_views: Array = []
	if selected_discard == null:
		player_used_views = [player1, player2]
	else:
		var kept_view: CardView = player2 if selected_discard == player1 else player1
		player_used_views = [kept_view, community]

	for v in player_used_views:
		(v as CardView).set_player_border(player_color, true)

	# Dealer used views (based on dealer_best["cards"])
	for v in [dealer1, dealer2, community]:
		if (v as CardView).card_id in dealer_best["cards"]:
			(v as CardView).set_dealer_border(dealer_color, true)

	# Switch button into New Round mode
	action_mode = ActionMode.NEW_ROUND
	confirm_button.text = "New Round"
	confirm_button.disabled = false

func _set_card_view(view: CardView, card_id: String, face_up: bool) -> void:
	view.card_id = card_id
	view.face_up = face_up

	if card_id == "":
		view.texture_normal = null
		return

	if face_up:
		view.texture_normal = CardDB.card_texture(card_id)
	else:
		view.texture_normal = CardDB.back_texture()
