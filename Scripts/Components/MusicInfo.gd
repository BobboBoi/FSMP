extends RichTextLabel

@export var track := false
@export var artist := false
@export var album := false

func _ready() -> void:
	Player.NewTrack.connect(Refresh)
	
	if Player.playing:
		text = Player.queue.front().name
	else:
		text = ""

func Refresh(_stream) -> void:
	var data := Player.queue[Player.currentIndex]
	
	if data.artists.size() > 0:
		text = data.name + " - " + data.GetArtistsString()
	else:
		text = data.name;
