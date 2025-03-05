extends RichTextLabel

@onready var player : Player = get_tree().get_first_node_in_group("Player")
@export var track := false
@export var artist := false
@export var album := false

func _ready() -> void:
	player.NewTrack.connect(Refresh)
	text = ""

func Refresh(_stream) -> void:
	var data := player.queue[player.currentIndex]
	text = data.name+(" - " if data.artist != "" else "")+data.artist
