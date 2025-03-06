extends RichTextLabel

@export var track := false
@export var artist := false
@export var album := false

func _ready() -> void:
	Player.NewTrack.connect(Refresh)
	text = ""

func Refresh(_stream) -> void:
	var data := Player.queue[Player.currentIndex]
	text = data.name+(" - " if data.artist != "" else "")+data.artist
