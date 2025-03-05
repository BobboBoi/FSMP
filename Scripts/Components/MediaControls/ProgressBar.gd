extends ProgressBar

@onready var progresspoint := %Indicator
@onready var player := get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	player.connect("NewTrack",NewTrack)

func _process(_delta: float) -> void:
	self.value = player.get_playback_position()
	progresspoint.position.x = (self.size.x-20)*self.value/self.max_value +4

func _gui_input(event: InputEvent) -> void:
	if player.stream == null: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var local = make_input_local(event)
		if Rect2(Vector2(0,0),size).has_point(local.position):
			return
		
		var mod = (local.position.x+54) / (self.size.x)
		player.seek(player.stream.get_length() * mod)

func NewTrack(newStream : AudioStream) -> void:
	self.max_value = roundi(newStream.get_length())
