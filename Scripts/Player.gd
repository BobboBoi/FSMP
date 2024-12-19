extends AudioStreamPlayer
class_name Player

@onready var window := get_window()

var loopStart := 0.0

var srcQueue : Array[MusicData] = []
var queue : Array[MusicData] = []
var shuffled := false
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

func _physics_process(_delta: float) -> void:
	if window.mode != window.Mode.MODE_MINIMIZED: return
	if Input.is_action_just_pressed("Pause"):
		self.stream_paused = !self.stream_paused

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		self.stream_paused = !self.stream_paused

#region Playing
##Similair to [member PlayFromPath] but resets the queue.[br]
##This is used when a single song is selected to be played.
func PlaySingleFromPath(path : String,emitSignal := true):
	var loaded = Loader._load(path)
	if loaded == null or loaded is not MusicData: return
	PlaySingleFromData(loaded,emitSignal)

##Plays a new track with the give [param path].
##[b]Note[/b] the path used is the path to the local userdata and not the music file.
func PlayFromPath(path : String,emitSignal := true):
	var loaded = Loader._load(path)
	if loaded == null or loaded is not MusicData: return
	PlayFromData(loaded,emitSignal)

##Similair to [member PlayFromData] but resets the queue.[br]
##This is used when a single song is selected to be played.
func PlaySingleFromData(data : MusicData,emitSignal := true):
	srcQueue = [data]
	queue = srcQueue
	QueueChange.emit()
	
	PlayNewTrack(data.path,data.name,data.album,data.artist,emitSignal)

##Plays a track using data from [param data].
func PlayFromData(data : MusicData,emitSignal := true):
	PlayNewTrack(data.path,data.name,data.album,data.artist,emitSignal)

func PlayNewTrack(music : String,trackName : String = "",album : String = "",artist : String = "", emitSignal := true):
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
func EnqueueFromDataArray(data : Array[MusicData]) -> void:
	var startPlaying := queue.size() <= 0
	srcQueue.append_array(data)
	queue.append_array(data)
	
	QueueChange.emit()
	
	if startPlaying: PlayFromData(queue[currentIndex])

func ProgressQueue() -> void:
	currentIndex = wrapi(currentIndex+1,0,queue.size())
	PlayFromData(queue[currentIndex])

func TravelTo(index : int) -> void:
	currentIndex = wrapi(index,0,queue.size())
	PlayFromData(queue[currentIndex])

func MoveItemInQueue(init : int, new : int) -> void:
	print("Queue move: ",init," -> ",new)
	if shuffled:
		queue.insert(new,queue.pop_at(init))
	else:
		srcQueue.insert(new,srcQueue.pop_at(init))
		queue = srcQueue

func ClearQueue() -> void:
	srcQueue.clear()
	queue.clear()
	self.stop()
	
	QueueChange.emit()
	Discord.refresh()

func Shuffle() -> void:
	var currentTrack := queue[currentIndex]
	
	#Restore src
	if shuffled:
		queue = srcQueue
		currentIndex = queue.find(currentTrack)
	#Shuffle
	else:
		queue.shuffle()
		queue.push_front(queue.pop_at(queue.find(currentTrack)))
		currentIndex = 0
	
	shuffled = !shuffled
	QueueChange.emit()

##Called when the current track is finished playing.
func Finished() -> void:
	match(loopMode):
		LOOPMODE.LOOP_SINGLE:
			self.play(loopStart)
		LOOPMODE.LOOP_QUEUE:
			if queue.size() > 0:
				ProgressQueue()
			else:
				self.play(loopStart)
#endregion
