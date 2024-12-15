extends AudioStreamPlayer
class_name Player

var loopStart := 0.0

var srcQueue : Array[MusicData] = []
var queue : Array[MusicData] = []
var currentIndex := 0

var loopMode : LOOPMODE = LOOPMODE.LOOP_QUEUE
enum LOOPMODE {
	LOOP_QUEUE,
	LOOP_SINGLE,
	NO_LOOP
}

signal NewTrack(stream : AudioStream)
signal QueueChange()

func _init() -> void:
	if !finished.is_connected(Finished): finished.connect(Finished)

#region Playing
func PlayFromPath(path : String,emitSignal := true):
	var loaded = Loader._load(path)
	if loaded == null or loaded is not MusicData: return
	PlayFromData(loaded,emitSignal)

func PlayFromData(data : MusicData,emitSignal := true):
	PlayNewTrack(data.path,data.name,data.album,data.artist,emitSignal)

func PlayNewTrack(music : String,trackName : String,album : String,artist : String, emitSignal := true):
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
	Discord.refresh(trackName,album,artist)
#endregion

#region Queue
func EnqueueFromDataArray(data : Array[MusicData]):
	var startPlaying := queue.size() <= 0
	srcQueue.append_array(data)
	queue.append_array(data)
	
	QueueChange.emit()
	
	if startPlaying: PlayFromData(queue[currentIndex])

func NextInQueue():
	currentIndex = wrapi(currentIndex+1,0,queue.size())
	PlayFromData(queue[currentIndex])

func ClearQueue():
	srcQueue.clear()
	queue.clear()
	self.stop()
	
	QueueChange.emit()
	Discord.refresh()

func Shuffle():
	var currentTrack := queue[currentIndex]
	
	#Restore src
	if srcQueue != queue:
		print("restore")
		queue = srcQueue
		currentIndex = queue.find(currentTrack)
	#Shuffle
	else:
		print("shuffle")
		queue.shuffle()
		queue.remove_at(queue.find(currentTrack))
		queue.push_front(currentTrack)
		currentIndex = 0
	
	QueueChange.emit()

##Called wg
func Finished():
	match(loopMode):
		LOOPMODE.LOOP_SINGLE:
			self.play(loopStart)
		LOOPMODE.LOOP_QUEUE:
			if queue.size() > 0:
				NextInQueue()
			else:
				self.play(loopStart)
#endregion
