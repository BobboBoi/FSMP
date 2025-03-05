extends Control
class_name HomeMenuItem
##Parent class for selectable items in the home menu.
##
##Used by [MusicSelection], [AlbumSelection] and currently [QueueSelection](Might change in the future!).

var selected := false
var hovered := false
var cancelHold := true
var held := false :
	set(value):
		if value != held:
			set_process(value)
			if value: Held.emit()
			else: Dropped.emit()
		held = value
var variation := 1 :
	set(value):
		variation = clamp(value,1,2)

signal Pressed
signal Selected
signal Unselected
signal Held
signal Dropped

func _init() -> void:
	mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND

func _ready() -> void:
	mouse_entered.connect(_OnMouseHover)
	focus_entered.connect(_OnHover)
	mouse_exited.connect(_OnMouseUnhover)
	focus_exited.connect(_OnUnhover)
	set_process(false)

func _process(_delta: float) -> void:
	if !held: 
		set_process(false)
		return
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		held = false
		set_process(false)

func _gui_input(event: InputEvent) -> void:
	if !hovered: return
	
	if event.is_action("LeftClick"):
		if get_parent() is CustomizableList:
			if event.is_pressed():
				cancelHold = false
				get_tree().create_timer(0.15).timeout.connect(CheckHold)
			elif event.is_released():
				cancelHold = true
				if held:
					held = false
				else:
					Clicked()
		elif event.is_released():
			Clicked()
	
	elif event.is_action_pressed("ui_accept"):
		Clicked()
	
	elif event.is_action_pressed("RightClick"):
		var rcm := get_tree().get_first_node_in_group("RightClickMenu")
		if rcm == null: return
		rcm.Open(self)

func Select(value : bool) -> void:
	if selected == value: return
	
	if value: Selected.emit()
	else: Unselected.emit()
	
	selected = value

func SetVariation(id := 1) -> void:
	variation = id
	RefreshTheme()

func RefreshTheme() -> void:
	var newTheme = "ListItem"+str(variation)
	if hovered: 
		newTheme += "Hovered"
		z_index = 1
	else: z_index = 0
	theme_type_variation = newTheme

func _OnHover():
	hovered = true
	RefreshTheme()

func _OnUnhover():
	hovered = false
	RefreshTheme()

func _OnMouseHover():
	hovered = true
	RefreshTheme()

func _OnMouseUnhover():
	hovered = false
	RefreshTheme()

func CheckHold():
	if cancelHold: return
	held = true

func Clicked() -> void:
	Pressed.emit()
