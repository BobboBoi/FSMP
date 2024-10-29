extends Resource
class_name MusicData

##Path to the music file
@export var path : String
@export var name : String
@export var artist : String
@export var album : String
@export var albumIndex : int

static func Create(newName : String,newPath : String,newArtist : String = "",newAlbum : String = "",newIndex : int = 0) -> MusicData:
	var newData := MusicData.new()
	newData.name = newName
	newData.path = newPath
	newData.artist = newArtist
	newData.album = newAlbum
	newData.albumIndex = newIndex
	return newData
