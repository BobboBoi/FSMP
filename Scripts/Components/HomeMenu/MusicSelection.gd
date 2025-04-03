extends HomeMenuItem
class_name MusicSelection

@onready var content = preload("uid://dnabikjgn0f5x")

@export var data : MusicData :
	set(value):
		data = value
		if is_inside_tree() and get_child_count() > 1: 
			get_child(1).Refresh(self)
@export var index : int : 
	set(value):
		index = value
		if is_inside_tree() and get_child_count() > 1: 
			get_child(1).Refresh(self)

static func Create(newData : MusicData,newIndex := 0) -> MusicSelection:
	var inst = preload("res://Scenes/Components/HomeMenu/MusicSelection.tscn").instantiate()
	inst.data = newData
	inst.index = newIndex
	inst.name = inst.data.name
	return inst

func Setup(newData : MusicData,newIndex := 0) -> void:
	data = newData
	index = newIndex
	name = data.name

func _ready() -> void:
	super()
	%VisNotifier.screen_entered.connect(VisUpdate.bind(true))
	%VisNotifier.screen_exited.connect(VisUpdate.bind(false))

func _OnMouseHover():
	super()
	SlideSelect()

func _OnMouseUnhover():
	super()
	SlideSelect()

func VisUpdate(vis : bool) -> void:
	if vis:
		var c := content.instantiate()
		add_child(c)
		c.Refresh(self)
	else:
		if get_child_count() > 1:
			get_child(1).free()

func ConnectToPlayTrack(home : HomeMenu):
	Pressed.connect(home.PlayTrack.bind(data))

func SlideSelect():
	if !Input.is_action_pressed("SelectMode"): return
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): return
	Select(true)

func Clicked() -> void:
	if Input.is_action_pressed("SelectMode"):
		Select(!selected)
	else:
		Pressed.emit()
