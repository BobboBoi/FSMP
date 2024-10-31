extends Resource
class_name AlbumData

@export var name : String
@export var artists : Array

static func Create(newName : String,newArtists : Array = []) -> AlbumData:
	var newDat = AlbumData.new()
	newDat.name = newName
	newDat.artists = newArtists
	return newDat
