extends Node

@onready var lister : TrackLister = get_tree().get_first_node_in_group("Lister")
@onready var player : Player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	var arguments := OS.get_cmdline_args()
	if arguments.size() <= 0: 
		queue_free()
		return
	
	if !FileAccess.file_exists(arguments[0]) or !TrackLister.MusicFile(arguments[0]):
		print("Unsupported cmd argument: \"",arguments[0],"\" supported file formats are MP3,WAV,OGG")
		queue_free()
		return
	
	var meta := MetaDataReader.GetFromAudioFile(arguments[0])
	var title := ""
	
	if meta != null:
		title = meta.Title
		if title == "":
			title = arguments[0].get_slice("\\",arguments[0].count("\\"))
	
	var filter := lister.music.filter(func(data : MusicData): return data.name == title)
	
	if filter.size() > 0:
		print("DATA:",filter)
		player.PlayFromData(filter[0])
	else:
		print("PATH:",arguments[0])
		var album := ""
		if meta != null: album = meta.Album
		
		player.PlayNewTrack(arguments[0],title,album)
	
	queue_free()
