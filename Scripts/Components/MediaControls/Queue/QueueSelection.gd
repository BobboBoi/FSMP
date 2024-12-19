extends HomeMenuItem
class_name QueueSelection

@export var musicIndex : int
@export var songName : String

static func Create(data : MusicData) -> QueueSelection:
	var loaded := preload("res://Scenes/Components/MediaControls/QueueSelection.tscn").instantiate()
	loaded.songName = data.name
	loaded.get_node("%Name").text = data.name
	loaded.get_node("%Artist").text = data.artist
	return loaded
