extends Resource
class_name AlbumData

@export var name : String
@export var artists : Array
@export var coverStatus := COVER_STATUS.UNKOWN

enum COVER_STATUS{
	UNKOWN,
	HAS_COVER,
	NO_COVER,
	CORRUPT_ERROR,
}

static func Create(newName : String,newArtists : Array = []) -> AlbumData:
	var newDat = AlbumData.new()
	newDat.name = newName
	newDat.artists = newArtists
	return newDat
