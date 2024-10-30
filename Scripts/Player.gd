extends AudioStreamPlayer
class_name Player

var loopStart := 0.0

signal NewTrack(stream : AudioStream)

func _init() -> void:
	if !finished.is_connected(Finished): finished.connect(Finished)

func PlayFromPath(path : String,emitSignal := true):
	var loaded = Loader._load(path)
	if loaded == null or loaded is not MusicData: return
	PlayFromData(loaded,emitSignal)

func PlayFromData(data : MusicData,emitSignal := true):
	PlayNewTrack(data.path,data.name,data.album,emitSignal)

func PlayNewTrack(music : String,trackName : String,album :String,emitSignal := true):
	self.stop()
	if music == "": return
	
	print(music)
	var file = FileAccess.open(music, FileAccess.READ)
	var bytes = file.get_buffer(file.get_length())
	
	# Load mp3
	if music.ends_with(".mp3"):
		self.stream = StreamLoader.LoadMP3FromBytes(bytes)
	# Load wav
	elif music.ends_with(".wav"):
		self.stream = StreamLoader.LoadWAVFromBytes(bytes)
	# Load wav
	elif music.ends_with(".ogg"):
		self.stream = StreamLoader.LoadOGGFromBytes(bytes)
	
	file.close()
	
	self.play()
	
	if emitSignal: NewTrack.emit(stream)
	Discord.refresh(trackName,album)

##WAV files don't loop properly when imported 
##This will fix that
func Finished():
	self.play(loopStart)
