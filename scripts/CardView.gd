extends TextureButton
class_name CardView

signal card_clicked(card_view: CardView)

@onready var discard_overlay := $DiscardOverlay
@onready var dealer_border_top: Panel = $ResultBorder/DealerBorderTop
@onready var player_border_bottom: Panel = $ResultBorder/PlayerBorderBottom
@onready var player_border_glow: Panel = $ResultBorder/PlayerBorderBottom/PlayerBorderGlow
@onready var dealer_border_glow: Panel = $ResultBorder/DealerBorderTop/DealerBorderGlow

var card_id: String = ""  # e.g. "AS"
var face_up: bool = true
var selectable: bool = false

func _set_panel_bg(panel: Panel, c: Color) -> void:
	var sb := panel.get_theme_stylebox("panel")
	var flat: StyleBoxFlat

	if sb is StyleBoxFlat:
		flat = (sb as StyleBoxFlat).duplicate(true) as StyleBoxFlat
	else:
		flat = StyleBoxFlat.new()

	flat.bg_color = c
	panel.add_theme_stylebox_override("panel", flat)
	panel.queue_redraw()

func clear_result_borders() -> void:
	player_border_bottom.visible = false
	dealer_border_top.visible = false

func set_player_border(color: Color, enabled: bool) -> void:
	player_border_bottom.visible = enabled
	if not enabled:
		return
	_set_panel_bg(player_border_bottom, color)

	var glow := color
	glow.a = min(1.0, color.a * 0.45)
	_set_panel_bg(player_border_glow, glow)

func set_dealer_border(color: Color, enabled: bool) -> void:
	dealer_border_top.visible = enabled
	if not enabled:
		return
	_set_panel_bg(dealer_border_top, color)

	var glow := color
	glow.a = min(1.0, color.a * 0.45)
	_set_panel_bg(dealer_border_glow, glow)

func _ready():
	dealer_border_top.visible = false
	player_border_bottom.visible = false

	discard_overlay.visible = false
	pressed.connect(_on_pressed)

func _on_pressed():
	if selectable:
		emit_signal("card_clicked", self)

func set_selected(selected: bool) -> void:
	discard_overlay.visible = selected
	if selected:
		discard_overlay.modulate.a = 0.0
		var t := create_tween()
		t.tween_property(discard_overlay, "modulate:a", 1.0, 0.12)
