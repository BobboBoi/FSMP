extends Resource
class_name MusicData

##Path to the music file
@export var path : String
@export var name : String
@export var artist : String
@export var album : String
@export var albumIndex : int

static func CreateFromMetaData(newPath : String,meta : MetaData) -> MusicData:
	var newData := MusicData.new()
	newData.path = newPath
	newData.name = meta.Title
	newData.artist = meta.Artists[0]
	newData.album = meta.Album
	newData.albumIndex = meta.Index
	return newData

static func Create(newName : String,newPath : String,newArtist : String = "",newAlbum : String = "",newIndex : int = 0) -> MusicData:
	var newData := MusicData.new()
	newData.name = newName
	newData.path = newPath
	newData.artist = newArtist
	newData.album = newAlbum
	newData.albumIndex = newIndex
	return newData
