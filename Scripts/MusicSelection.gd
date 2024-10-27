extends HomeMenuItem
class_name MusicSelection

@onready var button : Button = %Button

@export var data : MusicData :
	set(value):
		data = value
		if button != null: Refresh()
@export var index : int : 
	set(value):
		index = value
		if button != null: Refresh()

signal Pressed

static func Create(newData : MusicData,newIndex := 0) -> MusicSelection:
	var inst = preload("res://Scenes/MusicSelection.tscn").instantiate()
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
	if button == null: return
	%Name.text = data.name
	%Artist.text = data.artist
	%Album.text = data.album
	
	#%Index.visible = index >= 0
	%Index.text = str(index)

func ConnectToPlayer(player : Player):
	Pressed.connect(player.PlayFromData.bind(data))

func ButtonPressed() -> void:
	if Input.is_action_pressed("SelectMode"):
		Select(true)
	else:
		Pressed.emit()
