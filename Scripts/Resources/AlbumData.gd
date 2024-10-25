extends Resource
class_name AlbumData

@export var name : String
@export var artists : Array
@export var cover : String

static func Create(newName : String,newArtists : Array = [],newCover : String = "") -> AlbumData:
	var newDat = AlbumData.new()
	newDat.name = newName
	newDat.artists = newArtists
	newDat.cover = newCover
	return newDat
