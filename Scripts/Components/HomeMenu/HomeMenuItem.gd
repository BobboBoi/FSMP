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
			print("Holding: ",value)
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
	gui_input.connect(GuiInput)
	mouse_entered.connect(OnHover)
	mouse_exited.connect(OnUnhover)
	set_process(false)

func _process(_delta: float) -> void:
	if !held: 
		set_process(false)
		return
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		held = false
		set_process(false)

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

func OnHover():
	hovered = true
	RefreshTheme()

func OnUnhover():
	hovered = false
	RefreshTheme()

func GuiInput(event: InputEvent) -> void:
	if event is not InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	if !hovered: return
	
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

func CheckHold():
	if cancelHold: return
	held = true

func Clicked() -> void:
	Pressed.emit()
