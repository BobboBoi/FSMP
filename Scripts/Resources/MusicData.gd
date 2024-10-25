extends Resource
class_name MusicData

##Path to the music file
@export var path : String
@export var name : String
@export var artist : String
@export var album : String

static func Create(newName : String,newPath : String,newArtist : String = "",newAlbum : String = "") -> MusicData:
	var newData := MusicData.new()
	newData.name = newName
	newData.path = newPath
	newData.artist = newArtist
	newData.album = newAlbum
	return newData
