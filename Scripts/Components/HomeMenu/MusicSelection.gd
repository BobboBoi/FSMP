extends HomeMenuItem
class_name MusicSelection

@export var data : MusicData :
	set(value):
		data = value
		if is_inside_tree(): Refresh()
@export var index : int : 
	set(value):
		index = value
		if is_inside_tree(): Refresh()

static func Create(newData : MusicData,newIndex := 0) -> MusicSelection:
	var inst = preload("res://Scenes/Components/HomeMenu/MusicSelection.tscn").instantiate()
	inst.data = newData
	inst.index = newIndex
	inst.name = inst.data.name
	return inst;

func _ready() -> void:
	super()
	Selected.connect(%CheckBox.set_pressed_no_signal.bind(true))
	Unselected.connect(%CheckBox.set_pressed_no_signal.bind(false))
	Refresh()

func Refresh() -> void:
	%Name.text = data.name
	%Artist.text = data.artist
	%Album.text = data.album
	
	#%Index.visible = index >= 0
	%Index.text = str(index)

func ConnectToPlayer(player : Player):
	Pressed.connect(player.PlaySingleFromData.bind(data))

func OnHover():
	super()
	SlideSelect()

func OnUnhover():
	super()
	SlideSelect()

func SlideSelect():
	if !Input.is_action_pressed("SelectMode"): return
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): return
	Select(true)

func Clicked() -> void:
	if Input.is_action_pressed("SelectMode"):
		Select(!selected)
	else:
		Pressed.emit()
