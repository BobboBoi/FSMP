extends HomeMenuItem
class_name AlbumSelection

var data : AlbumData :
	set(value):
		data = value
		if is_inside_tree(): Refresh()
var cover : ImageTexture = null

static func Create(newData : AlbumData) -> AlbumSelection:
	var inst = preload("res://Scenes/Components/HomeMenu/AlbumSelection.tscn").instantiate()
	inst.data = newData
	return inst

func _ready() -> void:
	super()
	Refresh()
	%VisNotifier.screen_entered.connect(VisUpdate.bind(true))
	%VisNotifier.screen_exited.connect(VisUpdate.bind(false))

func VisUpdate(vis : bool) -> void:
	if vis and cover == null:
		cover = await Lister.LoadAlbumCover(data)
		if cover == null: return
		%AlbumCover.FadeIn(cover)

func Refresh():
	%Name.text = data.name
	%Artist.text = str(data.artists)
	
	if cover == null: return
	if %AlbumCover.texture != cover:
		%AlbumCover.texture = cover

func ConnectToAlbum(home : HomeMenu) -> void:
	Pressed.connect(home.OpenAlbumSelection.bind(self))
