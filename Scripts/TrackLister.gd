extends Node
class_name TrackLister

var music : Array[MusicData] = []
var albums : Array[AlbumData] = []
var paths : Array[String] = []

var threads : Array[Thread] = []

#Seems to not work with threading?
#const illegalChars : Array[String] = ["\\","/",":","?","*","\"","|","%","<",">"]

signal ListChanged

func _ready() -> void:
	MeasureReloadSpeed()

func _exit_tree() -> void:
	for t in threads:
		t.wait_to_finish()
	
	music.clear()

##Used for performance tests.[br]
##Same as [mehtod Reload] but also prints the load time and amount into the console.
func MeasureReloadSpeed():
	var time = Time.get_ticks_msec()
	await Reload()
	print("Took %f seconds to load" % ((Time.get_ticks_msec() - time) / 1000.0))
	print("While loading: %s total tracks and %s total albums!" % [music.size(),albums.size()] )

##Look for music files in saved directories
func Reload() -> void:
	paths = Loader.config.musicPaths
	music = []
	albums = []
	threads = []
	
	for p in range(paths.size()):
		var newThread := Thread.new()
		threads.push_back(newThread)
		threads[p].start(AddMusicFromPath.bind(paths[p]))
	
	for t in threads:
		var result : Array[MusicData] = await t.wait_to_finish()
		
		for i in result:
			if music.filter(func(d : MusicData): return d.name == i.name && d.artist == i.artist).size() == 0:
				music.append(i)
	
	# Find every unique album in the library
	var uniqueAlbums : Array = []
	for i in music:
		if i.album != "":
			if uniqueAlbums.find(i.album) == -1:
				uniqueAlbums.append(i.album)
	
	# Load the album metadeta and add them to the library
	for i in uniqueAlbums:
		var loadedAlbum := CheckAlbumData(i)
		albums.append(loadedAlbum)
	
	albums.sort_custom(func(a,b): return a.name.to_lower() < b.name.to_lower())
	
	ListChanged.emit()

## Call check music data on every file in the given directory.
## And return all data for the music in the directory.
func AddMusicFromPath(path : String, recursive := true) -> Array[MusicData]:
	if !DirAccess.dir_exists_absolute(path):
		Messages.call_deferred_thread_group("TextMessage", path, " does not exist")
		return []
	
	var files := FindMusicFiles(path, recursive)
	var newMusic : Array[MusicData] = []
	
	# Go over files in dir
	for p in files:
		var loadedMusic := CheckMusicData(p)
		newMusic.append(loadedMusic)
	
	return newMusic

func FindMusicFiles(path : String, recursive := true) -> Array:
	var files := []
	var dir := DirAccess.open(path)
	dir.list_dir_begin()
	
	while true:
		var file := dir.get_next()
		if file == "":
			break
		
		var filepath := path + "\\" + file
		
		if IsMusicFile(file) and not file.begins_with("."):
			files.append(filepath)
		elif !IsUnsupportedMusicFile(file) and recursive:
			if DirAccess.dir_exists_absolute(filepath) and !IsExcluded(filepath):
				files.append_array(FindMusicFiles(filepath))
	
	dir.list_dir_end()
	return files

## Load album data or create new data if it doesn't exist.
func CheckAlbumData(albumName : String) -> AlbumData:
	return AlbumData.Create(albumName) #TODO Artists aren't listed yet

## Attempt to load the album cover from the files metadata
func LoadAlbumCover(data : AlbumData) -> ImageTexture:
	# Skip album covers that we already know won't load
	if data.coverStatus == AlbumData.COVER_STATUS.CORRUPT_ERROR: return null
	if data.coverStatus == AlbumData.COVER_STATUS.NO_COVER: return null
	
	var list := music.filter(func(d): return d.album == data.name)
	if list.size() <= 0: return null
	
	for i in list:
		var reader := MetaDataReader.new()
		reader.GetImageFromAudioFileAsync(i.path,0) #Causes errors for some JPEG's
		var result = await reader.CoverLoaded
		
		if result != null:
			if result is ImageTexture:
				data.coverStatus = AlbumData.COVER_STATUS.HAS_COVER
				result.resource_name = data.name
				return result
			else:
				data.coverStatus = AlbumData.COVER_STATUS.CORRUPT_ERROR
		else:
			data.coverStatus = AlbumData.COVER_STATUS.NO_COVER
	
	return null;

## Get the [AlbumData] associated with the provided [param album] title
func GetAlbumData(album : String) -> AlbumData:
	var a := albums.filter(func (d : AlbumData): return d.name == album)
	if a.size() <= 0: return null
	return a.front()

## If true the path is in the current [Config.exludePaths]
func IsExcluded(path : String) -> bool:
	path = path.replace("\\","/")
	for e in Loader.config.excludePaths:
		if path.contains(e):
			return true
	
	return false

static func CheckMusicData(filepath : String) -> MusicData:
	var meta := MetaDataReader.GetFromAudioFile(filepath)
	return MusicData.CreateFromMetaData(filepath,meta)

## Returns [code]true[/code] if the provided [param filepath] is of a supported music file type
static func IsMusicFile(filepath : String) -> bool:
	return filepath.ends_with(".wav") or filepath.ends_with(".mp3") or filepath.ends_with(".ogg")

## Returns [code]true[/code] if the provided [param filepath] is of a unsupported music file type
static func IsUnsupportedMusicFile(filepath : String) -> bool:
	return filepath.ends_with(".flac") or filepath.ends_with(".m4a")

## Returns [code]true[/code] if the provided [param filepath] is of a supported image file type
static func IsImageFile(filepath : String) -> bool:
	return filepath.ends_with(".png") or filepath.ends_with(".jpg")
