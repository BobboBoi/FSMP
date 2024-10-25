extends Control

@onready var progressbar := %ProgressBar
@onready var progresspoint := %Indicator

@onready var stream : Player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	stream.connect("NewTrack",NewTrack)

func _process(_delta: float) -> void:
	progressbar.value = stream.get_playback_position()
	progresspoint.position.x = (progressbar.size.x-20)*progressbar.value/progressbar.max_value +4

func NewTrack(newStream : AudioStream) -> void:
	progressbar.max_value = roundi(newStream.get_length())
