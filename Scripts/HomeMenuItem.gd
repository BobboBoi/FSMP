extends Control
class_name HomeMenuItem
##Parent class for selectable items in the home menu.
##
##Used by [MusicSelection] and [AlbumSelection]

var selected := false
var hovered := false
var variation := 1 :
	set(value):
		variation = clamp(value,1,2)

signal Selected
signal Unselected

func _ready() -> void:
	mouse_entered.connect(OnHover)
	mouse_exited.connect(OnUnhover)

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
