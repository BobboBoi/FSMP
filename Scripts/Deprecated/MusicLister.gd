extends Control

@onready var selectionLoad = preload("res://Scenes/MusicSelection.tscn")
@onready var quickAccLoad = preload("res://Scenes/Song.tscn")

#Refernces
@onready var homeList = get_node("../Home/Music/SongList")
@onready var home = get_node("../Home")
@onready var player = get_node("../")
@onready var quickList = get_node("List/Vcont/Scroll/List")

var paths = ["{MUSIC PATH}"]

# Load All songs for home and quick access
func _ready():
	#quickList.custom_minimum_size.x = size.x
	for p in paths:
		var files = []
		var dir = DirAccess.open(p)
		print(p)
		dir.list_dir_begin()
		
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif musicFile(file) and not file.begins_with(".") and not file.ends_with(".ceol"):
				files.append(file)
		dir.list_dir_end()
		for i in files:
			var loaded = Loader._load("user://Songs/"+i)
			if loaded == null:
				var save = load("res://Store/Song.gd").new()
				save.index = 0
				save.name = i
				save.album = ""
				save.artist = ""
				save.path = p+"/"+i
				Loader._save("user://Songs/"+i,save)
				loaded = save
			
			var butt = quickAccLoad
			butt = butt.instantiate()
			butt.path = p+"/"+i
			butt.custom_minimum_size = Vector2(200,75)
			butt.text = i
			butt.mouse_filter = butt.MOUSE_FILTER_PASS
			butt.connect("pressed",Callable(player,"play").bind(butt.path,loaded.name,loaded.album))   
			quickList.add_child(butt)
			
			
			butt = selectionLoad
			butt = butt.instantiate()
			butt.init(loaded.index,loaded.name,loaded.artist,loaded.album,loaded.path)
			butt.get_node("Button").connect("pressed",Callable(player,"play").bind(butt.path,loaded.name,loaded.album))
			butt.get_node("Button").connect("pressed",Callable(get_node("../Home"),"hideHome"))
			homeList.add_child(butt)
	homeList.sort()
	
	#size.y = get_viewport_rect().size.y
	
	#get_node("../Button").position.x = size.x

func musicFile(file):
	return file.ends_with(".wav") or file.ends_with(".mp3") or file.ends_with(".ogg")


func _on_button_pressed():
	var tween = create_tween()
	if $List.position.x == 0:
		tween.tween_property($List,"position",Vector2(-$List.size.x as float,0),0.4)
		$List/Button.text = ">"
	else:
		tween.tween_property($List,"position",Vector2(0.0,0.0),0.4)
		$List/Button.text = "<"



func _on_text_edit_text_changed():
	for i in quickList.get_children():
		if i is QuickMusicSelection:
			i.visible = !(i.text.to_lower().find($List/Vcont/Searchbar.text) == -1 and not $List/Vcont/Searchbar.text == "")
