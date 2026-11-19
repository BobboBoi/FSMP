extends Window
class_name RightClickMenu

@onready var cont := %Cont

var hovered : Control = null
var selection : Array[HomeMenuItem] = []

signal SelectionUpdated

func _ready() -> void:
	Close()
	
	for i in cont.get_children():
		if i is Button:
			i.pressed.connect(Close)
	
	size = size

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Close()

func _notification(what: int) -> void:
	match(what):
		NOTIFICATION_WM_CLOSE_REQUEST:
			Close()

func Open(src : Control) -> void:
	if hovered == src:
		Close()
		return
	hovered = src
	
	OpenButtons(src)
	
	var active := 0
	for i in cont.get_children():
		if i.visible:
			active += 1
	if active == 0: 
		hovered = null
		return
	
	show()
	set_process_input(visible)
	
	size.x = cont.size.x
	size.y = (cont.get_child(0).size.y + cont.get("theme_override_constants/separation")) * active
	position = DisplayServer.mouse_get_position() + Vector2i(20,0)

func Close() -> void:
	hovered = null
	for i in cont.get_children(): i.hide()
	hide()
	set_process_input(visible)

func OpenButtons(src : Node) -> void:
	for i in cont.get_children():
		
		if i is RightClickItem: 
			i.CheckVisibility(src)
		else:
			assert(!i.has_method("Show"), "REWORK: " + i.name) # TEMPORARY!

#Music selection
func Select(item : HomeMenuItem):
	var index := selection.find(item)
	if index != -1: return
	
	selection.append(item)
	SelectionUpdated.emit()

func Unselect(item : HomeMenuItem):
	var index := selection.find(item)
	if index == -1: return
	
	selection.remove_at(index)
	SelectionUpdated.emit()

func ClearSelection():
	var oldSelection := selection.duplicate()
	
	for i in oldSelection:
		i.Select(false)
