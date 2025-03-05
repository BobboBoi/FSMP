extends Control
class_name RightClickMenu

@onready var cont := %Cont
var currentSelection = null

func _ready() -> void:
	Close()
	
	for i in cont.get_children():
		if i is Button:
			i.pressed.connect(Close)

func _input(event: InputEvent) -> void:
	if !visible: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var local = make_input_local(event)
		if Rect2(Vector2(0,0),size).has_point(local.position): return
		Close()
	
	elif event.is_action_pressed("ui_cancel"):
		Close()

func Open(src : Control) -> void:
	if currentSelection == src:
		Close()
		return
	currentSelection = src
	
	OpenButtons(src)
	
	var c := false
	for i in cont.get_children():
		if i.visible:
			c = true
			break
	if !c: 
		currentSelection = null
		return
	
	show()
	global_position = get_global_mouse_position() + Vector2(20,0)

func Close() -> void:
	currentSelection = null
	for i in cont.get_children(): i.hide()
	hide()

func OpenButtons(src : Node) -> void:
	for i in cont.get_children():
		if i is RightClickItem: i.Show(src)
		if i.has_method("Show"): i.Show(src)
		else: i.show()

func _on_focus_exited() -> void:
	Close()
