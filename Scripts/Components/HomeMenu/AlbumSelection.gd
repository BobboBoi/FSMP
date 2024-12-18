extends HomeMenuItem
class_name AlbumSelection

@onready var button : Button = %Button

var data : AlbumData :
	set(value):
		data = value
		if button != null: Refresh()
var cover : ImageTexture = null

static func Create(newData : AlbumData,newCover : ImageTexture = null) -> AlbumSelection:
	var inst = preload("res://Scenes/Components/HomeMenu/AlbumSelection.tscn").instantiate()
	inst.data = newData
	if newCover != null:
		inst.cover = newCover
	return inst

func _ready() -> void:
	super()
	Selected.connect(%CheckBox.set_pressed_no_signal.bind(true))
	Unselected.connect(%CheckBox.set_pressed_no_signal.bind(false))
	Refresh()

func Refresh():
	%Name.text = data.name
	%Artist.text = str(data.artists)
	
	if cover == null: return
	if %AlbumCover.texture != cover:
		%AlbumCover.texture = cover

func ConnectToAlbum(home : HomeMenu) -> void:
	get_node("Button").connect("pressed",home.OpenAlbum.bind(data,%AlbumCover.texture))
