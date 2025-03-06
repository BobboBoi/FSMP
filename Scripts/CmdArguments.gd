extends Node

@onready var home : HomeMenu = get_tree().get_first_node_in_group("Home")

func _ready() -> void:
	var arguments := OS.get_cmdline_args()
	if arguments.size() <= 0: 
		queue_free()
		return
	
	var index := -1
	for i in arguments.size():
		if FileAccess.file_exists(arguments[i]) and TrackLister.IsMusicFile(arguments[i]):
			index = i
			break
		print("Unsupported cmd argument: \"",arguments[i],"\" supported file formats are MP3,WAV,OGG")
	
	if index < 0:
		queue_free()
		return
	
	var fileName := arguments[index].get_slice("\\",arguments[index].count("\\"))
	var dir := arguments[index].erase(arguments[index].find(fileName),fileName.length())
	
	Player.PlaySingleFromData(TrackLister.CheckMusicData(dir,fileName))
	
	if home != null:
		if !home.is_inside_tree():
			await home.ready
		home.HideHome()
	
	queue_free()
