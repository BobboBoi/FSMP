extends Node
class_name TrackLister

var music : Array[MusicData] = []
var albums : Array[AlbumData] = []
var paths : Array[String] = []

var reloadThread : Thread
var subThreads : Array[Thread] = []

#Seems to not work with threading?
#const illegalChars : Array[String] = ["\\","/",":","?","*","\"","|","%","<",">"]
const THREAD_SLICE := 100

signal ReloadStarted(async : bool)
signal ListChanged

func _ready() -> void:
	Reload()

func _exit_tree() -> void:
	for t in subThreads:
		t.wait_to_finish()
	
	reloadThread.wait_to_finish()
	music.clear()

## Look for music files in saved directories.[br]If [param async] is [code]true[/code] runs on the [member reloadThread].[br]
## Emits [signal ReloadStarted] when starting a new reload task.
## Emits [signal ListChanged] when finished.
func Reload(async := true) -> void:
	if reloadThread != null and async:
		if reloadThread.is_alive():
			push_error("Reload thread already running!")
			return
	
	ReloadStarted.emit(async)
	
	if async:
		if reloadThread == null: 
			reloadThread = Thread.new()
		
		ListChanged.connect(reloadThread.wait_to_finish, CONNECT_ONE_SHOT)
		reloadThread.start(MeasureReloadSpeed)
	
	else:
		ReloadTask()

## Used for performance tests.[br]
## Same as [mehtod ReloadTask] but also prints the load time and amount into the console.
func MeasureReloadSpeed():
	var time = Time.get_ticks_msec()
	ReloadTask()
	
	print("Took %f seconds to load" % ((Time.get_ticks_msec() - time) / 1000.0))
	print("While loading: %s total tracks and %s total albums!" % [music.size(),albums.size()] )

## Look for music files in saved directories
func ReloadTask() -> void:
	paths = Loader.config.musicPaths
	music = []
	albums = []
	subThreads = []
	
	# Find files
	var files : PackedStringArray = []
	for p in range(paths.size()):
		var newThread := Thread.new()
		subThreads.push_back(newThread)
		subThreads[p].start(GetMusicFilesFromPath.bind(paths[p]), Thread.Priority.PRIORITY_HIGH)
	
	for t in subThreads:
		files.append_array(await t.wait_to_finish())
	
	subThreads = []
	
	# Get file data
	for s in range(ceil(float(files.size()) / THREAD_SLICE)):
		var newThread := Thread.new()
		subThreads.push_back(newThread)
		subThreads[s].start(GetMusicDataFromFiles.bind(files.slice(THREAD_SLICE*s,THREAD_SLICE*(s+1))), Thread.Priority.PRIORITY_HIGH)
	
	for t in subThreads:
		var result : Array[MusicData] = await t.wait_to_finish()
		
		for i in result:
			if music.filter(func(d : MusicData): return d.name == i.name && d.GetArtistsString() == i.GetArtistsString()).size() == 0:
				music.append(i)
	
	# Find every unique album in the library
	var uniqueAlbums : PackedStringArray = []
	for i in music:
		if i.album != "":
			if uniqueAlbums.find(i.album) == -1:
				uniqueAlbums.append(i.album)
	
	# Load the album metadeta and add them to the library
	for i in uniqueAlbums:
		var loadedAlbum := CheckAlbumData(i)
		albums.append(loadedAlbum)
	
	albums.sort_custom(func(a,b): return a.name.to_lower() < b.name.to_lower())
	
	ListChanged.emit.call_deferred()

## Call check music data on every file in the given directory.
## And return all data for the music in the directory.
func GetMusicFilesFromPath(path : String, recursive := true) -> PackedStringArray:
	if !DirAccess.dir_exists_absolute(path):
		Messages.call_deferred_thread_group("TextMessage", path, " does not exist")
		return []
	
	var excludes : PackedStringArray = []
	for p in Loader.config.excludePaths:
		if path.substr(0,1) == p.substr(0,1):
			excludes.append(p)
	
	return FindMusicFiles(path, excludes, recursive)

func FindMusicFiles(path : String, excludes : PackedStringArray, recursive := true) -> PackedStringArray:
	var files : PackedStringArray = []
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
			if DirAccess.dir_exists_absolute(filepath) and !IsExcluded(filepath, excludes):
				files.append_array(FindMusicFiles(filepath, excludes))
	
	dir.list_dir_end()
	return files

func GetMusicDataFromFiles(files : PackedStringArray) -> Array[MusicData]:
	var newMusic : Array[MusicData] = []
	
	# Go over files in dir
	for p in files:
		var loadedMusic := CheckMusicData(p)
		newMusic.append(loadedMusic)
	
	return newMusic

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
func IsExcluded(path : String, excludes : PackedStringArray) -> bool:
	path = path.replace("\\","/")
	
	for e in excludes:
		if path == e:
			return true
	
	return false

static func CheckMusicData(filepath : String) -> MusicData:
	var meta := MetaDataReader.GetFromAudioFile(filepath)
	return MusicData.CreateFromMetaData(filepath,meta)

## Returns [code]true[/code] if the provided [param filepath] is of a supported music file type
static func IsMusicFile(filepath : String) -> bool:
	return filepath.ends_with(".wav") or filepath.ends_with(".mp3") or filepath.ends_with(".ogg") or filepath.ends_with(".flac")

## Returns [code]true[/code] if the provided [param filepath] is of a unsupported music file type
static func IsUnsupportedMusicFile(filepath : String) -> bool:
	return filepath.ends_with(".m4a")

## Returns [code]true[/code] if the provided [param filepath] is of a supported image file type
static func IsImageFile(filepath : String) -> bool:
	return filepath.ends_with(".png") or filepath.ends_with(".jpg")
