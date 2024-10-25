extends Control
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

var selected := false

static func Create(newData : MusicData,newIndex := 0) -> MusicSelection:
	var inst = preload("res://Scenes/MusicSelection.tscn").instantiate()
	inst.data = newData
	inst.index = newIndex
	inst.name = inst.data.name
	return inst;

func _ready() -> void:
	Refresh()

func Refresh() -> void:
	if button == null: return
	%Name.text = data.name
	%Artist.text = data.artist
	%Album.text = data.album
	
	#%Index.visible = index >= 0
	%Index.text = str(index)

func ConnectToPlayer(player : Player):
	button.connect("pressed",player.PlayFromData.bind(data))#.path,data.name,data.album))   

func BoxToggled(toggled_on: bool) -> void:
	selected = toggled_on
