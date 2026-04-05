extends Resource
class_name MusicData

##Path to the music file
@export var path : String
@export var name : String
@export var artists : PackedStringArray
@export var album : String
@export var albumIndex : int
@export var disc : int

static func CreateFromMetaData(newPath : String, meta : MetaData) -> MusicData:
	var newData := MusicData.new()
	newData.path = newPath
	newData.name = meta.Title
	newData.artists = meta.Artists
	newData.album = meta.Album
	newData.albumIndex = meta.Index
	newData.disc = meta.Disc
	return newData

static func Create(newName : String, newPath : String, newArtist := "", newAlbum := "", newIndex := 0, newDisc := 0) -> MusicData:
	var newData := MusicData.new()
	newData.name = newName
	newData.path = newPath
	newData.artists = [newArtist]
	newData.album = newAlbum
	newData.albumIndex = newIndex
	newData.disc = newDisc
	return newData

func GetArtistsString() -> String:
	var result := ""
	
	if artists.size() > 2:
		for a in range(artists.size()-2):
			result += artists[a] + ", "
	
	if artists.size() > 1:
		result += artists[artists.size()-2] + " & " + artists[artists.size()-1]
	elif artists.size() == 1:
		result = artists[0]
	
	return result
