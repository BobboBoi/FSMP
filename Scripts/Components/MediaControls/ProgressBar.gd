extends ProgressBar

@onready var progresspoint := %Indicator

@onready var stream : Player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	stream.connect("NewTrack",NewTrack)

func _process(_delta: float) -> void:
	self.value = stream.get_playback_position()
	progresspoint.position.x = (self.size.x-20)*self.value/self.max_value +4

func NewTrack(newStream : AudioStream) -> void:
	self.max_value = roundi(newStream.get_length())
