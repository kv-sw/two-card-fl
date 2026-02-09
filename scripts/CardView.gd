extends Control
class_name CardView

signal card_clicked(card_view: CardView)

# CardView.tscn expected structure:
# CardView (Control)   <- this script
# ├─ ResultBorder (Control/Panel container)   (draws behind)
# │  ├─ DealerBorderTop (Panel)
# │  │  └─ DealerBorderGlow (Panel)
# │  └─ PlayerBorderBottom (Panel)
# │     └─ PlayerBorderGlow (Panel)
# ├─ CardButton (TextureButton)              (draws card art, handles click)
# └─ DiscardOverlay (Control)                (draws dim + X, on top)

@onready var card_button: TextureButton = $CardButton
@onready var discard_overlay := $DiscardOverlay
@onready var dealer_border_top: Panel = $ResultBorder/DealerBorderTop
@onready var player_border_bottom: Panel = $ResultBorder/PlayerBorderBottom
@onready var player_border_glow: Panel = $ResultBorder/PlayerBorderBottom/PlayerBorderGlow
@onready var dealer_border_glow: Panel = $ResultBorder/DealerBorderTop/DealerBorderGlow

var card_id: String = ""  # e.g. "AS"
var face_up: bool = true
var selectable: bool = false

# Convenience so Main.gd can keep using: view.texture_normal = ...
var texture_normal: Texture2D:
	get: return card_button.texture_normal
	set(value): card_button.texture_normal = value

func _ready() -> void:
	# Ensure children cover the CardView rect (safe even if already set in editor)
	card_button.set_anchors_preset(Control.PRESET_FULL_RECT)
	discard_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	$ResultBorder.set_anchors_preset(Control.PRESET_FULL_RECT)

	dealer_border_top.visible = false
	player_border_bottom.visible = false
	discard_overlay.visible = false

	card_button.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if selectable:
		card_clicked.emit(self)

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

func set_selected(selected: bool) -> void:
	discard_overlay.visible = selected
	if selected:
		discard_overlay.modulate.a = 0.0
		var t := create_tween()
		t.tween_property(discard_overlay, "modulate:a", 1.0, 0.12)
