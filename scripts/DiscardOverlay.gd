extends Control
class_name DiscardOverlay

@export var dim_color: Color = Color(0, 0, 0, 0.18)

@export var x_color: Color = Color(0.7, 0.3, 0.3, 0.6)
@export var border_color: Color = Color(0.7, 0.3, 0.3, 0.6)# Color(0.90, 0.15, 0.15, 0.75)

@export var line_width: float = 2.0
@export var border_width: float = 4.0
@export var inset: float = 12.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	# 1) Dim the whole card
	draw_rect(Rect2(Vector2.ZERO, size), dim_color, true)

	# 2) Red border around the card
	draw_rect(Rect2(Vector2.ZERO, size), border_color, false, border_width)

	# 3) Draw the X
	var p1 := Vector2(inset, inset)
	var p2 := Vector2(size.x - inset, size.y - inset)
	var p3 := Vector2(size.x - inset, inset)
	var p4 := Vector2(inset, size.y - inset)

	draw_line(p1, p2, x_color, line_width, true)
	draw_line(p3, p4, x_color, line_width, true)
