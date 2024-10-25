extends Control
class_name AlbumSelection

@onready var button : Button = %Button

var data : AlbumData :
	set(value):
		data = value
		if button != null: Refresh()
var coverPath : String

static func Create(newData : AlbumData) -> AlbumSelection:
	var inst = preload("res://Scenes/AlbumSelection.tscn").instantiate()
	inst.data = newData
	return inst

func _ready() -> void:
	Refresh(true)

func Refresh(cover = false):
	$Name.text = data.name
	$Artist.text = str(data.artists)
	
	if data.cover == "" or !cover: return
	LoadCover(data.cover)

func LoadCover(path : String):
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null: return
	
	var bytes = file.get_buffer(file.get_length())
	var texture = Image.new()
	
	if bytes.size() > 0:
		if path.ends_with(".png"):
			texture.load_png_from_buffer(bytes)
			#print("Load succesful png:",texture)
		elif path.ends_with(".jpg"):
			texture.load_jpg_from_buffer(bytes)
			#print("Load succesful jpg:",texture)
		
		var final = ImageTexture.create_from_image(texture)
		$TextureRect.texture = final
	
	file.close()

func ConnectToAlbum(home : HomeMenu) -> void:
	get_node("Button").connect("pressed",home.OpenAlbum.bind(data))
