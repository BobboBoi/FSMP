extends HomeMenuItem
class_name QueueSelection

@export var musicIndex : int
@export var songName : String

static func Create(newSongName : String) -> QueueSelection:
	var loaded := preload("res://Scenes/QueueSelection.tscn").instantiate()
	loaded.songName = newSongName
	loaded.get_node("%Name").text = newSongName
	return loaded
